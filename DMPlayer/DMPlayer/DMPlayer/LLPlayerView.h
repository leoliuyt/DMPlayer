//
//  LLPlayerView.h
//  DMPlayer
//
//  Created by lbq on 2018/1/17.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LLPlayerModelProtocol.h"
#import "LLPlaybackControlViewProtocol.h"

typedef NS_ENUM(NSUInteger, ELayerVideoGravityType) {
    ELayerVideoGravityTypeResize,
    ELayerVideoGravityTypeResizeAspectFill,
    ELayerVideoGravityTypeResizeAspect
};

typedef NS_ENUM(NSUInteger, EPlayerState) {
    EPlayerStateFailed,     //播放失败
    EPlayerStateBuffering,  //缓冲中
    EPlayerStatePlaying,    //播放中
    EPlayerStatePause,      //暂停播放
    EPlayerStateStopped,    //停止播放
};

@interface LLPlayerView : UIView
// 视频显示模式 类似图片的ContentMode
@property (nonatomic, assign) ELayerVideoGravityType videoGravityType;
@property (nonatomic, assign, readonly) EPlayerState playState; //播放状态
@property (nonatomic, assign) BOOL disablePanGesture;//各种进度手势（音量、亮度、快进快退）
@property (nonatomic, assign) BOOL mute;//静音
//视频链接 可以是本地路径URL
@property (nonatomic, strong) NSURL *contentURL;

/**
 * 指定播放的控制层和模型
 * 控制层传nil，默认使用PlaybackControlView(如自定义可传自定义的控制层)
 */
- (void)playerControlView:(id<LLPlaybackControlViewProtocol>)controlView playerModel:(id<LLPlayerModelProtocol>)playerModel;
@end
