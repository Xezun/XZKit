//
//  UIApplication+XZAuthorization.m
//  XZKit
//
//  Created by mlibai on 2016/11/9.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "UIApplication+XZAuthorization.h"

@implementation UIApplication (XZAuthorization)

- (void)xz_requestAuthorization:(XZAuthorizationType)authorization completion:(XZAuthorizationRequestCompletion)completion {
    [[XZAuthorizationManager manager] requestAuthorization:authorization completion:completion];
}

@end
