//
//  XZObjcIvar.h
//  XZKit
//
//  Created by Xezun on 2025/1/26.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class XZObjcType;

NS_ASSUME_NONNULL_BEGIN

/// 对运行时结构体 `Ivar` 的封装。
@interface XZObjcIvar : NSObject

/// 成员变量原始值。 ivar opaque struct
@property (nonatomic, readonly) Ivar raw;
/// 实例变量的类型。Ivar's type
@property (nonatomic, readonly) XZObjcType *type;
/// 实例变量名。Ivar's name
@property (nonatomic, readonly) NSString *name;
/// 实例变量偏移。Ivar's offset
@property (nonatomic, readonly) ptrdiff_t offset;

+ (nullable instancetype)ivarWithIvar:(Ivar)ivar NS_SWIFT_NAME(init(_:));
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
