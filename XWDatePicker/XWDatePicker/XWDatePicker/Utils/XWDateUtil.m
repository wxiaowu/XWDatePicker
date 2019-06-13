//
//  XWDateUtil.m
//  DatePicker
//
//  Created by xiaowu on 2018/11/28.
//

#import "XWDateUtil.h"

@implementation XWDateUtil

+ (NSDateComponents *)dateComponentsWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comps  = [calendar components:unitFlags fromDate:date];
    return comps;
}

// 获取当前时间戳
+ (NSTimeInterval)currentTimeInterval {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970] * 1000;// *1000 是精确到毫秒，不乘就是精确到秒
    return time;
}

+ (NSString *)transformToFormatDateStringWithTime:(NSTimeInterval)time andFormat:(NSString *)format {
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:time / 1000];
    // 实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:format];
    NSString *dateStr = [dateFormatter stringFromDate: date];
    return dateStr;
}

@end
