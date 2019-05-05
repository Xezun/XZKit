//
//  XZLocationHelper.h
//  XZKit
//
//  Created by mlibai on 2016/11/11.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^XZLocationAuthorizationRequestCompletion)(CLAuthorizationStatus status);

@interface XZLocationHelper : NSObject

- (void)requestAlwaysAuthorization:(XZLocationAuthorizationRequestCompletion)completion NS_AVAILABLE_IOS(4_2);
- (void)requestWhenInUseAuthorization:(XZLocationAuthorizationRequestCompletion)completion NS_AVAILABLE_IOS(4_2);

@end
