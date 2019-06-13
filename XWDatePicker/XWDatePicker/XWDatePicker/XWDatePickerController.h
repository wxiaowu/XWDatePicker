//
//  XWDatePickerController.h
//  DatePicker
//
//  Created by xiaowu on 2018/11/21.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, XWDatePickerComponent) {
    XWDatePickerComponentYear = (1 << 1), // 年
    XWDatePickerComponentMonth = (1 << 2), // 月
    XWDatePickerComponentDay = (1 << 3), // 日
    XWDatePickerComponentHour = (1 << 4), // 时
    XWDatePickerComponentMinute = (1 << 5), // 分
    XWDatePickerComponentSecond = (1 << 6) // 秒
};
@interface XWDatePickerController : UIViewController
@property (nonatomic, strong) UIColor *themeColor; ///< 主题颜色
@property (nonatomic, copy, nonnull) NSString *pickerTitle; ///< 选择器标题
@property (nonatomic, assign) NSTimeInterval initialTime; ///< 默认选中的时间、初始时间戳，默认为当前时间戳,超出时间限定边界就取边界值
@property (nonatomic, assign) NSTimeInterval maxTime; ///< 最大时间限定，精确到毫秒ms，默认1924963199000（2030-12-31 23:59:59）
@property (nonatomic, assign) NSTimeInterval minTime; ///< 最小时间限定，精确到毫秒ms，默认946656000000（2000-01-01 00:00:00）

@property (nonatomic, assign) XWDatePickerComponent pickerComponents; ///< 添加的选择组件,设置数据源


@end
