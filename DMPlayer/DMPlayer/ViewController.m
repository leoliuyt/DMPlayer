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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    LLPlaybackControlView *controlView = [[LLPlaybackControlView alloc] init];
    controlView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:controlView];
    [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.view);
//        make.top.equalTo(self.view).offset(64.);
//        make.height.equalTo(@160.);
        make.edges.equalTo(self.view);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
