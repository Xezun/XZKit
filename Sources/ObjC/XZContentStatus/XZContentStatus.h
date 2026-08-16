//
//  XZContentStatus.h
//  XZKit
//
//  Created by Mac on 2026/8/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_REFINED_FOR_SWIFT @interface XZContentStatus : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *rawValue;
@property (nonatomic, strong, readonly, nullable) id configuration;
- (instancetype)initWithRawValue:(NSString *)rawValue configuration:(nullable id)configuration NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (class, readonly) XZContentStatus *empty;
@property (class, readonly) XZContentStatus *error;
@property (class, readonly) XZContentStatus *loading;
@property (class, readonly) XZContentStatus *unreachable;
@property (class, readonly) XZContentStatus *unavailable;

@end

NS_ASSUME_NONNULL_END
