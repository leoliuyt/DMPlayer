//
//  NSNumber+LL.m
//  DMPlayer
//
//  Created by lbq on 2018/1/19.
//  Copyright © 2018年 lbq. All rights reserved.
//

#import "NSNumber+LL.h"

@implementation NSNumber (LL)

- (NSString *)ll_secondFormatter
{
    return [self ll_secondFormatter:@"HH:mm:ss"];
}

- (NSString *)ll_secondFormatter:(NSString *)aFormatter
{
    NSInteger second = self.integerValue;
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:aFormatter];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];//设置0时区
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}
@end
