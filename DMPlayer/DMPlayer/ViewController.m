//
//  ViewController.m
//  DMPlayer
//
//  Created by lbq on 2018/1/17.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>

#import "LLPlaybackControlView.h"
#import "LLPlayerView.h"
#import "LLPlayerModel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *fatherView;

@property (nonatomic, strong) LLPlayerModel *playerModel;
@property (nonatomic, strong) LLPlayerView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    LLPlaybackControlView *controlView = [[LLPlaybackControlView alloc] init];
//    controlView.backgroundColor = [UIColor grayColor];
//    [self.view addSubview:controlView];
//    [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.left.right.equalTo(self.view);
////        make.top.equalTo(self.view).offset(64.);
////        make.height.equalTo(@160.);
//        make.edges.equalTo(self.view);
//    }];
    
    [self.playerView playerControlView:nil playerModel:self.playerModel];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)randomUrl
{
    NSArray *arr = @[ @"http://120.25.226.186:32812/resources/videos/minion_01.mp4",
                      @"http://120.25.226.186:32812/resources/videos/minion_02.mp4",
                      @"http://120.25.226.186:32812/resources/videos/minion_03.mp4",
                      @"http://120.25.226.186:32812/resources/videos/minion_04.mp4",
                      @"http://120.25.226.186:32812/resources/videos/minion_05.mp4",
                      @"http://120.25.226.186:32812/resources/videos/minion_06.mp4",
                      @"http://120.25.226.186:32812/resources/videos/minion_07.mp4",
                      @"http://120.25.226.186:32812/resources/videos/minion_08.mp4",
                      @"http://static.smartisanos.cn/common/video/proud-farmer.mp4"];
    return arr[arc4random()%9];
}

- (LLPlayerModel *)playerModel
{
    if(!_playerModel){
        _playerModel = [[LLPlayerModel alloc] init];
        NSString *url = [self randomUrl];
        NSLog(@"random url =%@",url);
        _playerModel.contentURL = [NSURL URLWithString:url];
        _playerModel.fatherView = self.fatherView;
        
    }
    return _playerModel;
}

- (LLPlayerView *)playerView
{
    if(!_playerView){
        _playerView = [[LLPlayerView alloc] init];
    }
    return _playerView;
}

@end
