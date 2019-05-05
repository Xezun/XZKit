//
//  XZLocationHelper.m
//  XZKit
//
//  Created by mlibai on 2016/11/11.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZLocationHelper.h"

typedef NS_ENUM(NSInteger, XZLocationAuthorizationType) {
    XZLocationAuthorizationTypeWhenInUse,
    XZLocationAuthorizationTypeAlways
};

@interface XZLocationHelper () <CLLocationManagerDelegate>


@property (nonatomic, strong, readonly) CLLocationManager *locationManager;

@property (nonatomic) BOOL isRequestingAuthorization;
@property (nonatomic, strong) NSMutableArray<XZLocationAuthorizationRequestCompletion> *authorizationRequestCompletions;

@end

@implementation XZLocationHelper

- (void)requestWhenInUseAuthorization:(XZLocationAuthorizationRequestCompletion)completion {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
#endif
        [self requestAuthorizationOnMainThread:(XZLocationAuthorizationTypeWhenInUse) completion:completion];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    } else {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusNotDetermined:
                completion(kCLAuthorizationStatusAuthorized);
                break;
            default:
                completion(status);
                break;
        }
    }
#endif
}

- (void)requestAlwaysAuthorization:(XZLocationAuthorizationRequestCompletion)completion {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
#endif
        [self requestAuthorizationOnMainThread:(XZLocationAuthorizationTypeAlways) completion:completion];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    } else {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusNotDetermined:
                completion(kCLAuthorizationStatusAuthorized);
                break;
            default:
                completion(status);
                break;
        }
    }
#endif
}

#pragma mark - private methods

- (void)requestAuthorizationOnMainThread:(XZLocationAuthorizationType)authorization completion:(XZLocationAuthorizationRequestCompletion)completion {
    if (completion != nil) {
        [self.authorizationRequestCompletions addObject:completion];
    }
    if (!_isRequestingAuthorization) {
        _isRequestingAuthorization = YES;
        [self requestAuthorizationOnMainThread:authorization];
    }
}

- (void)requestAuthorizationOnMainThread:(XZLocationAuthorizationType)authorization {
    if ([NSThread isMainThread]) {
        [self requestAuthorization:authorization];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestAuthorization:authorization];
        });
    }
}

- (void)requestAuthorization:(XZLocationAuthorizationType)authorization {
    switch (authorization) {
        case XZLocationAuthorizationTypeAlways:
            [self.locationManager requestAlwaysAuthorization];
            break;
        case XZLocationAuthorizationTypeWhenInUse:
            [self.locationManager requestWhenInUseAuthorization];
            break;
    }
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self locationManager:manager completeWithStatus:(kCLAuthorizationStatusDenied)];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self locationManager:manager completeWithStatus:status];
}

- (void)locationManager:(CLLocationManager *)manager completeWithStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusNotDetermined) {
        _isRequestingAuthorization = NO;
        for (XZLocationAuthorizationRequestCompletion completion in _authorizationRequestCompletions) {
            completion(status);
        }
        [_authorizationRequestCompletions removeAllObjects];
    }
}

#pragma mark - getters & setters

- (NSMutableArray<XZLocationAuthorizationRequestCompletion> *)authorizationRequestCompletions {
    if (_authorizationRequestCompletions != nil) {
        return _authorizationRequestCompletions;
    }
    _authorizationRequestCompletions = [[NSMutableArray alloc] init];
    return _authorizationRequestCompletions;
}

@synthesize locationManager = _locationManager;

- (CLLocationManager *)locationManager {
    if (_locationManager != nil) {
        return _locationManager;
    }
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    return _locationManager;
}

@end
