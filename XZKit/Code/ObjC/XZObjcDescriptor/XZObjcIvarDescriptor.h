//
//  XZObjcIvarDescriptor.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcTypeDescriptor.h"
@import ObjectiveC;

@class XZObjcTypeDescriptor;

NS_ASSUME_NONNULL_BEGIN

/// 描述实例的成员变量的对象。
///
/// Instance variable information.
@interface XZObjcIvarDescriptor : NSObject <XZObjcDescriptor>

/// 成员变量原始值。 ivar opaque struct
@property (nonatomic, readonly) Ivar raw;
/// 变量类型。Ivar's type
@property (nonatomic, readonly) XZObjcTypeDescriptor *type;
/// 变量名。Ivar's name
@property (nonatomic, readonly) NSString *name;
/// 成员变量偏移。Ivar's offset
@property (nonatomic, readonly) ptrdiff_t offset;

+ (nullable instancetype)descriptorWithIvar:(Ivar)ivar NS_SWIFT_NAME(init(_:));
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
