//
//  XZAuthorizationManager.h
//  XZKit
//
//  Created by mlibai on 2016/11/8.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZLocation.h>

typedef NS_OPTIONS(NSUInteger, XZAuthorizationType) {
    XZAuthorizationTypeNone = 0,  // default, no authorization.
    
    XZAuthorizationTypeNetworking NS_DEPRECATED_IOS(1_0, 1_0, "Use \"XZKit/XZNetworkMonitor\" instead.") = 1 << 0,
    
    XZAuthorizationTypePhotos NS_AVAILABLE_IOS(7_0) = 1 << 1,
    XZAuthorizationTypeCamera NS_AVAILABLE_IOS(7_0) = 1 << 2,
    
    XZAuthorizationTypeLocationServicesAlways NS_AVAILABLE_IOS(4_2)    = 1 << 3,
    XZAuthorizationTypeLocationServicesWhenInUse NS_AVAILABLE_IOS(4_2) = 1 << 4,
    
    XZAuthorizationTypeMicrophone NS_AVAILABLE_IOS(7_0)         = 1 << 5,
    XZAuthorizationTypeSpeechRecognition NS_AVAILABLE_IOS(10_0) = 1 << 6,
    
    XZAuthorizationTypeContacts NS_AVAILABLE_IOS(9_0)  = 1 << 7,
    XZAuthorizationTypeCalendars NS_AVAILABLE_IOS(6_0) = 1 << 8,
    XZAuthorizationTypeReminders NS_AVAILABLE_IOS(6_0) = 1 << 9,
    
    XZAuthorizationTypeMediaLibrary NS_AVAILABLE_IOS(9_3)     = 1 << 10,
    // XZAuthorizationTypeBluetoothSharing NS_AVAILABLE_IOS(7_0) = 1 << 11,
    
    // XZAuthorizationTypeHealth = 1 << 12,
    // XZAuthorizationTypeHomeKit = 1 << 13,
    
    XZAuthorizationTypeUnknown,
};

typedef NS_ENUM(NSInteger, XZAuthorizationStatus) {
    XZAuthorizationStatusNotDetermined,
    XZAuthorizationStatusDenied,
    XZAuthorizationStatusRestricted,
    XZAuthorizationStatusAuthorized
};

XZAuthorizationStatus XZAuthorizationStatusForType(XZAuthorizationType authorizationType);

typedef void (^XZAuthorizationRequestCompletion)(XZAuthorizationStatus status, XZAuthorizationType type);

@interface XZAuthorizationManager : NSObject

+ (instancetype)manager;

/**
 检测并申请权限。如果所有权限都已授权，回调会立即执行；如果检测到未授权的权限，则终止继续检测，并触发回调。
 
 @param authorization 权限类型
 @param completion 回调，该回调始终在主线程执行。
 @discuss 如果 status == XZAuthorizationStatusAuthorized 则 type 与输入的参数一致。
 *        否则，type 为当前未被授权的权限。
 */
- (void)requestAuthorization:(XZAuthorizationType)authorization completion:(XZAuthorizationRequestCompletion)completion;

/**
 获取某权限的授权状态。

 @param authorizationType 权限类型
 @return 授权状态枚举值
 */
+ (XZAuthorizationStatus)authorizationStatus:(XZAuthorizationType)authorizationType;
- (XZAuthorizationStatus)authorizationStatus:(XZAuthorizationType)authorizationType;

@end
