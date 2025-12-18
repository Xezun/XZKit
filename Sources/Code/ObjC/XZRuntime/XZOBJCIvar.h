//
//  XZOBJCIvar.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import <objc/message.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZOBJCType.h>
#else
#import "XZISOCTypeDescriptor.h"
#endif

@class XZOBJCType;

NS_ASSUME_NONNULL_BEGIN

/// 描述实例的成员变量的对象。
///
/// Instance variable information.
@interface XZOBJCIvar : NSObject <XZOBJCType>

/// 成员变量原始值。 ivar opaque struct
@property (nonatomic, readonly) Ivar raw;
/// 变量类型。Ivar's type
@property (nonatomic, readonly) XZOBJCType *type;
/// 变量名。Ivar's name
@property (nonatomic, readonly) NSString *name;
/// 成员变量偏移。Ivar's offset
@property (nonatomic, readonly) ptrdiff_t offset;

+ (nullable instancetype)descriptorForIvar:(Ivar)ivar NS_SWIFT_NAME(init(for:));
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
