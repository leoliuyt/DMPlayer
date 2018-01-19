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
- (void)changePlayStatus:(BOOL)isPlaying;

// 修改全屏状态
- (void)changeFullStatus:(BOOL)isFull;

//设置时间
- (void)setPlayCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)aTotalTime sliderValue:(CGFloat)value;

//拖拽播放进度条
- (void)draggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd;

// configure progress max value
- (void)setProgressMaxValue:(CGFloat)aMaxValue;

// 更新播放进度条
- (void)updateProgress:(CGFloat)currentSecond;

//隐藏toolbar
- (void)hideToolBar:(BOOL)isHide animate:(BOOL)animated;

- (void)hideTopBar:(BOOL)isHide animate:(BOOL)animated;

- (void)hideBottomBar:(BOOL)isHide animate:(BOOL)animated;

@end
