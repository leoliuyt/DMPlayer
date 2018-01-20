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
#import <MediaPlayer/MediaPlayer.h>

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, EPanDirection){
    EPanDirectionHorizontal, // 横向移动
    EPanDirectionVertical    // 纵向移动
};


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

@property (nonatomic, assign) BOOL muted;//静音

//滑动控制
@property (nonatomic, assign) EPanDirection panDirection;
@property (nonatomic, assign) CGFloat sumTime;
@property (nonatomic, assign) BOOL isVolume;
@property (nonatomic, strong) UISlider *volumeViewSlider;
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
    
    [self createGesture];
}

/**
 *  获取系统音量
 */
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    self.volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
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
    
    [self configureVolume];
    
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
    [self.controlView ll_controlChangePlayStatus:YES];
    [self.player play];
}

- (void)pause
{
    [self.controlView ll_controlChangePlayStatus:NO];
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
            [weakSelf.controlView ll_controlPlayCurrentTime:currentTime totalTime:totalTime sliderValue:value];
        }
    }];
}

- (void)moviePlayDidEnd:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.controlView ll_controlChangePlayStatus:NO];
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

/**
 *  创建手势
 */
- (void)createGesture {
    // 单击
    self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapGestureAction:)];
    self.singleTap.delegate                = self;
    self.singleTap.numberOfTouchesRequired = 1; //手指数
    self.singleTap.numberOfTapsRequired    = 1;
    [self addGestureRecognizer:self.singleTap];
}


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
            [weakSelf play];
            weakSelf.seekTime = 0;
//            weakSelf.isDragged = NO;
            // 结束滑动
//            [weakSelf.controlView zf_playerDraggedEnd];
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp && !weakSelf.isLocalVideo) { weakSelf.playState = EPlayerStateBuffering; }
        }];
    }
}


/**
 *  pan垂直移动的方法
 *
 *  @param value void
 */
- (void)verticalMoved:(CGFloat)value {
    if (self.isVolume) {
        self.volumeViewSlider.value -= value/10000;
        [self.controlView ll_controlDraggingVolume:self.volumeViewSlider.value];
    } else {
        [UIScreen mainScreen].brightness -= value/10000;
    }
}

/**
 *  pan水平移动的方法
 *
 *  @param value void
 */
- (void)horizontalMoved:(CGFloat)value {
    // 每次滑动需要叠加时间
    self.sumTime += value / 200;
    // 需要限定sumTime的范围
    CMTime totalTime           = self.playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.sumTime > totalMovieDuration) { self.sumTime = totalMovieDuration;}
    if (self.sumTime < 0) { self.sumTime = 0; }
    
    BOOL style = false;
    if (value > 0) { style = YES; }
    if (value < 0) { style = NO; }
    if (value == 0) { return; }
    
    self.isDragging = YES;
    [self.controlView ll_controlDraggingTime:self.sumTime totalTime:totalMovieDuration isForward:style];
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

- (void)panGestureAction:(UIPanGestureRecognizer *)gesture
{
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [gesture locationInView:self];
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [gesture velocityInView:self];

    // 判断是垂直移动还是水平移动
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: { // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                // 取消隐藏
                self.panDirection = EPanDirectionHorizontal;
                // 给sumTime初值
                CMTime time       = self.player.currentTime;
                self.sumTime      = time.value/time.timescale;
            } else if (x < y) { // 垂直移动
                self.panDirection = EPanDirectionVertical;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else { // 状态改为显示亮度调节
                    self.isVolume = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged: { // 正在移动
            switch (self.panDirection) {
                case EPanDirectionHorizontal:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case EPanDirectionVertical:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: { // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case EPanDirectionHorizontal:{
//                    self.isPauseByUser = NO;
                    [self.controlView ll_controlDraggEnd];
                    [self seekToTime:self.sumTime completionHandler:nil];
                    // 把sumTime滞空，不然会越加越多
                    self.sumTime = 0;
                    break;
                }
                case EPanDirectionVertical:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)singleTapGestureAction:(UITapGestureRecognizer *)gesture
{
     [self.controlView ll_controlShowOrHideControlView];
}


//MARK: UIGestureDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    return YES;
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
        CGFloat totalTime     = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
        //计算出拖动的当前秒数
        CGFloat dragedSeconds = floorf(totalTime * slider.value);
        if (totalTime > 0) { // 当总时长 > 0时候才能拖动slider
            [controlView ll_controlDraggingTime:dragedSeconds totalTime:totalTime isForward:style];
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
        CGFloat total           = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * sender.value);
        [self.controlView ll_controlDraggEnd];
        [self seekToTime:dragedSeconds completionHandler:nil];
    }
}

- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView volumeSliderValueBegin:(UISlider *)sender
{
    
}

- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView volumeSliderValueChanged:(UISlider *)sender
{
    self.volumeViewSlider.value = sender.value;
}

- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView volumeSliderValueEnd:(UISlider *)sender
{
    
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
                    // 加载完成后，再添加平移手势
                    if (!self.disablePanGesture) {
                        // 添加平移手势，用来控制音量、亮度、快进快退
                        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
                        panRecognizer.delegate = self;
                        [panRecognizer setMaximumNumberOfTouches:1];
                        [panRecognizer setDelaysTouchesBegan:YES];
                        [panRecognizer setDelaysTouchesEnded:YES];
                        [panRecognizer setCancelsTouchesInView:YES];
                        [self addGestureRecognizer:panRecognizer];
                    }
                    
                    CGFloat totalDuration = self.playerItem.duration.value / self.playerItem.duration.timescale;
                    //设置初始值
                    [self.controlView ll_controlPlayCurrentTime:0 totalTime:totalDuration sliderValue:0];
                    // 跳到xx秒播放视频
                    if (self.seekTime) {
                        [self seekToTime:self.seekTime completionHandler:nil];
                    }
                    self.player.muted = self.mute;
                    //设置音量初始值
                    [self.controlView ll_controlDraggingVolume:self.volumeViewSlider.value];
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
