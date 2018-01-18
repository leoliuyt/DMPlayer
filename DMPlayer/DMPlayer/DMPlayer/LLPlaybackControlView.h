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

@interface LLPlaybackControlView :UIView<LLPlaybackControlViewProtocol>

@property (nonatomic, assign) BOOL hideToolBar;//设置后直接隐藏

//MARK: LLPlaybackControlViewProtocol 方法
@property (nonatomic, weak) id<LLPlaybackControlDelegate> delegate;

- (void)changePlayStatus:(BOOL)play;

- (void)setProgressMaxValue:(CGFloat)aMaxValue;

- (void)setPlayCurrentTime:(NSString *)currentTime totalTime:(NSString *)aTotalTime;

- (void)updateProgress:(CGFloat)currentSecond;

//隐藏toolbar
- (void)hideToolBar:(BOOL)isHide animate:(BOOL)animated;

- (void)hideTopBar:(BOOL)isHide animate:(BOOL)animated;

- (void)hideBottomBar:(BOOL)isHide animate:(BOOL)animated;

@end

