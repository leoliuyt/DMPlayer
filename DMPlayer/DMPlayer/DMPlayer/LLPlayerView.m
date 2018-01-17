//
//  LLPlayerView.m
//  DMPlayer
//
//  Created by lbq on 2018/1/17.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import "LLPlayerView.h"
#import <Masonry.h>

static void *PlayViewStatusObservationContext = &PlayViewStatusObservationContext;

@interface LLPlayerView()
/** 播放属性 */
@property (nonatomic, strong) AVPlayer               *player;
@property (nonatomic, strong) AVPlayerItem           *playerItem;
@property (nonatomic, strong) AVURLAsset             *urlAsset;
@property (nonatomic, strong) AVAssetImageGenerator  *imageGenerator;
/** playerLayer */
@property (nonatomic, strong) AVPlayerLayer          *playerLayer;
@property (nonatomic, strong) NSURL                  *videoURL;
/** 视频填充模式 */
@property (nonatomic, copy) NSString                 *videoGravity;

@property (nonatomic, strong) id<NSObject> playbackTimeObserver;

/**
 *  跳到time处播放
 *  @param seekTime这个时刻，这个时间点
 */
@property (nonatomic, assign) double  seekTime;
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

/**
 *  设置Player相关参数
 */
- (void)configPlayer {
    self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
    // 初始化playerItem
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    // 初始化playerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.backgroundColor = [UIColor blackColor];
//    // 此处为默认视频填充模式
//    self.playerLayer.videoGravity = self.videoGravity;
//
//    // 自动播放
//    self.isAutoPlay = YES;
//
//    // 添加播放进度计时器
//    [self createTimer];
//
//    // 获取系统音量
//    [self configureVolume];
//
//    // 本地文件不设置ZFPlayerStateBuffering状态
//    if ([self.videoURL.scheme isEqualToString:@"file"]) {
//        self.state = ZFPlayerStatePlaying;
//        self.isLocalVideo = YES;
//        [self.controlView zf_playerDownloadBtnState:NO];
//    } else {
//        self.state = ZFPlayerStateBuffering;
//        self.isLocalVideo = NO;
//        [self.controlView zf_playerDownloadBtnState:YES];
//    }
//    // 开始播放
//    [self play];
//    self.isPauseByUser = NO;
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
    [self.player play];
}

- (void)pause
{
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

- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
//    __weak LLPlayerViewController *weakSelf = self;
    //要求在播放期间请求调用
    //CMTimeMake(1, 1) 每隔一秒调用一次block
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = CMTimeGetSeconds(playerItem.currentTime);// 计算当前在第几秒
//        [weakSelf updateVideoSlider:currentSecond];
//        NSString *timeString = [weakSelf convertTime:currentSecond];
//        if ([weakSelf.playbackControlView respondsToSelector:@selector(setPlayCurrentTime:totalTime:)]) {
//            [weakSelf.playbackControlView setPlayCurrentTime:timeString totalTime:weakSelf.totalTime];
//        }
    }];
}


- (void)moviePlayDidEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
//        [self updateVideoSlider:0.0];
//        [self.playbackControlView changePlayStatus:NO];
//        [self.player pause];
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
/**
 *  跳到time处播放
 *  @param seekTime这个时刻，这个时间点
 */
- (void)seekToTimeToPlay:(double)time{
    if (self.player&&self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if (time>[self duration]) {
            time = [self duration];
        }
        if (time<=0) {
            time=0.0;
        }
        //        int32_t timeScale = self.player.currentItem.asset.duration.timescale;
        //currentItem.asset.duration.timescale计算的时候严重堵塞主线程，慎用
        /* A timescale of 1 means you can only specify whole seconds to seek to. The timescale is the number of parts per second. Use 600 for video, as Apple recommends, since it is a product of the common video frame rates like 50, 60, 25 and 24 frames per second*/
        NSLog(@"######@@@@@##%tu",self.playerItem.currentTime.timescale);
        [self.player seekToTime:CMTimeMakeWithSeconds(time, self.playerItem.currentTime.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        }];
    }
}




//MARK: Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    if (context == PlayViewStatusObservationContext)
//    {
//        AVPlayerItem *playerItem = (AVPlayerItem *)object;
//        if ([keyPath isEqualToString:@"status"]) {
//            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
//            switch (status) {
//                    case AVPlayerStatusUnknown:
//                {
//
//                }
//                    break;
//                    case AVPlayerStatusReadyToPlay:
//                {
//                    CGFloat totalSecond = CMTimeGetSeconds(playerItem.duration);//获取视频总长度 并 转换成秒
//                    NSLog(@"####%f",totalSecond);
//                    self.totalTime = [self convertTime:totalSecond];// 转换成播放时间
//                    [self configureVideoSlider:totalSecond];
//                    [self monitoringPlayback:playerItem];// 监听播放状态
//                    [self.playbackControlView changePlayStatus:YES];
//                    if (self.seekTime) {
//                        [self seekToTimeToPlay:self.seekTime];
//                    }
//                }
//                    break;
//                    case AVPlayerStatusFailed:
//                {
//
//                }
//                    break;
//            }
//        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
//            NSLog(@"---####%lld",playerItem.currentTime.value/playerItem.currentTime.timescale);
//            NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
//            CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
//            if (timeInterval < currentSecond) {
//                //loading
//                [self startLoading];
//            }else{
//                //remove loading
//                [self stopLoading];
//            }
//        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
//            [self startLoading];
//            //            [self.loadingView startAnimating];
//            //            // 当缓冲是空的时候
//            //            if (self.currentItem.playbackBufferEmpty) {
//            //                self.state = WMPlayerStateBuffering;
//            //                [self loadedTimeRanges];
//            //            }
//        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
//            [self stopLoading];
//            //            [self.loadingView stopAnimating];
//            //            // 当缓冲好的时候
//            //            if (self.currentItem.playbackLikelyToKeepUp && self.state == WMPlayerStateBuffering){
//            //                self.state = WMPlayerStatePlaying;
//            //            }
//        }
//    }
}

//MARK: Setter
- (void)setPlayer:(AVPlayer *)player
{
    _player = player;
    self.player = player;
}

- (void)setContentURL:(NSURL *)contentURL
{
    _contentURL = contentURL;
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:contentURL];
    self.playerItem = playerItem;
    AVPlayer *aPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    self.player = aPlayer;
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
//    self.playerView.videoGravityType = videoGravityType;
}



@end
