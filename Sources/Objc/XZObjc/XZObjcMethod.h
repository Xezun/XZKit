//
//  XZObjcMethod.h
//  XZKit
//
//  Created by Xezun on 2025/1/26.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class XZObjcType;

NS_ASSUME_NONNULL_BEGIN

/// 对运行时结构体 `Method` 的封装。
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
/// 方法参数的类型。
///
/// 按照 objc 的规则，运行时会把方法编译为`method(receiver, SEL, ...)`的形式，即前两个参数是固定的，此属性不包含这两个参数。
@property (nonatomic, readonly, nullable) NSArray<XZObjcType *> *arguments;

+ (nullable instancetype)methodWithMethod:(Method)method NS_SWIFT_NAME(init(_:));
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
