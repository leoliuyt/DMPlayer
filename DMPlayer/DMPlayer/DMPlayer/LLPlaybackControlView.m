//
//  LLPlaybackControlView.m
//  DMPlayer
//
//  Created by lbq on 2018/1/17.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import "LLPlaybackControlView.h"
#import <Masonry.h>
#import "LLPlayerConfigure.h"

static CGFloat kToolHeight = 248; //标题和底部视图的高度

@interface LLPlaybackControlView()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIImageView *topBgImageView;
@property (nonatomic, strong) UIImageView *bottomBgImageView;

@end

@implementation LLPlaybackControlView

- (instancetype)init
{
    self = [super init];
    self.backgroundColor = [UIColor clearColor];
    [self makeUI];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self makeUI];
    return self;
}

- (void)makeUI
{
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@(kToolHeight));
    }];
    
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@(kToolHeight));
    }];
    
    [self.topView addSubview:self.topBgImageView];
    [self.topBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.topView);
    }];
    
    [self.topView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).offset(10.);
        make.top.equalTo(self.topView).offset(20.);
        make.width.height.equalTo(@44.);
    }];
    
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backBtn.mas_right).offset(10.);
        make.top.bottom.right.equalTo(self.topView);
    }];
    
    [self.bottomView addSubview:self.bottomBgImageView];
    [self.bottomBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bottomView);
    }];
    [self.bottomView addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(0.);
        make.bottom.equalTo(self.bottomView).offset(-10.);
        make.width.height.equalTo(@44.);
    }];
    
    [self.bottomView addSubview:self.pauseBtn];
    [self.pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(0.);
        make.bottom.equalTo(self.bottomView).offset(-10.);
        make.width.height.equalTo(@44.);
    }];
    
    //    [self.bottomView addSubview:self.fullBtn];
    //    [self.fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.right.top.bottom.equalTo(self.bottomView);
    //        make.width.equalTo(kToolHeight);
    //    }];
    //
    //    [self.bottomView addSubview:self.shrinkBtn];
    //    [self.shrinkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.right.top.bottom.equalTo(self.bottomView);
    //        make.width.equalTo(kToolHeight);
    //    }];
    
    [self.bottomView addSubview:self.progressSlider];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playBtn.mas_right).offset(5.);
        make.right.equalTo(self.bottomView).offset(-95.);
        make.centerY.equalTo(self.playBtn);
        make.height.equalTo(@20.);
    }];
    
    [self.bottomView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-10.);
        make.centerY.equalTo(self.playBtn);
        make.width.equalTo(@80.);
        make.height.equalTo(@20.);
    }];
    
    [self addSubview:self.centerPlayBtn];
    [self.centerPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (void)changePlayStatus:(BOOL)play
{
    if (play) {
        self.playBtn.hidden = YES;
        self.pauseBtn.hidden = NO;
        self.centerPlayBtn.alpha = 0;
    } else {
        self.playBtn.hidden = NO;
        self.pauseBtn.hidden = YES;
        self.centerPlayBtn.alpha = 1;
    }
}

//- (void)changeFullStatus:(BOOL)full
//{
//    if (full) {
//        self.fullBtn.hidden = YES;
//        self.shrinkBtn.hidden = NO;
//    } else {
//        self.fullBtn.hidden = NO;
//        self.shrinkBtn.hidden = YES;
//    }
//}

//MARK: buton Action
- (void)playAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didClickPlayAction:)]) {
        [self.delegate didClickPlayAction:sender];
        [self changePlayStatus:YES];
    }
}

- (void)pauseAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didClickPauseAction:)]) {
        [self.delegate didClickPauseAction:sender];
        [self changePlayStatus:NO];
    }
}

//- (void)fullAction:(id)sender
//{
//    if ([self.delegate respondsToSelector:@selector(didClickFullScreenAction:)]) {
//        [self.delegate didClickFullScreenAction:sender];
//        [self changeFullStatus:YES];
//    }
//}
//
//- (void)shrinkAction:(id)sender
//{
//    if ([self.delegate respondsToSelector:@selector(didClickShrinkScreenAction:)]) {
//        [self.delegate didClickShrinkScreenAction:sender];
//        [self changeFullStatus:NO];
//    }
//}

- (void)backAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didClickBackAction:)]) {
        [self.delegate didClickBackAction:sender];
    }
}

- (void)progressSliderValueChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(progressSliderValueChanged:)]) {
        [self.delegate progressSliderValueChanged:sender];
    }
}

- (void)progressSliderValueChangedEnd:(id)sender {
    if ([self.delegate respondsToSelector:@selector(progressSliderValueChangedEnd:)]) {
        [self.delegate progressSliderValueChangedEnd:sender];
    }
}

//收拾 快进 快退
- (void)quickType:(EQuickType)quickType timeStr:(NSString *)timeStr
{
    
}

//MARK: LLPlaybackControlViewProtocol
- (void)setProgressMaxValue:(CGFloat)aMaxValue
{
    self.progressSlider.maximumValue = aMaxValue;
}

-(void)setPlayCurrentTime:(NSString *)currentTime totalTime:(NSString *)aTotalTime
{
    NSString *str = [NSString stringWithFormat:@"%@/%@",currentTime,aTotalTime];
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:str];
    //    [attri addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange([currentTime length], [aTotalTime length] + 1)];
    [attri addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0,str.length)];
    self.timeLabel.attributedText = attri;
}

- (void)updateProgress:(CGFloat)currentSecond
{
    [self.progressSlider setValue:currentSecond animated:YES];
}

//隐藏toolbar
- (void)hideToolBar:(BOOL)isHide animate:(BOOL)animated
{
    if (self.hideToolBar) {
        return;
    }
    CGFloat duration = animated ? 0.5 : 0.0;
    [UIView animateWithDuration:duration  animations:^{
        self.topView.alpha = isHide ? 0. : 1.;
        self.bottomView.alpha = isHide ? 0. : 1.;
    }];
}

- (void)hideTopBar:(BOOL)isHide animate:(BOOL)animated
{
    if (self.hideToolBar) {
        return;
    }
    CGFloat duration = animated ? 0.5 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.topView.alpha = isHide ? 0. : 1.;
    }];
}

- (void)hideBottomBar:(BOOL)isHide animate:(BOOL)animated
{
    if (self.hideToolBar) {
        return;
    }
    CGFloat duration = animated ? 0.5 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.bottomView.alpha = isHide ? 0. : 1.;
        self.centerPlayBtn.alpha = isHide ? 0. : 1.;
    }];
}

- (void)setHideToolBar:(BOOL)hideToolBar
{
    _hideToolBar = hideToolBar;
    self.topView.hidden = YES;
    self.bottomView.hidden = YES;
}

//MARK:lazy
- (UIView *)topView
{
    if(!_topView){
        _topView = [[UIView alloc] init];
        //        _topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _topView.backgroundColor = [UIColor clearColor];
    }
    return _topView;
}

- (UIView *)bottomView
{
    if(!_bottomView){
        _bottomView = [[UIView alloc] init];
        //        _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _bottomView.backgroundColor = [UIColor clearColor];
    }
    return _bottomView;
}

- (UIImageView *)bottomBgImageView
{
    if(!_bottomBgImageView){
        _bottomBgImageView = [[UIImageView alloc] init];
        _bottomBgImageView.image = [UIImage imageNamed:LLPlayerSrcName(@"ll_player_bottom_mask")];
        _bottomBgImageView.userInteractionEnabled = YES;
        [self.bottomView addSubview:_bottomBgImageView];
    }
    return _bottomBgImageView;
}

- (UIImageView *)topBgImageView
{
    if(!_topBgImageView){
        _topBgImageView = [[UIImageView alloc] init];
        _topBgImageView.image = [UIImage imageNamed:LLPlayerSrcName(@"ll_player_top_mask")];
        _topBgImageView.userInteractionEnabled = YES;
        [self.topView addSubview:_topBgImageView];
    }
    return _topBgImageView;
}

- (UIButton *)backBtn
{
    if(!_backBtn){
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:LLPlayerSrcName(@"ll_player_close")] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)playBtn
{
    if(!_playBtn){
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:LLPlayerSrcName(@"ll_player_play")] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)pauseBtn
{
    if(!_pauseBtn){
        _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseBtn setImage:[UIImage imageNamed:LLPlayerSrcName(@"ll_player_pause")] forState:UIControlStateNormal];
        [_pauseBtn addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
        _pauseBtn.hidden = YES;
    }
    return _pauseBtn;
}

//- (UIButton *)fullBtn
//{
//    if(!_fullBtn){
//        _fullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_fullBtn setImage:[UIImage imageNamed:LLPlayerSrcName(@"kr-video-player-fullscreen")] forState:UIControlStateNormal];
//         [_fullBtn addTarget:self action:@selector(fullAction:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _fullBtn;
//}
//
//- (UIButton *)shrinkBtn
//{
//    if(!_shrinkBtn){
//        _shrinkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_shrinkBtn setImage:[UIImage imageNamed:LLPlayerSrcName(@"kr-video-player-shrinkscreen")] forState:UIControlStateNormal];
//        [_shrinkBtn addTarget:self action:@selector(shrinkAction:) forControlEvents:UIControlEventTouchUpInside];
//        _shrinkBtn.hidden = YES;
//    }
//    return _shrinkBtn;
//}

- (UILabel *)titleLabel
{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UISlider *)progressSlider
{
    if(!_progressSlider){
        _progressSlider = [[UISlider alloc] init];
        //        [_progressSlider setMinimumTrackImage:[UIImage imageNamed:LLPlayerSrcName(@"icon_player_progress")] forState:UIControlStateNormal];
        //        [_progressSlider setMaximumTrackImage:[UIImage imageNamed:LLPlayerSrcName(@"icon_player_backprogress")] forState:UIControlStateNormal];
        //        [_progressSlider setThumbImage:[UIImage imageNamed:LLPlayerSrcName(@"icon_audio_thumail")] forState:UIControlStateNormal];
//        _progressSlider.minimumTrackTintColor = [UIColor colorWithRGBHex:0x31bd77 alpha:0.7];
//        _progressSlider.maximumTrackTintColor = [UIColor colorWithRGBHex:0xffffff alpha:0.5];
        //        _progressSlider.minimumTrackTintColor = [UIColor colorWithHexString:0x31bd77 alpha:0.7];
        //        _progressSlider.minimumTrackTintColor = [UIColor art_ornament];
        //        _progressSlider.maximumTrackTintColor = [UIColor colorWithHexString:@"ffffff" alpha:0.5];
        [_progressSlider setThumbImage:[UIImage imageNamed:LLPlayerSrcName(@"ll_player_progress_dot")] forState:UIControlStateNormal];
        [_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(progressSliderValueChangedEnd:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _progressSlider;
}

- (UILabel *)timeLabel
{
    if(!_timeLabel){
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:12.];
    }
    return _timeLabel;
}

- (UIButton *)centerPlayBtn
{
    if(!_centerPlayBtn){
        _centerPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_centerPlayBtn setImage:[UIImage imageNamed:LLPlayerSrcName(@"ll_player_play_center")] forState:UIControlStateNormal];
        [_centerPlayBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _centerPlayBtn;
}
- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end