//
//  LLPlayerModelProtocol.h
//  DMPlayer
//
//  Created by lbq on 2018/1/18.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol LLPlayerModelProtocol <NSObject>

@property (nonatomic, copy) NSURL *contentURL;
@property (nonatomic, strong) UIView *fatherView;
//从第几s开始播放
@property (nonatomic, assign) NSInteger    seekTime;

@end
