//
//  NSNumber+LL.h
//  DMPlayer
//
//  Created by lbq on 2018/1/19.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (LL)

//将秒格式化成HH:mm:ss

/**
 将秒数格式化成HH:mm:ss的字符串

 @return 格式化后的字符串
 */
- (NSString *)ll_secondFormatter;


/**
 将秒数格式化成指定格式的字符串
 
 @param formatter 指定的格式
 @return 格式化后的字符串
 */
- (NSString *)ll_secondFormatter:(NSString *)formatter;
@end
