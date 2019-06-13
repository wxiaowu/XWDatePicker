//
//  UIViewController_Util.h
//  XWUtils
//
//  Created by xiaowu on 2019/6/13.
//  Copyright © 2019年 xiaowu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Util)

/** 用于控制器间传值，类似于安卓的onActivityResult，自身调用即可。不需要判空 */
@property (nonatomic, copy) void (^xw_onControllerResult)(UIViewController *controller, NSUInteger resultCode, NSDictionary *data);
- (void)setXw_onControllerResult:(void (^)(UIViewController *controller, NSUInteger resultCode, NSDictionary *data))xw_onControllerResult;

@end

