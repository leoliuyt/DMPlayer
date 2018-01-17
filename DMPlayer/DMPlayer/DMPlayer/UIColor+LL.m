//
//  UIColor+LL.m
//  DMPlayer
//
//  Created by leoliu on 2018/1/17.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import "UIColor+LL.h"

@implementation UIColor (LL)

+ (UIColor *)ll_colorWithRGBHex:(UInt32)hex {
    return [UIColor ll_colorWithRGBHex:hex alpha:1.0];
}

+ (UIColor *)ll_colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

+ (UIColor *)ll_colorWithHexString:(NSString *)stringToConvert {
    return [UIColor ll_colorWithHexString:stringToConvert alpha:1];
}

+ (UIColor *)ll_colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha{
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [UIColor ll_colorWithRGBHex:hexNum alpha:alpha];
}

@end
