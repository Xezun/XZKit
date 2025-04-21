//
//  XZObjcMethodDescriptor.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcTypeDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

/// 描述方法的对象。
///
/// Method information.
@interface XZObjcMethodDescriptor : NSObject <XZObjcDescriptor>

/// 方法原始值。 method opaque struct
@property (nonatomic, readonly) Method raw;
/// 方法名，一定为非空字符串。method name
@property (nonatomic, readonly) NSString *name;
/// 返回值类型编码。 return value's type
@property (nonatomic, readonly) XZObjcTypeDescriptor *type;
/// 方法标识。method's selector
@property (nonatomic, assign, readonly) SEL selector;
/// 方法实现。method's implementation
@property (nonatomic, assign, readonly) IMP implementation;
/// 方法参数和返回值类型编码。method's parameter and return types
@property (nonatomic, strong, readonly) NSString *encoding;
/// 参数类型编码。 array of arguments' type
@property (nonatomic, readonly, nullable) NSArray<XZObjcTypeDescriptor *> *argumentsTypes;

+ (nullable instancetype)descriptorWithMethod:(Method)method NS_SWIFT_NAME(init(_:));
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
