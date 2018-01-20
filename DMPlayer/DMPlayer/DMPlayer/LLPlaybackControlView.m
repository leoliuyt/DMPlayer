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
#import <MMMaterialDesignSpinner.h>

static const CGFloat kPlayerAnimationTimeInterval             = 7.0f;
static const CGFloat kPlayerControlBarAutoFadeOutTimeInterval = 0.35f;

static const CGFloat kPlayerTopToolHeight = 64; //标题和底部视图的高度
static const CGFloat kPlayerBottomToolH = 40.; //标题和底部视图的高度
static const CGFloat kPlayerRightToolH = 243.; //右部视图的高度
static const CGFloat kPlayerVolumeBtnH = 38.; //右部视图的高度

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

@interface LLPlaybackControlView()<UIGestureRecognizerDelegate>

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

@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIImageView *rightBgImageView;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UIButton *volumeBtn;

@property (nonatomic, strong) UIButton *centerPlayBtn;
@property (nonatomic, strong) LLPlayQuickView *quickView;
@property (nonatomic, assign) BOOL isDragging;

@property (nonatomic, assign) BOOL showing;
@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, strong) MMMaterialDesignSpinner *activity;
@property (nonatomic, strong) UIButton *repeatBtn;

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
    
    //right view
    [self addSubview:self.rightView];
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10.);
//        make.bottom.equalTo(self.bottomView.mas_top).offset(-26.);
        make.centerY.equalTo(self).offset(-20.);
        make.size.mas_equalTo(CGSizeMake(40, kPlayerRightToolH));
    }];
    
    [self.rightView addSubview:self.rightBgImageView];
    [self.rightBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.rightView);
    }];
    
    [self.rightView addSubview:self.volumeBtn];
    [self.volumeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.rightView);
        make.bottom.equalTo(self.rightView);
        make.height.equalTo(@(kPlayerVolumeBtnH));
    }];
    
    CGFloat sliderH = (kPlayerRightToolH - kPlayerVolumeBtnH - 10);
    self.volumeSlider.layer.anchorPoint = CGPointMake(0, 0.5);
    [self.rightView addSubview:self.volumeSlider];
    [self.volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.rightView.mas_centerX).offset(-sliderH/2.);
        make.centerY.equalTo(self.volumeBtn.mas_top);
        make.size.mas_equalTo(CGSizeMake(sliderH, 40));
    }];
    self.volumeSlider.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
    
    [self addSubview:self.activity];
    [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(45., 45.));
    }];
    
    [self addSubview:self.repeatBtn];
    [self.repeatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(45, 45));
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
    
    self.rightView.alpha = 1;
    self.downBtn.hidden = NO;
    self.isFullScreen = YES;
}

- (void)setOrientationPortraitConstraint {
    self.downBtn.hidden = YES;
    self.rightView.alpha = 0;
    self.isFullScreen = NO;
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

- (void)repeatPlayAction:(UIButton *)sender
{
    
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

- (void)volumeSliderValueBegin:(UISlider *)sender
{
    if ([self.delegate respondsToSelector:@selector(controlView:volumeSliderValueBegin:)]) {
        [self.delegate controlView:self volumeSliderValueBegin:sender];
    }
}

- (void)volumeSliderValueChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlView:volumeSliderValueChanged:)]) {
        [self.delegate controlView:self volumeSliderValueChanged:sender];
    }
}

- (void)volumeSliderValueEnd:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlView:volumeSliderValueEnd:)]) {
        [self.delegate controlView:self volumeSliderValueEnd:sender];
    }
}

//MARK: LLPlaybackControlViewProtocol

- (void)ll_controlChangePlayStatus:(BOOL)play
{
    self.playBtn.selected = play;
}

- (void)ll_controlChangeFullStatus:(BOOL)isFull
{
    self.fullBtn.selected = isFull;
}

- (void)ll_controlPlayCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)aTotalTime sliderValue:(CGFloat)value;
{
    if (!self.isDragging) {
        self.progressSlider.value = value;
    }
    self.currentTimeLabel.text = [@(currentTime) ll_secondFormatter];
    self.totalTimeLabel.text = [@(aTotalTime) ll_secondFormatter];
}

- (void)ll_controlDraggingTime:(NSInteger)draggingTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd{
    // 快进快退时候停止菊花
    [self.activity stopAnimating];
    self.isDragging = YES;
    self.quickView.alpha = 1;
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

- (void)ll_controlAddPanGesture
{
//    // 添加平移手势，用来控制音量、亮度、快进快退
//    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
//    panRecognizer.delegate = self;
//    [panRecognizer setMaximumNumberOfTouches:1];
//    [panRecognizer setDelaysTouchesBegan:YES];
//    [panRecognizer setDelaysTouchesEnded:YES];
//    [panRecognizer setCancelsTouchesInView:YES];
//    [self addGestureRecognizer:panRecognizer];
}

- (void)ll_controlDraggEnd
{
    self.isDragging = NO;
    self.quickView.alpha = 0;
}

- (void)ll_controlDraggingVolume:(CGFloat)draggingVolume
{
    self.volumeSlider.value = draggingVolume;
}

/**
 *  显示控制层
 */
- (void)ll_controlShowControlView {
//    if ([self.delegate respondsToSelector:@selector(zf_controlViewWillShow:isFullscreen:)]) {
//        [self.delegate zf_controlViewWillShow:self isFullscreen:self.isFullScreen];
//    }
    [self ll_controlCancelAutoFadeOutControlView];
    [UIView animateWithDuration:kPlayerControlBarAutoFadeOutTimeInterval animations:^{
        [self showControlView];
    } completion:^(BOOL finished) {
        self.showing = YES;
        [self autoFadeOutControlView];
    }];
}

/**
 *  隐藏控制层
 */
- (void)ll_controlHideControlView {
//    if ([self.delegate respondsToSelector:@selector(zf_controlViewWillHidden:isFullscreen:)]) {
//        [self.delegate zf_controlViewWillHidden:self isFullscreen:self.isFullScreen];
//    }
    [self ll_controlCancelAutoFadeOutControlView];
    [UIView animateWithDuration:kPlayerControlBarAutoFadeOutTimeInterval animations:^{
        [self hideControlView];
    } completion:^(BOOL finished) {
        self.showing = NO;
    }];
}

- (void)ll_controlShowOrHideControlView
{
    if (self.showing) {
        [self ll_controlHideControlView];
    } else {
        [self ll_controlShowControlView];
    }
}

- (void)ll_controlCancelAutoFadeOutControlView
{
     [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/** 加载的菊花 */
- (void)ll_controlActivity:(BOOL)animated {
    if (animated) {
        [self.activity startAnimating];
        self.quickView.alpha = 0;
    } else {
        [self.activity stopAnimating];
    }
}

- (void)ll_controlPlayEnd
{
    self.repeatBtn.hidden = NO;
    self.showing = NO;
    [self hideControlView];
}

//MARK: private

- (void)showControlView {
    self.showing = YES;
    if (self.isFullScreen) {
        self.topView.alpha = 1;
        self.rightView.alpha = 1;
        self.bottomView.alpha = 1;
    } else {
        self.topView.alpha = 0;
        self.rightView.alpha = 0;
        self.bottomView.alpha = 1;
    }
}

- (void)hideControlView {
    self.showing = NO;
    self.topView.alpha = 0;
    self.rightView.alpha = 0;
    self.bottomView.alpha = 0;
}

- (void)autoFadeOutControlView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ll_controlHideControlView) object:nil];
    [self performSelector:@selector(ll_controlHideControlView) withObject:nil afterDelay:kPlayerAnimationTimeInterval];
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
        _totalTimeLabel.text = @"00:00:00";
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
        _currentTimeLabel.text = @"00:00:00";
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
        _quickView.alpha = 0;
    }
    return _quickView;
}

- (UIView *)rightView
{
    if(!_rightView){
        _rightView = [[UIView alloc] init];
        _rightView.backgroundColor = [UIColor clearColor];
        
    }
    return _rightView;
}

- (UIImageView *)rightBgImageView
{
    if(!_rightBgImageView){
        _rightBgImageView = [[UIImageView alloc] init];
        _rightBgImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        _rightBgImageView.userInteractionEnabled = YES;
    }
    return _rightBgImageView;
}

- (UISlider *)volumeSlider
{
    if(!_volumeSlider){
        _volumeSlider = [[UISlider alloc] init];
        [_volumeSlider setThumbImage:[UIImage imageNamed:@"ll_player_point"] forState:UIControlStateNormal];
        _volumeSlider.minimumTrackTintColor = [UIColor ll_colorWithHexString:@"E2368E"];
        _volumeSlider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.3];
        _volumeSlider.value = 0.f;
        _volumeSlider.continuous = YES;
        // slider开始滑动事件
        [_volumeSlider addTarget:self action:@selector(volumeSliderValueBegin:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_volumeSlider addTarget:self action:@selector(volumeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_volumeSlider addTarget:self action:@selector(volumeSliderValueEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    }
    return _volumeSlider;
}

- (UIButton *)volumeBtn
{
    if(!_volumeBtn){
        _volumeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_volumeBtn setImage:[UIImage imageNamed:@"ll_player_voice"] forState:UIControlStateNormal];
    }
    return _volumeBtn;
}

- (MMMaterialDesignSpinner *)activity {
    if (!_activity) {
        _activity = [[MMMaterialDesignSpinner alloc] init];
        _activity.lineWidth = 1;
        _activity.duration  = 1;
        _activity.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    }
    return _activity;
}


- (UIButton *)repeatBtn
{
    if(!_repeatBtn){
        _repeatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_repeatBtn setImage:[UIImage imageNamed:@"ll_player_pause"] forState:UIControlStateNormal];
        [_repeatBtn setImage:[UIImage imageNamed:@"ll_player_play"] forState:UIControlStateSelected];
        [_repeatBtn addTarget:self action:@selector(repeatPlayAction:) forControlEvents:UIControlEventTouchUpInside];
        _repeatBtn.hidden = YES;
    }
    return _repeatBtn;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
