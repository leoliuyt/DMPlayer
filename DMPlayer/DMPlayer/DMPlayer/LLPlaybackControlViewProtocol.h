//
//  LLPlaybackControlViewProtocol.h
//  DMPlayer
//
//  Created by lbq on 2018/1/18.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LLPlaybackControlDelegate;
@protocol LLPlaybackControlViewProtocol <NSObject>

@required

@property (nonatomic, weak) id<LLPlaybackControlDelegate> delegate;

@optional
// 修改播放状态
- (void)ll_controlChangePlayStatus:(BOOL)isPlaying;

// 修改全屏状态
- (void)ll_controlChangeFullStatus:(BOOL)isFull;

//设置时间
- (void)ll_controlPlayCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)aTotalTime sliderValue:(CGFloat)value;

//拖拽播放进度条
- (void)ll_controlDraggingTime:(NSInteger)draggingTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd;

//拖拽播放进度条结束
- (void)ll_controlDraggEnd;

//拖拽音量进度条
- (void)ll_controlDraggingVolume:(CGFloat)draggingVolume;

//添加UIPanGesture手势

- (void)ll_controlAddPanGesture;

//显示控制层
- (void)ll_controlPlayerShowControlView;

//隐藏控制层
- (void)ll_controlPlayerHideControlView;

- (void)ll_controlShowOrHideControlView;

//取消延时操作
- (void)ll_controlCancelAutoFadeOutControlView;


// configure progress max value
- (void)setProgressMaxValue:(CGFloat)aMaxValue;

// 更新播放进度条
- (void)updateProgress:(CGFloat)currentSecond;



//隐藏toolbar
- (void)hideToolBar:(BOOL)isHide animate:(BOOL)animated;

- (void)hideTopBar:(BOOL)isHide animate:(BOOL)animated;

- (void)hideBottomBar:(BOOL)isHide animate:(BOOL)animated;

@end
