//
//  UIApplication+XZAuthorization.h
//  XZKit
//
//  Created by mlibai on 2016/11/9.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZAuthorizationManager.h>

@interface UIApplication (XZAuthorization)

- (void)xz_requestAuthorization:(XZAuthorizationType)authorization completion:(XZAuthorizationRequestCompletion)completion;

@end
