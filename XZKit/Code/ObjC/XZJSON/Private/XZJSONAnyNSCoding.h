//
//  XZJSONAnyNSCoding.h
//  XZJSON
//
//  Created by 徐臻 on 2025/2/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZJSONAnyNSCoding : NSObject <NSCoding, NSSecureCoding>
@property (nonatomic, readonly, nullable) id base;
- (nullable instancetype)initWithBase:(id)base;
@end

NS_ASSUME_NONNULL_END
