//
//  LLPlayerView.m
//  DMPlayer
//
//  Created by lbq on 2018/1/17.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import "LLPlayerView.h"
#import <Masonry.h>
#import "LLPlaybackControlView.h"

static void *PlayViewStatusObservationContext = &PlayViewStatusObservationContext;

@interface LLPlayerView()<UIGestureRecognizerDelegate,
LLPlaybackControlDelegate>
/** 播放属性 */
@property (nonatomic, strong) AVPlayer               *player;
@property (nonatomic, strong) AVPlayerItem           *playerItem;
@property (nonatomic, strong) AVURLAsset             *urlAsset;
@property (nonatomic, strong) AVAssetImageGenerator  *imageGenerator;

/** playerLayer */
@property (nonatomic, strong) AVPlayerLayer          *playerLayer;
/** 视频填充模式 */
@property (nonatomic, copy) NSString                 *videoGravity;

@property (nonatomic, strong) id<NSObject> playbackTimeObserver;
@property (nonatomic, assign) NSInteger    seekTime;//从seekTime处开始播放

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@property (nonatomic, strong) UIView<LLPlaybackControlViewProtocol> *controlView;
@property (nonatomic, strong) id<LLPlayerModelProtocol> playerModel;

@property (nonatomic, assign) EPlayerState playState; //播放状态

@property (nonatomic, assign) BOOL isLocalVideo;//本地视频

@property (nonatomic, assign) CGFloat sliderLastValue;

@property (nonatomic, assign) BOOL isDragging;
@end

@implementation LLPlayerView

- (instancetype)init
{
    self = [super init];
    if(self){
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

- (void)addPlayerToFatherView:(UIView *)fatherView
{
    [fatherView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(fatherView);
    }];
}
- (void)addObserver {
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    // 监测设备方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStatusBarOrientationChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)addGesture
{
//    // 单击
//    self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
//    self.singleTap.delegate                = self;
//    self.singleTap.numberOfTouchesRequired = 1; //手指数
//    self.singleTap.numberOfTapsRequired    = 1;
//    [self addGestureRecognizer:self.singleTap];
//
//    // 双击(播放/暂停)
//    self.doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
//    self.doubleTap.delegate                = self;
//    self.doubleTap.numberOfTouchesRequired = 1; //手指数
//    self.doubleTap.numberOfTapsRequired    = 2;
//    [self addGestureRecognizer:self.doubleTap];
//
//    // 解决点击当前view时候响应其他控件事件
//    [self.singleTap setDelaysTouchesBegan:YES];
//    [self.doubleTap setDelaysTouchesBegan:YES];
//    // 双击失败响应单击事件
//    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
}

//MARK: public
- (void)playerControlView:(UIView<LLPlaybackControlViewProtocol> *)controlView playerModel:(id<LLPlayerModelProtocol>)playerModel
{
    if (!controlView) {
        self.controlView = (UIView<LLPlaybackControlViewProtocol> *)[[LLPlaybackControlView alloc] init];
    } else {
        self.controlView = controlView;
    }
    self.playerModel = playerModel;
    
    [self configPlayer];
}

- (void)configPlayer
{
    self.urlAsset = [AVURLAsset assetWithURL:self.contentURL];
    // 初始化playerItem
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    // 初始化playerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.backgroundColor = [UIColor blackColor];
    // 此处为默认视频填充模式
    self.playerLayer.videoGravity = self.videoGravity;
    
    [self createTimerObserver];
    
    if ([self.contentURL.scheme isEqualToString:@"file"]) {
        self.isLocalVideo = YES;
        self.playState = EPlayerStatePlaying;
    } else {
        self.isLocalVideo = NO;
        self.playState = EPlayerStateBuffering;
    }
}

-(void)removeKVOObserver{
    if(self.playerItem)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [self.player removeTimeObserver:self.playbackTimeObserver];
        [self.player replaceCurrentItemWithPlayerItem:nil];
    }
}

- (void)play
{
    [self.controlView changePlayStatus:YES];
    [self.player play];
}

- (void)pause
{
    [self.controlView changePlayStatus:NO];
    [self.player pause];
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)createTimerObserver {
    __weak typeof(self) weakSelf = self;
    //CMTimeMake(1, 1) 每隔一秒调用一次block
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
        AVPlayerItem *currentItem = weakSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            CGFloat totalTime     = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value         = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
            [weakSelf.controlView setPlayCurrentTime:currentTime totalTime:totalTime sliderValue:value];
        }
    }];
}

- (void)moviePlayDidEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
    }];
}

///获取视频长度
- (double)duration{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return CMTimeGetSeconds([playerItem duration]);
    }
    else{
        return 0.f;
    }
}

//MARK: Setter
- (void)setControlView:(UIView<LLPlaybackControlViewProtocol> *)controlView
{
    if (_controlView) {return;}
    _controlView = controlView;
    controlView.delegate = self;
    [self addSubview:controlView];
    [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)setPlayerModel:(id<LLPlayerModelProtocol>)playerModel
{
    _playerModel = playerModel;
    
    if (playerModel.seekTime) { self.seekTime = playerModel.seekTime; }
    //    [self.controlView zf_playerModel:playerModel];
    [self addPlayerToFatherView:playerModel.fatherView];
    self.contentURL = playerModel.contentURL;
}

- (void)setContentURL:(NSURL *)contentURL
{
    _contentURL = contentURL;
    [self addObserver];
    
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem==playerItem) {
        return;
    }
    if (_playerItem && playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        _playerItem = nil;
    }
    _playerItem = playerItem;
    if (_playerItem) {
        [_playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionNew
                         context:PlayViewStatusObservationContext];
        
        [_playerItem addObserver:self
                      forKeyPath:@"loadedTimeRanges"
                         options:NSKeyValueObservingOptionNew
                         context:PlayViewStatusObservationContext];
        // 缓冲区空了，需要等待数据
        [_playerItem addObserver:self
                      forKeyPath:@"playbackBufferEmpty"
                         options: NSKeyValueObservingOptionNew
                         context:PlayViewStatusObservationContext];
        // 缓冲区有足够数据可以播放了
        [_playerItem addObserver:self
                      forKeyPath:@"playbackLikelyToKeepUp"
                         options: NSKeyValueObservingOptionNew
                         context:PlayViewStatusObservationContext];
        
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
        // 添加视频播放结束通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    }
}

- (void)setVideoGravityType:(ELayerVideoGravityType)videoGravityType
{
    _videoGravityType = videoGravityType;
    NSString *videoGravity = AVLayerVideoGravityResizeAspect;
    switch (videoGravityType) {
        case ELayerVideoGravityTypeResize:
            videoGravity = AVLayerVideoGravityResize;
            break;
        case ELayerVideoGravityTypeResizeAspect:
            videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case ELayerVideoGravityTypeResizeAspectFill:
            videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            videoGravity = AVLayerVideoGravityResizeAspect;
            break;
    }
    self.videoGravity = videoGravity;
}

//MARK: getter
- (NSString *)videoGravity
{
    if (!_videoGravity) {
        return AVLayerVideoGravityResizeAspect;
    }
    return _videoGravity;
}

//MARK: private Method

- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler {
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        // seekTime:completionHandler:不能精确定位
        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
        // 转换成CMTime才能给player来控制播放进度
//        [self.controlView zf_playerActivity:YES];
        [self.player pause];
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1); //kCMTimeZero
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
//            [weakSelf.controlView zf_playerActivity:NO];
            // 视频跳转回调
            if (completionHandler) { completionHandler(finished); }
            [weakSelf.player play];
            weakSelf.seekTime = 0;
//            weakSelf.isDragged = NO;
            // 结束滑动
//            [weakSelf.controlView zf_playerDraggedEnd];
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp && !weakSelf.isLocalVideo) { weakSelf.playState = EPlayerStateBuffering; }
        }];
    }
}

//MARK: Action & observer

- (void)appResignActive:(NSNotification *)notification
{
    
}

- (void)appBecomeActive:(NSNotification *)notification
{
    
}

- (void)audioRouteChangeListenerCallback:(NSNotification *)notification
{
    
}

- (void)onDeviceOrientationChange:(NSNotification *)notification
{
    
}

- (void)onStatusBarOrientationChange:(NSNotification *)notification
{
    
}


//MARK: LLPlaybackControlDelegate
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView didClickPlayAction:(UIButton *)sender
{
    if (sender.selected) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView progressSliderValueBegin:(id)sender
{
    
}

- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView progressSliderValueChanged:(UISlider *)slider
{
    // 拖动改变视频播放进度
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        self.isDragging = YES;
        BOOL style = false;
        CGFloat value   = slider.value - self.sliderLastValue;
        if (value > 0) { style = YES; }
        if (value < 0) { style = NO; }
        if (value == 0) { return; }
        self.sliderLastValue  = slider.value;
        CGFloat totalTime     = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        //计算出拖动的当前秒数
        CGFloat dragedSeconds = floorf(totalTime * slider.value);
        if (totalTime > 0) { // 当总时长 > 0时候才能拖动slider
            [controlView draggedTime:dragedSeconds totalTime:totalTime isForward:style];
        } else {
            // 此时设置slider值为0
            slider.value = 0;
        }
    } else { // player状态加载失败
        // 此时设置slider值为0
        slider.value = 0;
    }
}

- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView progressSliderValueEnd:(UISlider *)sender
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
         self.isDragging = NO;
        // 视频总时间长度
        CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * sender.value);
        [self seekToTime:dragedSeconds completionHandler:nil];
    }
}

//MARK: Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (context == PlayViewStatusObservationContext)
    {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status) {
                case AVPlayerStatusUnknown:
                {
                    NSLog(@"AVPlayerStatus = AVPlayerStatusUnknown");
                }
                    break;
                case AVPlayerStatusReadyToPlay:
                {
                    NSLog(@"AVPlayerStatus = AVPlayerStatusReadyToPlay");
                    [self setNeedsLayout];
                    [self layoutIfNeeded];
                    // 添加playerLayer到self.layer
                    [self.layer insertSublayer:self.playerLayer atIndex:0];
                }
                    break;
                case AVPlayerStatusFailed:
                {
                    NSLog(@"AVPlayerStatus = AVPlayerStatusFailed");
                }
                    break;
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSLog(@"loadedTimeRanges = loadedTimeRanges");
            NSLog(@"---####%lld",playerItem.currentTime.value/playerItem.currentTime.timescale);
            NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
            CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            NSLog(@"playbackBufferEmpty = playbackBufferEmpty");
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
             NSLog(@"playbackLikelyToKeepUp = playbackLikelyToKeepUp");
        }
    }
}


@end
