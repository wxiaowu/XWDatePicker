//
//  UIViewController+Util.m
//  XWUtils
//
//  Created by xiaowu on 2019/6/13.
//  Copyright © 2019年 xiaowu. All rights reserved.
//

#import "UIViewController_Util.h"
#import <objc/runtime.h>

@implementation UIViewController (Util)

- (void (^)(UIViewController *, NSUInteger, NSDictionary *))xw_onControllerResult {
//    id obj = objc_getAssociatedObject(self, @selector(xw_onControllerResult));
//    if (obj == nil) {
//        obj = ^(UIViewController *viewController, NSUInteger code, NSDictionary *data) {};
//    }
//    return obj;
    return objc_getAssociatedDefaultObjectBlock(self, @selector(xw_onControllerResult), OBJC_ASSOCIATION_COPY_NONATOMIC, ^id{
        // 设置一个空的block，这样就不需要总是先判断了
        return ^(UIViewController *viewController, NSUInteger code, NSDictionary *data) {};
    });
}

- (void)setXw_onControllerResult:(void (^)(UIViewController *, NSUInteger, NSDictionary *))xw_onControllerResult {
    objc_setAssociatedObject(self, @selector(xw_onControllerResult), xw_onControllerResult, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

id objc_getAssociatedDefaultObject(id object, const void *key, id defaultObject, objc_AssociationPolicy policy){
    id obj = objc_getAssociatedObject(object, key);
    if (obj == nil && defaultObject != nil) {
        obj = defaultObject;
        objc_setAssociatedObject(object, key, obj, policy);
    }
    return obj;
}

id objc_getAssociatedDefaultObjectBlock(id object, const void *key, objc_AssociationPolicy policy, id (^defaultObject)(void)){
    id obj = objc_getAssociatedObject(object, key);
    if (obj == nil && defaultObject != nil) {
        obj = defaultObject();
        if (obj != nil) {
            objc_setAssociatedObject(object, key, obj, policy);
        }
    }
    return obj;
}

@end
