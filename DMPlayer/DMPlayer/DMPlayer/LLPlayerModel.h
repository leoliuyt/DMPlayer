//
//  LLPlayerModel.h
//  DMPlayer
//
//  Created by lbq on 2018/1/18.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPlayerModelProtocol.h"

@interface LLPlayerModel : NSObject<LLPlayerModelProtocol>

@property (nonatomic, copy) NSURL *contentURL;
@property (nonatomic, strong) UIView *fatherView;
@property (nonatomic, assign) NSInteger    seekTime;
@end
