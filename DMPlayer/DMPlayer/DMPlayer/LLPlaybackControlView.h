//
//  LLPlaybackControlView.h
//  DMPlayer
//
//  Created by lbq on 2018/1/17.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLPlaybackControlProtocol.h"

@interface LLPlaybackControlView :UIView<LLPlaybackControlViewProtocol>

@property (nonatomic, strong) UIButton *centerPlayBtn;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *pauseBtn;
@property (nonatomic, strong) UIButton *fullBtn;
@property (nonatomic, strong) UIButton *shrinkBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UISlider *progressSlider;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, assign) BOOL hideToolBar;//设置后直接隐藏

//MARK: LLPlaybackControlViewProtocol 方法
@property (nonatomic, weak) id<LLPlaybackControlProtocol> delegate;

- (void)changePlayStatus:(BOOL)play;

- (void)setProgressMaxValue:(CGFloat)aMaxValue;

- (void)setPlayCurrentTime:(NSString *)currentTime totalTime:(NSString *)aTotalTime;

- (void)updateProgress:(CGFloat)currentSecond;

//隐藏toolbar
- (void)hideToolBar:(BOOL)isHide animate:(BOOL)animated;

- (void)hideTopBar:(BOOL)isHide animate:(BOOL)animated;

- (void)hideBottomBar:(BOOL)isHide animate:(BOOL)animated;

@end

