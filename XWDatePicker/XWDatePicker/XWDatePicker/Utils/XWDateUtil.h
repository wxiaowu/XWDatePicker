//
//  XWDateUtil.h
//  DatePicker
//
//  Created by xiaowu on 2018/11/28.
//

#import <Foundation/Foundation.h>

@interface XWDateUtil : NSObject

/** 获取时间组件
 * @param date : 时间
 * @return : 时间组件
 */
+ (NSDateComponents *)dateComponentsWithDate:(NSDate *)date;

/**
 * 获取当前时间戳，精确到毫秒ms
 */
+ (NSTimeInterval)currentTimeInterval;

/** 将时间戳转格式化时间
 * @param time : 13位时间戳,精确到毫秒
 * @param format : 日期格式
 * @return : 格式化时间字符串
 */
+ (NSString *)transformToFormatDateStringWithTime:(NSTimeInterval)time andFormat:(NSString *)format;

@end
