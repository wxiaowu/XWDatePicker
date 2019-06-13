//
//  XWDatePickerController.m
//  DatePicker
//
//  Created by xiaowu on 2018/11/21.
//

#import "XWDatePickerController.h"
#import "Masonry.h"
#import "XWDateUtil.h"
#import "UIViewController_Util.h"


/**
 * 格式选中时间结构
 */
typedef struct {
    NSInteger year;
    NSInteger month;
    NSInteger day;
    NSInteger hour;
    NSInteger minute;
    NSInteger second;
} XWPickerDate;

#define SCREENW                     [UIScreen mainScreen].bounds.size.width
#define SCREENH                     [UIScreen mainScreen].bounds.size.height
#define BGVIEWH                     274

#define Format(...)                 [NSString stringWithFormat:__VA_ARGS__] // 格式化字符串
#define MatchDatePickerComponent(A,B)    {if (self.pickerComponents & (XWDatePickerComponent##A)) B} // 判断添加了哪个选择器组件，执行B
@interface XWDatePickerController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSInteger _minYear; ///< 记录限定的时间年份最小值
    NSInteger _minMonth;
    NSInteger _minDay;
    NSInteger _minHour;
    NSInteger _minMinute;
    NSInteger _minSecond;
    NSInteger _maxYear; ///< 记录限定的时间年份最大值
    NSInteger _maxMonth;
    NSInteger _maxDay;
    NSInteger _maxHour;
    NSInteger _maxMinute;
    NSInteger _maxSecond;
    NSInteger _yearCompMin; ///< 记录年组件显示的最小值
    NSInteger _monthCompMin;
    NSInteger _dayCompMin;
    NSInteger _hourCompMin;
    NSInteger _minuteCompMin;
    NSInteger _secondCompMin;
}

@property (nonatomic, strong) UIView *bgView; ///< 日期选择器背景视图
@property (nonatomic, strong) UIView *topView; ///< 顶部视图
@property (nonatomic, strong) UILabel *pickerTitleLB; ///< 标题
@property (nonatomic, strong) UIButton *cancelBtn; ///< 取消按钮
@property (nonatomic, strong) UIButton *sureBtn; ///< 确定按钮
@property (nonatomic, strong) UIPickerView *pickerView; ///< 日期选择器
@property (nonatomic, strong) UIView *separateView; ///< 分割线

@property (nonatomic, assign) XWPickerDate currentDate; ///< 选中的时间
@property (nonatomic, assign) NSInteger dayRange; ///< 天数范围

@property (nonatomic, strong) NSMutableArray *compsArr; ///< 记录添加了那些组件,数组索引对应组件

@end

@implementation XWDatePickerController

- (NSMutableArray *)compsArr {
    if (_compsArr == nil) {
        _compsArr = [NSMutableArray new];
    }
    return _compsArr;
}

- (instancetype)init {
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.pickerTitle = @"";
        // 初始化最小最大时间限定
        self.minTime = 946656000000;
        self.maxTime = 1924963199000;
        // 初始化被选中时间为当前时间（默认:当前时间戳,超出时间限定边界取边界值）
        self.initialTime = [XWDateUtil currentTimeInterval];
    }
    return self;
}

- (void)setInitialTime:(NSTimeInterval)initialTime {
    _initialTime = initialTime;
}

- (void)setThemeColor:(UIColor *)themeColor {
    _themeColor = themeColor;
    [self.cancelBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [self.sureBtn setTitleColor:themeColor forState:UIControlStateNormal];
    self.pickerTitleLB.textColor = themeColor;
}

- (void)setPickerTitle:(NSString *)pickerTitle {
    _pickerTitle = pickerTitle;
    self.pickerTitleLB.text = pickerTitle;
}

- (void)setMinTime:(NSTimeInterval)minTime {
    _minTime = minTime;
    // 设置限定的时间最小值
    NSDateComponents *minDateComp = [XWDateUtil dateComponentsWithDate:[NSDate dateWithTimeIntervalSince1970:_minTime / 1000]];
    _minYear = minDateComp.year;
    _minMonth = minDateComp.month;
    _minDay = minDateComp.day;
    _minHour = minDateComp.hour;
    _minMinute = minDateComp.minute;
    _minSecond = minDateComp.second;
}

- (void)setMaxTime:(NSTimeInterval)maxTime {
    _maxTime = maxTime;
    // 设置限定的时间最大值
    NSDateComponents *maxDateComp = [XWDateUtil dateComponentsWithDate:[NSDate dateWithTimeIntervalSince1970:_maxTime / 1000]];
    _maxYear = maxDateComp.year;
    _maxMonth = maxDateComp.month;
    _maxDay = maxDateComp.day;
    _maxHour = maxDateComp.hour;
    _maxMinute = maxDateComp.minute;
    _maxSecond = maxDateComp.second;
}

// 设置添加的组件
- (void)setPickerComponents:(XWDatePickerComponent)pickerComponents {
    _pickerComponents = pickerComponents;
    MatchDatePickerComponent(Year,   {[self.compsArr addObject:@"year"];}) // 添加了年组件
    MatchDatePickerComponent(Month,  {[self.compsArr addObject:@"month"];})
    MatchDatePickerComponent(Day,    {[self.compsArr addObject:@"day"];})
    MatchDatePickerComponent(Hour,   {[self.compsArr addObject:@"hour"];})
    MatchDatePickerComponent(Minute, {[self.compsArr addObject:@"minute"];})
    MatchDatePickerComponent(Second, {[self.compsArr addObject:@"second"];})
}

#pragma mark - 选择对应月份的天数
-(NSInteger)dayInYear:(NSInteger)year andMonth:(NSInteger)month {
    int day = 0;
    switch(month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            day = 31;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            day = 30;
            break;
        case 2:
        {
            if(((year % 4 == 0)&&(year % 100 != 0))||(year % 400 == 0)) {
                day = 29;
                break;
            } else {
                day = 28;
                break;
            }
        }
        default:
            break;
    }
    return day;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 选择器背景视图
    self.bgView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    [self.view addSubview:self.bgView];
    // 顶部View
    self.topView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    [self.bgView addSubview:self.topView];
    // 标题
    self.pickerTitleLB = ({
        UILabel *pickerTitleLB = [UILabel new];
        pickerTitleLB.textAlignment = NSTextAlignmentCenter;
        pickerTitleLB.font = [UIFont systemFontOfSize:18];
        pickerTitleLB;
    });
    [self.topView addSubview:self.pickerTitleLB];
    // 取消按钮
    self.cancelBtn = ({
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn;
    });
    [self.topView addSubview:self.cancelBtn];
    // 确定按钮
    self.sureBtn = ({
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        sureBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(sureBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        sureBtn;
    });
    [self.topView addSubview:self.sureBtn];
    // 选择器
    self.pickerView = ({
        UIPickerView *picker = [UIPickerView new];
        picker.backgroundColor = [UIColor whiteColor];
        picker.dataSource = self;
        picker.delegate = self;
        picker;
    });
    [self.bgView addSubview:self.pickerView];
    // 分割线
    self.separateView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        view;
    });
    [self.bgView addSubview:self.separateView];
}

// 取消按钮点击
- (void)cancelBtnDidClick {
    [UIView animateWithDuration:0.2 animations:^{
        // 还原平移初始位置
        self.bgView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.xw_onControllerResult(self, 0, nil);
    }];
}

// 确认按钮点击
- (void)sureBtnDidClick {
    // 执行成功返回选中日期
    NSDate *date = [self transformFromPickerDate:_currentDate];
    NSTimeInterval timeInterval = [date timeIntervalSince1970] * 1000;
    self.xw_onControllerResult(self, 1, @{@"data" : @(timeInterval)});
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    __weak typeof(self) weakself = self;
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        // 设置初始位置为屏幕底部，用于动画弹出
        make.top.equalTo(weakself.view.mas_bottom).with.offset(0);
        make.width.equalTo(weakself.view.mas_width);
        make.height.mas_equalTo(BGVIEWH);
    }];
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.bgView.mas_top).with.offset(0);
        make.width.equalTo(weakself.bgView.mas_width);
        make.height.mas_equalTo(44);
    }];
    [self.cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0,*)) {
            make.left.equalTo(weakself.view.mas_safeAreaLayoutGuideLeft).with.offset(15);
        }else{
            make.left.equalTo(weakself.topView.mas_left).with.offset(15);
        }
        make.top.equalTo(weakself.topView.mas_top).with.offset(0);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(weakself.topView.mas_height);
    }];
    [self.sureBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0,*)) {
            make.right.equalTo(weakself.view.mas_safeAreaLayoutGuideRight).with.offset(-15);
        }else{
            make.right.equalTo(weakself.topView.mas_right).with.offset(-15);
        }
        make.top.equalTo(weakself.topView.mas_top).with.offset(0);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(weakself.topView.mas_height);
    }];
    [self.pickerTitleLB mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.cancelBtn.mas_right).with.offset(15);
        make.right.equalTo(weakself.sureBtn.mas_left).with.offset(-15);
        make.top.equalTo(weakself.topView.mas_top);
        make.bottom.equalTo(weakself.topView.mas_bottom);
    }];
    [self.pickerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.bgView).with.insets(UIEdgeInsetsMake(44, 0, 0, 0));
    } ];
    [self.separateView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.bgView.mas_left);
        make.right.equalTo(weakself.bgView.mas_right);
        make.top.equalTo(weakself.bgView.mas_top).with.offset(44);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 动画弹出视图
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform tf = CGAffineTransformMakeTranslation(0, -BGVIEWH);
        [self.bgView setTransform:tf];
    }];
    
    // 确定选择器的初始显示时间
    _initialTime = [self checkInitialTime];
    // 设置初始选中时间
    [self setSelectedDateWithInitialTime:_initialTime];
    // 根据各个组件的选中来确定组件的最小值
    [self compsMinValueOfCurrentDate];
    // 设置选中
    [self updateSelectedRowOfCurrentDate];
}

// 检验初始显示时间，超出时间限定边界就取边界值
- (NSTimeInterval)checkInitialTime {
    if (_initialTime < _minTime) {
        _initialTime = _minTime;
    }
    if (_initialTime > _maxTime) {
        _initialTime = _maxTime;
    }
    return _initialTime;
}

// 设置初始选中的时间
- (void)setSelectedDateWithInitialTime:(NSTimeInterval)initialTime {
    // 获取日期组件
    NSDateComponents *seletedDateComps = [XWDateUtil dateComponentsWithDate:[NSDate dateWithTimeIntervalSince1970:initialTime / 1000]];
    _currentDate.year = seletedDateComps.year;
    _currentDate.month = seletedDateComps.month;
    _currentDate.day = seletedDateComps.day;
    _currentDate.hour = seletedDateComps.hour;
    _currentDate.minute = seletedDateComps.minute;
    _currentDate.second = seletedDateComps.second;
    // 计算天数范围
    _dayRange = [self dayInYear:_currentDate.year andMonth:_currentDate.month];
}

// 刷新选中的行 为当前时间
- (void)updateSelectedRowOfCurrentDate {
    // 遍历组件，设置选中的行
    for (int i = 0; i < _compsArr.count; i++) {
        NSString *compType = _compsArr[i];
        NSInteger rowNum = [self.pickerView numberOfRowsInComponent:i];
        
        if ([compType isEqualToString:@"year"]) {
            NSInteger yearIndex = _currentDate.year - _yearCompMin;
            [self.pickerView selectRow:yearIndex inComponent:i animated:NO];
        }
        if ([compType isEqualToString:@"month"]) {
            NSInteger monthIndex = _currentDate.month - _monthCompMin;
            if (monthIndex < 0 || monthIndex >= rowNum) {
                // 如果当前选中的组件超出边界，设置为选中最小值，此时选中的值为边界最小值，应刷新其他组件的最小值
                monthIndex = 0;
                _currentDate.month = _monthCompMin;
                [self compsMinValueOfCurrentDate];
            }
            [self.pickerView selectRow:monthIndex inComponent:i animated:NO];
        }
        if ([compType isEqualToString:@"day"]) {
            NSInteger dayIndex = _currentDate.day - _dayCompMin;
            if (dayIndex < 0 || dayIndex >= rowNum) {
                dayIndex = 0;
                _currentDate.day = _dayCompMin;
                [self compsMinValueOfCurrentDate];
            }
            [self.pickerView selectRow:dayIndex inComponent:i animated:NO];
        }
        if ([compType isEqualToString:@"hour"]) {
            NSInteger hourIndex = _currentDate.hour - _hourCompMin;
            if (hourIndex < 0 || hourIndex >= rowNum) {
                hourIndex = 0;
                // 当前选中的时间
                _currentDate.hour = _hourCompMin;
                [self compsMinValueOfCurrentDate];
            }
            [self.pickerView selectRow:hourIndex inComponent:i animated:NO];
        }
        if ([compType isEqualToString:@"minute"]) {
            NSInteger minuteIndex = _currentDate.minute - _minuteCompMin;
            if (minuteIndex < 0 || minuteIndex >= rowNum) { // 超出边界，统一指向第0行
                minuteIndex = 0;
                _currentDate.minute = _minuteCompMin;
                [self compsMinValueOfCurrentDate];
            }
            [self.pickerView selectRow:minuteIndex inComponent:i animated:NO];
        }
        if ([compType isEqualToString:@"second"]) {
            NSInteger secondIndex = _currentDate.second - _secondCompMin;
            if (secondIndex < 0 || secondIndex >= rowNum) {
                secondIndex = 0;
                _currentDate.second = _secondCompMin;
                [self compsMinValueOfCurrentDate];
            }
            [self.pickerView selectRow:secondIndex inComponent:i animated:NO];
        }
        // 每遍历一遍刷新一次,更新最新的组件rowNum
        [self.pickerView reloadAllComponents];
    }
}

// 根据各个组件的选中来刷新组件的最小值,如果当前选中时间currentDate改变，必须调用这个方法刷新最新的组件最小值
- (void)compsMinValueOfCurrentDate {
    _yearCompMin = _minYear;
    // 当前选中的年份为最小年，则月组件的最小值为最小月份
    _monthCompMin = (_currentDate.year == _minYear) ? _minMonth : 1;
    _dayCompMin = (_currentDate.year == _minYear && _currentDate.month == _minMonth) ? _minDay : 1;
    _hourCompMin = (_currentDate.year == _minYear && _currentDate.month == _minMonth && _currentDate.day == _minDay) ? _minHour : 0;
    _minuteCompMin = (_currentDate.year == _minYear && _currentDate.month == _minMonth && _currentDate.day == _minDay && _currentDate.hour == _minHour) ? _minMinute : 0;
    _secondCompMin = (_currentDate.year == _minYear && _currentDate.month == _minMonth && _currentDate.day == _minDay && _currentDate.hour == _minHour && _currentDate.minute == _minMinute) ? _minSecond : 0;
}



#pragma mark -- UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//    int count = 0;//用于累加计算二进制1的个数,也就是添加的组件数
//    NSUInteger value = _pickerComponents;
//    while (value) {
//        if ((value & 1) == 1) {
//            count++;
//            value = value >> 1;
//        }
//    }
    return _compsArr.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // 组件类型
    NSString *compType = _compsArr[component];
    if ([compType isEqualToString:@"year"]) {
        return _maxYear - _minYear + 1;
    }
    if ([compType isEqualToString:@"month"]) {
        if (_currentDate.year == _minYear) {
            return 12 - _minMonth + 1;
        } else if (_currentDate.year == _maxYear) {
            return _maxMonth;
        } else {
            return 12;
        }
    }
    if ([compType isEqualToString:@"day"]) {
        if (_currentDate.year == _minYear && _currentDate.month == _minMonth) {
            return _dayRange - _minDay + 1;
        } else if (_currentDate.year == _maxYear && _currentDate.month == _maxMonth) {
            return _maxDay;
        } else {
            return _dayRange;
        }
    }
    if ([compType isEqualToString:@"hour"]) {
        if (_currentDate.year == _minYear && _currentDate.month == _minMonth && _currentDate.day == _minDay) {
            return 24 - _minHour;
        } else if (_currentDate.year == _maxYear && _currentDate.month == _maxMonth && _currentDate.day == _maxDay) {
            return _maxHour + 1;
        } else {
            return 24;
        }
    }
    if ([compType isEqualToString:@"minute"]) {
        if (_currentDate.year == _minYear && _currentDate.month == _minMonth && _currentDate.day == _minDay && _currentDate.hour == _minHour) {
            return 60 - _minMinute;
        } else if (_currentDate.year == _maxYear && _currentDate.month == _maxMonth && _currentDate.day == _maxDay && _currentDate.hour == _maxHour) {
            return _maxMinute + 1;
        } else {
            return 60;
        }
    }
    if ([compType isEqualToString:@"second"]) {
        if (_currentDate.year == _minYear && _currentDate.month == _minMonth && _currentDate.day == _minDay && _currentDate.hour == _minHour && _currentDate.minute == _minMinute) {
            return 60 - _minSecond;
        } else if (_currentDate.year == _maxYear && _currentDate.month == _maxMonth && _currentDate.day == _maxDay && _currentDate.hour == _maxHour && _currentDate.minute == _maxMinute) {
            return _maxSecond + 1;
        } else {
            return 60;
        }
    }
    return 0;
}

#pragma mark -- UIPickerViewDelegate

-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *yearValue       = Format(@"%ld年",(long)(row + _yearCompMin));
    NSString *monthValue      = Format(@"%ld月",(long)(row + _monthCompMin));
    NSString *dayValue        = Format(@"%ld日",(long)(row + _dayCompMin));
    NSString *hourValue       = Format(@"%ld时",(long)(row + _hourCompMin));
    NSString *minuteValue     = Format(@"%ld分",(long)(row + _minuteCompMin));
    NSString *secondValue     = Format(@"%ld秒",(long)(row + _secondCompMin));
    
    NSString *compType = _compsArr[component];
    if ([compType isEqualToString:@"year"]) {
        return yearValue;
    }
    if ([compType isEqualToString:@"month"]) {
        return monthValue;
    }
    if ([compType isEqualToString:@"day"]) {
        return dayValue;
    }
    if ([compType isEqualToString:@"hour"]) {
        return hourValue;
    }
    if ([compType isEqualToString:@"minute"]) {
        return minuteValue;
    }
    if ([compType isEqualToString:@"second"]) {
        return secondValue;
    }
    return @"";
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    CGFloat pickerW = [UIScreen mainScreen].bounds.size.width - 40;
    
    NSString *compType = _compsArr[component];
    if ([compType isEqualToString:@"year"])       {return 70;}
    if ([compType isEqualToString:@"month"])        {return 45;}
    if ([compType isEqualToString:@"day"])        {return 45;}
    if ([compType isEqualToString:@"hour"])        {return 45;}
    if ([compType isEqualToString:@"minute"])        {return 45;}
    if ([compType isEqualToString:@"second"])        {return 45;}
    
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 35;
}

// 监听picker的选择
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *compType = _compsArr[component];
    if ([compType isEqualToString:@"year"]) {
        _currentDate.year = _yearCompMin + row;
        _dayRange = [self dayInYear:_currentDate.year andMonth:_currentDate.month];
        
    }
    if ([compType isEqualToString:@"month"]) {
        _currentDate.month = _monthCompMin + row;
        _dayRange = [self dayInYear:_currentDate.year andMonth:_currentDate.month];
    }
    if ([compType isEqualToString:@"day"]) {_currentDate.day = _dayCompMin + row;}
    if ([compType isEqualToString:@"hour"]) {_currentDate.hour = _hourCompMin + row;}
    if ([compType isEqualToString:@"minute"]) {_currentDate.minute = _minuteCompMin + row;}
    if ([compType isEqualToString:@"second"]) {_currentDate.second = _secondCompMin + row;}
    
    // currentDate更新需刷新组件最小值
    [self compsMinValueOfCurrentDate];
    // 刷新组件后需更新当前选中日期的行
    [self updateSelectedRowOfCurrentDate];
}

/** XWPickerDate转NSDate类型
 * @param pickerDate : XWPickerDate选中的时间
 * @return : NSDate
 */
- (NSDate *)transformFromPickerDate:(XWPickerDate)pickerDate {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    [components setYear:pickerDate.year];
    [components setMonth:pickerDate.month];
    [components setDay:pickerDate.day];
    [components setHour:pickerDate.hour];
    [components setMinute:pickerDate.minute];
    [components setSecond:pickerDate.second];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components];
    return date;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;//获取触摸对象
    CGPoint pt = [touch locationInView:self.view];
    // 点击其他地方消失
    if (!CGRectContainsPoint([self.bgView frame], pt)) {
        [self cancelBtnDidClick];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
