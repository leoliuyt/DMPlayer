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
#import "UIColor+LL.h"

static CGFloat kPlayerTopToolHeight = 64; //标题和底部视图的高度
static CGFloat kPlayerBottomToolH = 40.; //标题和底部视图的高度

@interface LLPlaybackControlView()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIImageView *topBgImageView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *bottomBgImageView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *fullBtn;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UIButton *downBtn;

@property (nonatomic, strong) UIButton *centerPlayBtn;

@end

@implementation LLPlaybackControlView

- (instancetype)init
{
    self = [super init];
    self.backgroundColor = [UIColor clearColor];
    [self makeUI];
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation == UIDeviceOrientationPortrait) {
        [self setOrientationPortraitConstraint];
    } else {
        [self setOrientationLandscapeConstraint];
    }
}

- (void)makeUI
{
    //topview UI
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@(kPlayerTopToolHeight));
    }];
    
    //顶部阴影
    [self.topView addSubview:self.topBgImageView];
    [self.topBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.topView);
    }];
    
    //返回
    [self.topView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).offset(20.);
        make.top.equalTo(self.topView).offset(20.);
        make.width.height.equalTo(@40.);
    }];
    
    //title
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backBtn.mas_right).offset(10.);
        make.top.bottom.right.equalTo(self.topView);
    }];
    
    //bottomview UI
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@(kPlayerBottomToolH));
    }];
    
     //底部阴影
    [self.bottomView addSubview:self.bottomBgImageView];
    [self.bottomBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bottomView);
    }];
    
    //play pause
    [self.bottomView addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView);
        make.centerY.equalTo(self.bottomView);
        make.width.equalTo(@44.);
        make.height.equalTo(@(kPlayerBottomToolH));
    }];
    
    //全屏 小屏
    [self.bottomView addSubview:self.fullBtn];
    [self.fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView);
        make.centerY.equalTo(self.bottomView);
        make.width.equalTo(@(44.));
        make.height.equalTo(@(kPlayerBottomToolH));
    }];

    //进度条
    [self.bottomView addSubview:self.progressSlider];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playBtn.mas_right);
        make.right.equalTo(self.fullBtn.mas_left);
        make.centerY.equalTo(self.bottomView).offset(-7.);
        make.height.equalTo(@20.);
    }];
    
    //时间
    [self.bottomView addSubview:self.currentTimeLabel];
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressSlider);
        make.centerY.equalTo(self.bottomView).offset(6.);
    }];
    
    //时间
    [self.bottomView addSubview:self.totalTimeLabel];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.progressSlider);
        make.centerY.equalTo(self.bottomView).offset(6.);
    }];
    
    [self.bottomView addSubview:self.downBtn];
    
    [self.currentTimeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh+1 forAxis:UILayoutConstraintAxisHorizontal];
    [self.totalTimeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh+1 forAxis:UILayoutConstraintAxisHorizontal];
    [self.currentTimeLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh+1 forAxis:UILayoutConstraintAxisHorizontal];
    [self.totalTimeLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh+1 forAxis:UILayoutConstraintAxisHorizontal];
    
//    [self addSubview:self.centerPlayBtn];
//    [self.centerPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self);
//    }];
}

- (void)setOrientationLandscapeConstraint {
    [self.playBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(3.);
    }];
    
    [self.fullBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-3.);
    }];
    
    [self.currentTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playBtn.mas_right).offset(3.);
        make.centerY.equalTo(self.bottomView);
    }];
    
    [self.downBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.width.equalTo(@36.);
        make.height.equalTo(@20.);
        make.right.equalTo(self.fullBtn.mas_left).offset(-7.);
    }];
    
    [self.totalTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.downBtn.mas_left).offset(-15.);
        make.centerY.equalTo(self.bottomView);
    }];
    
    [self.progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(10.);
        make.right.equalTo(self.totalTimeLabel.mas_left).offset(-10.);
        make.centerY.equalTo(self.bottomView);
        make.height.equalTo(@20.);
    }];
    
    self.downBtn.hidden = NO;
}

- (void)setOrientationPortraitConstraint {
    self.downBtn.hidden = YES;
    //删除约束
    [self.downBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
    }];
    
    [self.playBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(0.);
    }];
    
    [self.fullBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(0.);
    }];
    
    [self.progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playBtn.mas_right);
        make.right.equalTo(self.fullBtn.mas_left);
        make.centerY.equalTo(self.bottomView).offset(-7.);
        make.height.equalTo(@20.);
    }];
    
    [self.currentTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressSlider);
         make.centerY.equalTo(self.bottomView).offset(6.);
    }];
    
    [self.totalTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.progressSlider);
        make.centerY.equalTo(self.bottomView).offset(6.);
    }];
}

- (void)changePlayStatus:(BOOL)play
{
    if (play) {
        self.playBtn.hidden = YES;
        self.centerPlayBtn.alpha = 0;
    } else {
        self.playBtn.hidden = NO;
        self.centerPlayBtn.alpha = 1;
    }
}

//MARK: buton Action

- (void)backAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(controlView:didClickBackAction:)]) {
        [self.delegate controlView:self didClickBackAction:sender];
    }
}

- (void)playAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(controlView:didClickPlayAction:)]) {
        [self.delegate controlView:self didClickPlayAction:sender];
    }
}

- (void)progressSliderValueChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlView:progressSliderValueChanged:)]) {
        [self.delegate controlView:self progressSliderValueChanged:sender];
    }
}

- (void)progressSliderValueChangedEnd:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlView:progressSliderValueChangedEnd:)]) {
        [self.delegate controlView:self progressSliderValueChangedEnd:sender];
    }
}

- (void)fullAction:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(controlView:didClickFullScreenAction:)]) {
        [self.delegate controlView:self didClickFullScreenAction:btn];
    }
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
//    self.timeLabel.attributedText = attri;
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
        _topView.backgroundColor = [UIColor clearColor];
    }
    return _topView;
}

- (UIView *)bottomView
{
    if(!_bottomView){
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor clearColor];
    }
    return _bottomView;
}

- (UIImageView *)bottomBgImageView
{
    if(!_bottomBgImageView){
        _bottomBgImageView = [[UIImageView alloc] init];
//        _bottomBgImageView.image = [UIImage imageNamed:@"ll_player_bottom_shadow"];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        _bottomBgImageView.userInteractionEnabled = YES;
        [self.bottomView addSubview:_bottomBgImageView];
    }
    return _bottomBgImageView;
}

- (UIImageView *)topBgImageView
{
    if(!_topBgImageView){
        _topBgImageView = [[UIImageView alloc] init];
//        _topBgImageView.image = [UIImage imageNamed:@"ll_player_top_shadow"];
//        _topBgImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _topBgImageView.userInteractionEnabled = YES;
        [self.topView addSubview:_topBgImageView];
    }
    return _topBgImageView;
}

- (UIButton *)backBtn
{
    if(!_backBtn){
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)playBtn
{
    if(!_playBtn){
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"ll_player_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"ll_player_pause"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)fullBtn
{
    if(!_fullBtn){
        _fullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullBtn setImage:[UIImage imageNamed:@"ll_player_fullscreen"] forState:UIControlStateNormal];
        [_fullBtn setImage:[UIImage imageNamed:@"ll_player_shrinkscreen"] forState:UIControlStateSelected];
         [_fullBtn addTarget:self action:@selector(fullAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullBtn;
}

- (UIButton *)downBtn
{
    if(!_downBtn){
        _downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downBtn setImage:[UIImage imageNamed:@"ll_player_download"] forState:UIControlStateNormal];
        [_downBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
        [_downBtn addTarget:self action:@selector(downLoadAction:) forControlEvents:UIControlEventTouchUpInside];
        _downBtn.hidden = YES;
    }
    return _downBtn;
}

- (UILabel *)titleLabel
{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.hidden = YES;
    }
    return _titleLabel;
}

- (UISlider *)progressSlider
{
    if(!_progressSlider){
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"ll_player_point"] forState:UIControlStateNormal];
        _progressSlider.minimumTrackTintColor = [UIColor ll_colorWithHexString:@"E2368E"];
        _progressSlider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.3];
        _progressSlider.value = 0.f;
        _progressSlider.continuous = YES;
        [_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(progressSliderValueChangedEnd:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _progressSlider;
}

- (UILabel *)totalTimeLabel
{
    if(!_totalTimeLabel){
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textAlignment = NSTextAlignmentRight;
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12.];
        _totalTimeLabel.text = @"00:10:03";
    }
    return _totalTimeLabel;
}

- (UILabel *)currentTimeLabel
{
    if(!_currentTimeLabel){
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12.];
        _currentTimeLabel.text = @"00:05:03";
    }
    return _currentTimeLabel;
}

- (UIButton *)centerPlayBtn
{
    if(!_centerPlayBtn){
        _centerPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_centerPlayBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_centerPlayBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _centerPlayBtn;
}
- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
