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
#import "NSNumber+LL.h"

static CGFloat kPlayerTopToolHeight = 64; //标题和底部视图的高度
static CGFloat kPlayerBottomToolH = 40.; //标题和底部视图的高度

@interface LLPlayQuickView()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *quickImageView;
@property (nonatomic, strong) UILabel *quickLabel;

@end

@implementation LLPlayQuickView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self makeUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)makeUI
{
    self.backgroundColor = [UIColor clearColor];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    CGSize size = self.quickImageView.image.size;
    [self.quickImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10.);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(size);
    }];
    
    [self.quickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.quickImageView.mas_bottom).offset(8.);
        make.left.right.equalTo(self);
    }];
}

- (void)setQuickType:(EQuickType)quickType
{
    _quickType = quickType;
    self.quickImageView.image = quickType == EQuickTypeBackward ? [UIImage imageNamed:@"ll_player_backward"] : [UIImage imageNamed:@"ll_player_forward"];
}

- (void)setTimeStr:(NSString *)quickStr
{
    _timeStr = quickStr;
    self.quickLabel.text = quickStr;
}

- (UIView *)bgView
{
    if(!_bgView){
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [self addSubview:_bgView];
    }
    return _bgView;
}

- (UIImageView *)quickImageView
{
    if(!_quickImageView){
        _quickImageView = [[UIImageView alloc] init];
        _quickImageView.image = [UIImage imageNamed:@"ll_player_forward"];
        [self addSubview:_quickImageView];
    }
    return _quickImageView;
}

- (UILabel *)quickLabel
{
    if(!_quickLabel){
        _quickLabel = [[UILabel alloc] init];
        _quickLabel.font = [UIFont systemFontOfSize:12.];
        _quickLabel.textColor = [UIColor whiteColor];
        _quickLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_quickLabel];
    }
    return _quickLabel;
}
@end

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
@property (nonatomic, strong) LLPlayQuickView *quickView;
@property (nonatomic, assign) BOOL isDragging;

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
    
    [self addSubview:self.quickView];
    [self.quickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(110, 70));
        make.center.equalTo(self);
    }];
    
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
    self.playBtn.selected = play;
}

- (void)changeFullStatus:(BOOL)isFull
{
    self.fullBtn.selected = isFull;
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

- (void)progressSliderValueBegin:(UISlider *)sender
{
    if ([self.delegate respondsToSelector:@selector(controlView:progressSliderValueBegin:)]) {
        [self.delegate controlView:self progressSliderValueBegin:sender];
    }
}

- (void)progressSliderValueChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlView:progressSliderValueChanged:)]) {
        [self.delegate controlView:self progressSliderValueChanged:sender];
    }
}

- (void)progressSliderValueEnd:(id)sender {
    self.isDragging = NO;
    self.quickView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(controlView:progressSliderValueEnd:)]) {
        [self.delegate controlView:self progressSliderValueEnd:sender];
    }
}

- (void)fullAction:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(controlView:didClickFullScreenAction:)]) {
        [self.delegate controlView:self didClickFullScreenAction:btn];
    }
}

- (void)downLoadAction:(UIButton *)btn
{
    if([self.delegate respondsToSelector:@selector(controlView:didClickDownloadAction:)]) {
        [self.delegate controlView:self didClickDownloadAction:btn];
    }
}

//MARK: LLPlaybackControlViewProtocol

- (void)setPlayCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)aTotalTime sliderValue:(CGFloat)value;
{
    if (!self.isDragging) {
        self.progressSlider.value = value;
    }
    self.currentTimeLabel.text = [@(currentTime) ll_secondFormatter];
    self.totalTimeLabel.text = [@(aTotalTime) ll_secondFormatter];
}

- (void)draggingTime:(NSInteger)draggingTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd{
    // 快进快退时候停止菊花
    self.isDragging = YES;
    self.quickView.hidden = NO;
    self.quickView.quickType = forawrd ? EQuickTypeForward : EQuickTypeBackward;
    NSString *currentTimeStr = [@(draggingTime) ll_secondFormatter];
    NSString *totalTimeStr   = [@(totalTime) ll_secondFormatter];
    NSString *timeStr = [NSString stringWithFormat:@"%@/%@",currentTimeStr,totalTimeStr];
    CGFloat  draggedValue    = (CGFloat)draggingTime/(CGFloat)totalTime;
    self.currentTimeLabel.text = currentTimeStr;
    self.totalTimeLabel.text = totalTimeStr;
    self.progressSlider.value = draggedValue;
    self.quickView.timeStr = timeStr;
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
        [_playBtn setImage:[UIImage imageNamed:@"ll_player_pause"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"ll_player_play"] forState:UIControlStateSelected];
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
        // slider开始滑动事件
        [_progressSlider addTarget:self action:@selector(progressSliderValueBegin:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_progressSlider addTarget:self action:@selector(progressSliderValueEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
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

- (LLPlayQuickView *)quickView
{
    if(!_quickView){
        _quickView = [[LLPlayQuickView alloc] initWithFrame:CGRectMake(0, 0, 110, 70)];
        _quickView.layer.cornerRadius = 3;
        _quickView.layer.masksToBounds = YES;
        _quickView.hidden = YES;
    }
    return _quickView;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
