//
//  ViewController.m
//  XWDatePicker
//
//  Created by xiaowu on 2019/6/13.
//  Copyright © 2019年 xiaowu. All rights reserved.
//

#import "ViewController.h"
#import "XWDatePickerController.h"
#import "XWDateUtil.h"
#import "UIViewController_Util.h"

@interface ViewController ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    [btn setTitle:@"日期选择器" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor orangeColor]];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 150, 200, 40)];
    label.layer.borderColor = [UIColor lightGrayColor].CGColor;
    label.layer.borderWidth = 1;
    label.textColor = [UIColor blackColor];
    [self.view addSubview:label];
    self.label = label;
}


- (void)btnClick:(UIButton *)btn {
    
    XWDatePickerController *picker = [[XWDatePickerController alloc] init];
    picker.pickerTitle = @"日期选择器";
    picker.themeColor = [UIColor blueColor];
    
    // 获取初始显示时间默认值，默认为当前时间，超出时间限定边界就取边界值
    NSTimeInterval minTime = 955077071000;
    NSTimeInterval maxTime = 1896228610000;
    NSTimeInterval defaultTime = [self getDefaultTimeWithMinTime:minTime andMaxTime:maxTime];
    picker.minTime = 955077071000;
    picker.maxTime = 1896228610000;
    picker.initialTime = defaultTime;
    
    picker.pickerComponents = XWDatePickerComponentYear | XWDatePickerComponentMonth | XWDatePickerComponentDay | XWDatePickerComponentHour | XWDatePickerComponentMinute | XWDatePickerComponentSecond;
    
    picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:picker animated:NO completion:nil];
    [picker setXw_onControllerResult:^(UIViewController *controller, NSUInteger resultCode, NSDictionary *data) {
        [controller dismissViewControllerAnimated:NO completion:^{
            if (resultCode == 1) {
                // 格式化时间
                NSString *dateString = [XWDateUtil transformToFormatDateStringWithTime:[data[@"data"] doubleValue] andFormat:@"yyyy-MM-dd HH:mm:ss"];
                self.label.text = dateString;
                
            } else if (resultCode == 0) {
                NSLog(@"o我取消了。。。哈哈哈😃");
            }
        }];
    }];
}

// 获取初始显示时间的默认值，默认为当前时间，超出时间限定边界就取边界值
- (NSTimeInterval)getDefaultTimeWithMinTime:(NSTimeInterval)minTime andMaxTime:(NSTimeInterval)maxTime {
    NSTimeInterval currentTime = [XWDateUtil currentTimeInterval];
    if (currentTime < minTime) {
        currentTime = minTime;
    }
    if (currentTime > maxTime) {
        currentTime = maxTime;
    }
    return currentTime;
}


@end
