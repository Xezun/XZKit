//
//  XZNetworkMonitor.m
//  XZKit
//
//  Created by mlibai on 2016/11/7.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZNetworkMonitor.h"

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h> // inet_addr()

#import <SystemConfiguration/CaptiveNetwork.h> // WiFi
#import <CoreFoundation/CoreFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NSNotificationName const kXZNetworkReachabilityDidChangeNotification = @"kXZNetworkReachabilityDidChangeNotification";
NSNotificationName const kXZNetworkRadioAccessTechnologyDidChangeNotification = @"kXZNetworkRadioAccessTechnologyDidChangeNotification";

static void XZSCNetworkReachabilityCallback(SCNetworkReachabilityRef, SCNetworkReachabilityFlags, void *);
static NSString *CTRadioAccessTechnologyFromXZRadioAccessTechnology(XZRadioAccessTechnology type);
static XZRadioAccessTechnology XZRadioAccessTechnologyForCTRadioAccessTechnology(NSString *);
static XZNetworkReachability XZNetworkReachabilityForReachableSCNetworkReachabilityFlags(SCNetworkReachabilityFlags);

@interface XZNetworkMonitor ()

@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, strong, readonly) CTTelephonyNetworkInfo *telephonyNetworkInfo;

@end

@implementation XZNetworkMonitor

+ (instancetype)monitorWithHostName:(NSString *)hostName {
    XZNetworkMonitor *monitor = nil;
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachabilityRef != NULL) {
        monitor = [(XZNetworkMonitor *)[self alloc] initWithReachabilityRef:reachabilityRef];
        CFRelease(reachabilityRef);
    }
    return monitor;
}

+ (instancetype)monitorWithIPAddress:(NSString *)ipAddress {
    XZNetworkMonitor *monitor = nil;
    struct sockaddr_in sock_address;
    bzero(&sock_address, sizeof(sock_address));
    sock_address.sin_len = sizeof(sock_address);
    sock_address.sin_family = AF_INET;
    sock_address.sin_addr.s_addr = inet_addr(ipAddress.UTF8String);
    
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&sock_address);
    if (reachabilityRef != NULL) {
        monitor = [(XZNetworkMonitor *)[self alloc] initWithReachabilityRef:reachabilityRef];
        CFRelease(reachabilityRef);
    }
    
    return monitor;
}

+ (instancetype)monitor {
    return [self monitorWithIPAddress:@"0.0.0.0"];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSGenericException reason:@"Call -initWithReachabilityRef: method instead." userInfo:nil];
}

- (instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)reachabilityRef {
    NSAssert(reachabilityRef != NULL, @"The reachabilityRef Cannot Be Null When Use XZNetworkMonitor.");
    self = [super init];
    if (self != nil) {
        _reachabilityRef = CFRetain(reachabilityRef);
    }
    return self;
}

- (void)dealloc {
    [self stopMonitoring];
    if (_reachabilityRef != NULL) {
        CFRelease(_reachabilityRef);
    }
    if (_telephonyNetworkInfo != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CTRadioAccessTechnologyDidChangeNotification object:_telephonyNetworkInfo];
    }
}

- (BOOL)startMonitoring {
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    BOOL succeed = SCNetworkReachabilitySetCallback(_reachabilityRef, XZSCNetworkReachabilityCallback, &context);
    if (succeed) {
        succeed = SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
    return succeed;
}

- (void)stopMonitoring {
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}

- (BOOL)isNetworkConnectionRequired {
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    return NO;
}

- (XZNetworkReachability)networkReachability {
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        return XZNetworkReachabilityForReachableSCNetworkReachabilityFlags(flags);
    }
    return XZNetworkReachabilityUnreachable;
}

- (BOOL)isReachable {
    return ([self networkReachability] != XZNetworkReachabilityUnreachable);
}

- (BOOL)isViaWWAN {
    return ([self networkReachability] == XZNetworkReachabilityViaWWAN);
}

- (NSArray<NSDictionary<NSString *,id> *> *)captiveNetworkInfo {
    NSMutableArray<NSDictionary<NSString *,id> *> *arrayM = nil;
    NSArray *interfaces = CFBridgingRelease(CNCopySupportedInterfaces());
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef interfaceInfo = CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName);
        if (CFDictionaryGetCount(interfaceInfo) > 0) {
            if (arrayM == nil) {
                arrayM = [NSMutableArray array];
            }
            [arrayM addObject:(__bridge NSDictionary<NSString *,id> * _Nonnull)(interfaceInfo)];
        }
    }
    return arrayM;
}

- (BOOL)isViaWiFi {
    return ([self networkReachability] == XZNetworkReachabilityViaWiFi);
}

- (XZRadioAccessTechnology)radioAccessTechnology {
    NSString *radioAccessTechnologyString = [self telephonyNetworkInfo].currentRadioAccessTechnology;
    return XZRadioAccessTechnologyForCTRadioAccessTechnology(radioAccessTechnologyString);
}

- (BOOL)is2G {
    XZRadioAccessTechnology technology = [self radioAccessTechnology];
    return (technology >= XZRadioAccessTechnologyUnknown && technology < XZRadioAccessTechnology3G);
}

- (BOOL)is3G {
    XZRadioAccessTechnology technology = [self radioAccessTechnology];
    return (technology >= XZRadioAccessTechnology3G && technology < XZRadioAccessTechnology4G);
}

- (BOOL)is4G {
    XZRadioAccessTechnology technology = [self radioAccessTechnology];
    return (technology >= XZRadioAccessTechnology4G);
}

- (XZNetworkAuthorizationStatus)authorizationStatus {
    if (![self isReachable]) {
        if (self.captiveNetworkInfo.count > 0) { // wifi is connected.
            return XZNetworkAuthorizationStatusDenied;
        } else if (self.radioAccessTechnology == XZRadioAccessTechnologyUnknown) { // wifi is not connected and also no cell.
            return XZNetworkAuthorizationStatusRestricted;
        }
        return XZNetworkAuthorizationStatusCellularDenied;
    }
    return XZNetworkAuthorizationStatusAuthorized;
}

- (id<XZCellularProviderInfo>)cellularProviderInfo {
    return (id<XZCellularProviderInfo>)[[self telephonyNetworkInfo] subscriberCellularProvider];
}



@synthesize telephonyNetworkInfo = _telephonyNetworkInfo;
- (CTTelephonyNetworkInfo *)telephonyNetworkInfo {
    if (_telephonyNetworkInfo != nil) {
        return _telephonyNetworkInfo;
    }
    _telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioAccessTechnologyDidChangeNotification:) name:CTRadioAccessTechnologyDidChangeNotification object:_telephonyNetworkInfo];
    return _telephonyNetworkInfo;
}

- (void)radioAccessTechnologyDidChangeNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kXZNetworkRadioAccessTechnologyDidChangeNotification object:self];
}

- (void)postNetworkReachabilityDidChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kXZNetworkReachabilityDidChangeNotification object:self];
}

@end

#pragma mark - private functions

static void XZSCNetworkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was nil in SCNetworkReachabilityCallBack");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [XZNetworkMonitor class]], @"info was wrong class in SCNetworkReachabilityCallBack");
    
    XZNetworkMonitor *monitor = (__bridge XZNetworkMonitor *)info;
    [monitor postNetworkReachabilityDidChangeNotification];
}

static NSString *CTRadioAccessTechnologyFromXZRadioAccessTechnology(XZRadioAccessTechnology technology) {
    switch (technology) {
        case XZRadioAccessTechnologyGPRS: // XZRadioAccessTechnology2G
            return CTRadioAccessTechnologyGPRS;
        case XZRadioAccessTechnologyEdge:
            return CTRadioAccessTechnologyEdge;
        case XZRadioAccessTechnologyCDMA1x:
            return CTRadioAccessTechnologyCDMA1x;
        case XZRadioAccessTechnologyWCDMA: // XZRadioAccessTechnology3G
            return CTRadioAccessTechnologyWCDMA;
        case XZRadioAccessTechnologyHSDPA:
            return CTRadioAccessTechnologyHSDPA;
        case XZRadioAccessTechnologyHSUPA:
            return CTRadioAccessTechnologyHSUPA;
        case XZRadioAccessTechnologyCDMAEVDORev0:
            return CTRadioAccessTechnologyCDMAEVDORev0;
        case XZRadioAccessTechnologyCDMAEVDORevA:
            return CTRadioAccessTechnologyCDMAEVDORevA;
        case XZRadioAccessTechnologyCDMAEVDORevB:
            return CTRadioAccessTechnologyCDMAEVDORevB;
        case XZRadioAccessTechnologyeHRPD:
            return CTRadioAccessTechnologyeHRPD;
        case XZRadioAccessTechnologyLTE: // XZRadioAccessTechnology4G
            return CTRadioAccessTechnologyLTE;
        default:
            return nil;
            break;
    }
}

static XZRadioAccessTechnology XZRadioAccessTechnologyForCTRadioAccessTechnology(NSString *technology) {
    for (XZRadioAccessTechnology type = XZRadioAccessTechnology2G; type <= XZRadioAccessTechnologyLTE; type++) {
        NSString *tmp = CTRadioAccessTechnologyFromXZRadioAccessTechnology(type);
        if ([tmp isEqualToString:technology]) {
            return type;
        }
    }
    return XZRadioAccessTechnologyUnknown;
}

static XZNetworkReachability XZNetworkReachabilityForReachableSCNetworkReachabilityFlags(SCNetworkReachabilityFlags flags) {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return XZNetworkReachabilityUnreachable;
    }
    
    // 网络可访问，使用移动网络
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        return XZNetworkReachabilityViaWWAN;
    }
    
    // 网络可访问，且不需要建立连接
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        return XZNetworkReachabilityViaWiFi;
    }
    
    // 网络可访问，需要建立连接，但网络连接是根据需要建立或网络连接是自动连接的
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        // 网络连接不需要手动连接
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            return XZNetworkReachabilityViaWiFi;
        }
    }
    return XZNetworkReachabilityUnreachable;
}
