//
//  LLPlaybackControlView.h
//  DMPlayer
//
//  Created by lbq on 2018/1/17.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLPlaybackControlViewProtocol.h"
#import "LLPlaybackControlDelegate.h"
typedef NS_ENUM(NSUInteger, EQuickType) {
    EQuickTypeForward,
    EQuickTypeBackward
};

@interface LLPlaybackControlView :UIView<LLPlaybackControlViewProtocol>

@property (nonatomic, assign) BOOL hideToolBar;//设置后直接隐藏

//MARK: LLPlaybackControlViewProtocol 方法
@property (nonatomic, weak) id<LLPlaybackControlDelegate> delegate;

//修改播放按钮状态
- (void)ll_controlChangePlayStatus:(BOOL)play;

// 修改全屏状态
- (void)ll_controlChangeFullStatus:(BOOL)isFull;

- (void)ll_controlPlayCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)aTotalTime sliderValue:(CGFloat)value;

- (void)ll_controlDraggingTime:(NSInteger)draggingTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd;

- (void)ll_controlDraggEnd;

- (void)ll_controlDraggingVolume:(CGFloat)draggingVolume;

- (void)ll_controlShowControlView;
- (void)ll_controlHideControlView;
- (void)ll_controlShowOrHideControlView;

- (void)ll_controlCancelAutoFadeOutControlView;

//加载的菊花
- (void)ll_controlActivity:(BOOL)animated;

- (void)ll_controlPlayEnd;


- (void)setProgressMaxValue:(CGFloat)aMaxValue;

- (void)updateProgress:(CGFloat)currentSecond;

//隐藏toolbar
- (void)hideToolBar:(BOOL)isHide animate:(BOOL)animated;

- (void)hideTopBar:(BOOL)isHide animate:(BOOL)animated;

- (void)hideBottomBar:(BOOL)isHide animate:(BOOL)animated;

@end

@interface LLPlayQuickView :UIView
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, assign) EQuickType quickType;
@end
