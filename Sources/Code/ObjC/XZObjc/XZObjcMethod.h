//
//  XZObjcMethod.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class XZObjcType;

NS_ASSUME_NONNULL_BEGIN

/// 描述方法的对象。
///
/// Method information.
@interface XZObjcMethod : NSObject

/// 方法原始值。 method opaque struct
@property (nonatomic, readonly) Method raw;
/// 方法名，一定为非空字符串。method name
@property (nonatomic, readonly) NSString *name;
/// 返回值的数据类型。 return value's type
@property (nonatomic, readonly) XZObjcType *type;
/// 方法标识。method's selector
@property (nonatomic, readonly) SEL selector;
/// 方法实现。method's implementation
@property (nonatomic, assign, readonly) IMP implementation;
/// 方法参数和返回值类型编码。method's parameter and return types
@property (nonatomic, copy, readonly) NSString *encoding;
/// 参数类型编码。 array of arguments' type
/// 
/// 按照 objc 的规则，参数为 `(receiver, SEL, ...)`
@property (nonatomic, readonly, nullable) NSArray<XZObjcType *> *arguments;

+ (nullable instancetype)methodWithMethod:(Method)method NS_SWIFT_NAME(init(_:));
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
