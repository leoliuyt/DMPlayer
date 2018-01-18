//
//  LLPlaybackControlDelegate.h
//  DMPlayer
//
//  Created by lbq on 2018/1/18.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol LLPlaybackControlViewProtocol;
@protocol LLPlaybackControlDelegate <NSObject>
@optional
//播放 暂停
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView didClickPlayAction:(UIButton *)sender;
//全屏 小屏
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView didClickFullScreenAction:(UIButton *)sender;

//退出
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView didClickBackAction:(id)sender;

//播放进度相关
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView progressSliderValueChanged:(id)sender;

- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView progressSliderValueChangedEnd:(id)sender;

//收拾 快进 快退
//- (void)quickType:(EQuickType)quickType timeStr:(NSString *)timeStr;

@end
