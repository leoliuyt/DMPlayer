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

//播放完毕 重新播放
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView didClickRepeatPlayAction:(UIButton *)sender;

//加载失败 点击重试
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView didClickFailPlayAction:(UIButton *)sender;

//全屏 小屏
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView didClickFullScreenAction:(UIButton *)sender;

//退出
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView didClickBackAction:(id)sender;

//下载
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView didClickDownloadAction:(id)sender;

//播放进度相关
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView progressSliderValueBegin:(UISlider *)sender;

- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView progressSliderValueChanged:(UISlider *)sender;

- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView progressSliderValueEnd:(UISlider *)sender;

//音量进度相关
- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView volumeSliderValueBegin:(UISlider *)sender;

- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView volumeSliderValueChanged:(UISlider *)sender;

- (void)controlView:(UIView<LLPlaybackControlViewProtocol> *)controlView volumeSliderValueEnd:(UISlider *)sender;

//收拾 快进 快退
//- (void)quickType:(EQuickType)quickType timeStr:(NSString *)timeStr;

@end
