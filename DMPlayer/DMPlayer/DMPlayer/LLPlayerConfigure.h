//
//  LLPlayerConfigure.h
//  DMPlayer
//
//  Created by lbq on 2018/1/17.
//  Copyright © 2018年 lbq. All rights reserved.
//

#ifndef LLPlayerConfigure_h
#define LLPlayerConfigure_h

#define LLPlayerSrcName(file) [@"LLPlayer.bundle" stringByAppendingPathComponent:file]
typedef NS_ENUM(NSUInteger, ELayerVideoGravityType) {
    ELayerVideoGravityTypeResize,
    ELayerVideoGravityTypeResizeAspectFill,
    ELayerVideoGravityTypeResizeAspect
};

#endif /* LLPlayerConfigure_h */
