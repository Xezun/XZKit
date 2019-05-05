//
//  XZNetworkMonitor.h
//  XZKit
//
//  Created by mlibai on 2016/11/7.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName const kXZNetworkReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSNotificationName const kXZNetworkRadioAccessTechnologyDidChangeNotification;

extern const CFStringRef kCNNetworkInfoKeySSIDData;
extern const CFStringRef kCNNetworkInfoKeySSID;
extern const CFStringRef kCNNetworkInfoKeyBSSID;

/**
 网络连接状态枚举值。
 */
typedef NS_ENUM(NSUInteger, XZNetworkReachability) {
    XZNetworkReachabilityUnreachable,
    XZNetworkReachabilityViaWiFi,
    XZNetworkReachabilityViaWWAN
};

/**
 一组描述无线接入方式的枚举值。
 */
typedef NS_ENUM(NSUInteger, XZRadioAccessTechnology) {
    XZRadioAccessTechnologyUnknown,
    // 2G
    XZRadioAccessTechnology2G,
    XZRadioAccessTechnologyGPRS = XZRadioAccessTechnology2G,
    XZRadioAccessTechnologyEdge,
    XZRadioAccessTechnologyCDMA1x,
    // 3G
    XZRadioAccessTechnology3G,
    XZRadioAccessTechnologyWCDMA = XZRadioAccessTechnology3G,
    XZRadioAccessTechnologyHSDPA,
    XZRadioAccessTechnologyHSUPA,
    // 3G CDMA
    XZRadioAccessTechnologyCDMAEVDORev0,
    XZRadioAccessTechnologyCDMAEVDORevA,
    XZRadioAccessTechnologyCDMAEVDORevB,
    XZRadioAccessTechnologyeHRPD,
    // 4G
    XZRadioAccessTechnology4G,
    XZRadioAccessTechnologyLTE = XZRadioAccessTechnology4G
};

/**
 对于网络而言，如果当前可连接到网络就表示已授权。

 - XZNetworkAuthorizationStatusNotDetermined: 暂时不会返回此值
 - XZNetworkAuthorizationStatusDenied: 当网络不可用时，却检测到 Wi-Fi 或蜂窝移动网络
 - XZNetworkAuthorizationStatusCellularDenied: 有蜂窝网，但是无法连接
 - XZNetworkAuthorizationStatusRestricted: 没有 Wi-Fi 和蜂窝
 - XZNetworkAuthorizationStatusAuthorized: 网络可连接
 */
typedef NS_ENUM(NSUInteger, XZNetworkAuthorizationStatus) {
    XZNetworkAuthorizationStatusNotDetermined,
    XZNetworkAuthorizationStatusDenied,
    XZNetworkAuthorizationStatusCellularDenied,
    XZNetworkAuthorizationStatusRestricted,
    XZNetworkAuthorizationStatusAuthorized
};

@protocol XZCellularProviderInfo, XZCaptiveNetworkInfo;


@interface XZNetworkMonitor : NSObject

/**
 创建一个监测与指定主机之间的连通性的 XZNetworkReachability 对象。
 
 @param hostName 主机名
 @return XZNetworkReachability 对象
 */
+ (instancetype)monitorWithHostName:(NSString *)hostName;

/**
 创建一个监测与指定 IP 之间的连通性的 XZNetworkReachability 对象。
 
 @param ipAddress IP 地址，如 192.168.1.1
 @return XZNetworkReachability 对象
 */
+ (instancetype)monitorWithIPAddress:(NSString *)ipAddress;

/**
 创建一个监测网络是否可用的 XZNetworkReachability 对象。
 
 @return XZNetworkReachability 对象
 */
+ (instancetype)monitor;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)reachabilityRef NS_DESIGNATED_INITIALIZER;

- (BOOL)startMonitoring;
- (void)stopMonitoring;

/**
 当前网络是否需要手动建立连接。

 @return 返回 YES ，表示需要。
 */
- (BOOL)isNetworkConnectionRequired;

// 网络连通性
- (XZNetworkReachability)networkReachability;
- (BOOL)isReachable;
- (BOOL)isViaWiFi;
- (BOOL)isViaWWAN;

/**
 Return info of a connected captive network. A captive network is a Wi-Fi network.

 @return a NSDictionary with Keys: kCNNetworkInfoKeySSIDData, kCNNetworkInfoKeySSID, kCNNetworkInfoKeyBSSID.
 */
- (NSArray<NSDictionary<NSString *, id> *> *)captiveNetworkInfo;

// 无线蜂窝接入方式
- (XZRadioAccessTechnology)radioAccessTechnology;
- (BOOL)is2G;
- (BOOL)is3G;
- (BOOL)is4G;

- (XZNetworkAuthorizationStatus)authorizationStatus;

@property (nonatomic, strong, readonly) id<XZCellularProviderInfo> cellularProviderInfo;

- (void)postNetworkReachabilityDidChangeNotification;



@end

@protocol XZCellularProviderInfo <NSObject>

/*
 * providerName
 *
 * Discussion:
 *   An NSString containing the name of the subscriber's cellular service provider.
 */
@property (nonatomic, readonly, nullable, getter=carrierName) NSString *providerName;

/*
 * mobileCountryCode
 *
 * Discussion:
 *   An NSString containing the mobile country code for the subscriber's
 *   cellular service provider, in its numeric representation
 */
@property (nonatomic, readonly, nullable, strong) NSString *mobileCountryCode;

/*
 * mobileNetworkCode
 *
 * Discussion:
 *   An NSString containing the  mobile network code for the subscriber's
 *   cellular service provider, in its numeric representation
 */
@property (nonatomic, readonly, nullable, strong) NSString *mobileNetworkCode;

/*
 * isoCountryCode
 *
 * Discussion:
 *   Returns an NSString object that contains country code for
 *   the subscriber's cellular service provider, represented as an ISO 3166-1
 *   country code string
 */

@property (nonatomic, readonly, nullable, strong) NSString* isoCountryCode;

/*
 * allowsVOIP
 *
 * Discussion:
 *   A BOOL value that is YES if this carrier allows VOIP calls to be
 *   made on its network, NO otherwise.
 */

@property (nonatomic, readonly) BOOL allowsVOIP;

@end


NS_ASSUME_NONNULL_END
