//
//  LLPlayerView.h
//  DMPlayer
//
//  Created by lbq on 2018/1/17.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
typedef NS_ENUM(NSUInteger, ELayerVideoGravityType) {
    ELayerVideoGravityTypeResize,
    ELayerVideoGravityTypeResizeAspectFill,
    ELayerVideoGravityTypeResizeAspect
};
@interface LLPlayerView : UIView
// 视频显示模式 类似图片的ContentMode
@property (nonatomic, assign) ELayerVideoGravityType videoGravityType;
//视频链接 可以是本地路径URL
@property (nonatomic, strong) NSURL *contentURL;
@end
