//
//  UIColor+LL.h
//  DMPlayer
//
//  Created by leoliu on 2018/1/17.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (LL)
+ (UIColor *)ll_colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)ll_colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha;
@end
