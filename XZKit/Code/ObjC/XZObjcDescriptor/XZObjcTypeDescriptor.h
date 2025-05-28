//
//  XZObjcTypeDescriptor.h
//  XZKit
//
//  Created by Xezun on 2021/2/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

#if LONG_BIT == __LLONG_WIDTH__
/// 在不同的架构中，long 的实际类型可能不同。
/// - 在 arm64 架构中，long 会被编译为 long long 类型，即会被编码为`q`而不是`l`。
/// > 官方文档相关说明：`l` is treated as a 32-bit quantity on 64-bit programs.
#define XZ_LONG_IS_LLONG 1
#else
#define XZ_LONG_IS_LLONG 0
#endif

/// 所有 ObjC 数据类型枚举。
///
/// 1. 官方文档 [Objective-C Runtime Programming Guide - Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)
///
/// 2. [Objective-C Runtime Programming Guide - Declared Properties](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html)
typedef NS_ENUM(NSUInteger, XZObjcType) {
    /// unknown type (among other things, this code is used for function pointers)
    /// > 匿名的结构体、共用体也会被编码为此名字，如 {?=ics}。
    XZObjcTypeUnknown          = '?',
    /// char
    XZObjcTypeChar             = 'c',
    /// unsigned char
    XZObjcTypeUnsignedChar     = 'C',
    /// int
    XZObjcTypeInt              = 'i',
    /// unsigned int
    XZObjcTypeUnsignedInt      = 'I',
    /// short
    XZObjcTypeShort            = 's',
    /// unsigned short
    XZObjcTypeUnsignedShort    = 'S',
    /// long
    /// > 64位编译器会将 long 当作 long long 处理，在代码中，可使用 `XZ_LONG_IS_LLONG` 宏进行条件编译。
    XZObjcTypeLong             = 'l',
    /// unsigned long
    /// > 64位编译器会将 unsigned long 当作 unsigned long long 处理，在代码中，可使用 `XZ_LONG_IS_LLONG` 宏进行条件编译。
    XZObjcTypeUnsignedLong     = 'L',
    /// long long
    XZObjcTypeLongLong         = 'q',
    /// unsigned long long
    XZObjcTypeUnsignedLongLong = 'Q',
    /// float
    XZObjcTypeFloat            = 'f',
    /// double
    XZObjcTypeDouble           = 'd',
    /// long double
    XZObjcTypeLongDouble       = 'D',
    /// bool
    XZObjcTypeBool             = 'B',
    /// void
    XZObjcTypeVoid             = 'v',
    /// C 字符串 char *
    XZObjcTypeString           = '*',
    /// 类对象的类型
    XZObjcTypeClass            = '#',
    /// SEL
    XZObjcTypeSEL              = ':',
    /// pointer to type
    XZObjcTypePointer          = '^',
    /// C 数组
    XZObjcTypeArray            = '[',
    /// bit field of num bits
    /// @code
    /// // 位域结构体的成员的类型即为 bit field
    /// struct Bitfield {
    ///     int a:1;
    ///     char b:2;
    /// }
    /// @endcode
    XZObjcTypeBitField         = 'b',
    /// C 共用体
    XZObjcTypeUnion            = '(',
    /// C 结构体；类结构体，如 NSObject 为 {NSObject=#}
    XZObjcTypeStruct           = '{',
    /// id. An object (whether statically typed or typed id)
    XZObjcTypeObject           = '@',
};

/// 类型修饰符。
typedef NS_OPTIONS(NSUInteger, XZObjcQualifiers) {
    // Qualifiers for Variables
    XZObjcVariableQualifiers = 0xFF00,
    /// const
    XZObjcQualifierConst  = 1 << 8,
    /// in
    XZObjcQualifierIn     = 1 << 9,
    /// inout
    XZObjcQualifierInout  = 1 << 10,
    /// out
    XZObjcQualifierOut    = 1 << 11,
    /// bycopy
    XZObjcQualifierByCopy = 1 << 12,
    /// byref
    XZObjcQualifierByRef  = 1 << 13,
    /// oneway
    XZObjcQualifierOneway = 1 << 14,
    /// Qualifier for Properties
    /// > 没有 assign/unsafe_unretained 修饰符，只能反向判断
    XZObjcPropertyQualifiers = 0xFF0000,
    /// readonly
    XZObjcQualifierReadonly  = 1 << 16,
    /// copy
    XZObjcQualifierCopy      = 1 << 17,
    /// retain
    XZObjcQualifierRetain    = 1 << 18,
    /// weak
    XZObjcQualifierWeak      = 1 << 20,
    /// nonatomic
    XZObjcQualifierNonatomic = 1 << 19,
    /// getter=
    XZObjcQualifierGetter    = 1 << 21,
    /// setter=
    XZObjcQualifierSetter    = 1 << 22,
    /// @dynamic
    XZObjcQualifierDynamic   = 1 << 23,
};

/// 类型描述词，描述数据类型的对象。
///
/// 数据类型，通常也称为变量类型。在 objc 中，数据类型包括 c 基础类型，比如 int、float 等，和 NSObject 等对象类型，可通过 `@encoding(type)` 可将类型编码为字符串。
@interface XZObjcTypeDescriptor : NSObject

/// 类型的原始值，即类型的编码。
@property (nonatomic, copy, readonly) NSString *raw;

/// 类型枚举。
@property (nonatomic, readonly) XZObjcType type;

/// 类型修饰符。
@property (nonatomic, readonly) XZObjcQualifiers qualifiers;

/// 类型名称。
@property (nonatomic, copy, readonly) NSString *name;

/// 大小，占用的空间大小，度量单位”字节byte“。
/// - 对于位域而言，此值并不一定准确。
@property (nonatomic, readonly) size_t size;

/// 大小，占用的空间大小，度量单位”位bit“。
/// > 对于结构体 sizeInBit 才是 bit field 成员类型的实际大小。
@property (nonatomic, readonly) size_t sizeInBit;

/// 字节对齐，度量单位“字节byte”。
///
/// 必须注册内存对齐的情形：
/// - 自定义了对齐的结构体和共用体。
/// - 包含 位域 的结构体或共用体。
///
/// > 使用 `#pragma pack (value)` 或 `__attribute__((packed))` 可以自定义字节对齐。
///
/// ```objc
/// +[XZObjcTypeDescriptor setSize:sizeof(Type) alignment:_Alignof(Type) forType:\@encode(Type)];
/// // 或
/// XZObjcTypeRegister(Type);
/// ```
@property (nonatomic, readonly) size_t alignment;

/// 当前类型的成员类型，比如结构体、共用体的组成成员，或者指针类型（一般被认为是数组）的值的类型等。
@property (nonatomic, copy, readonly, nullable) NSArray<XZObjcTypeDescriptor *> *members;

/// 子类型，对象的类型。
///
/// 此属性仅在 `type` 为 `XZObjcTypeObject` 时才可能有值。
@property (nonatomic, readonly, nullable) Class subtype;

/// 对象类型遵循的协议。
///
/// 此属性仅在 `type` 为 `XZObjcTypeObject` 时才可能有值。
@property (nonatomic, copy, readonly, nullable) NSArray<Protocol *> *protocols;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 构造类型描述。
/// > 因为类型不能直接作为参数，而枚举 XZObjcType 并不包含完整的类型信息，因此需要使用类型编码来构造。
/// - Parameter objcType: 类型编码，可以是类型编码中的子类型
+ (nullable XZObjcTypeDescriptor *)descriptorForObjcType:(const char * _Nullable)objcType NS_SWIFT_NAME(init(for:));

/// 构造类型描述符。
///
/// - Parameters:
///   - objcType: 类型编码
///   - qualifiers: 修饰符，因为属性修饰符不包含在类型编码中，可通过此参数提供
+ (nullable XZObjcTypeDescriptor *)descriptorForObjcType:(const char * _Nullable)objcType qualifiers:(XZObjcQualifiers)qualifiers NS_SWIFT_NAME(init(for:qualifiers:));

/// 设置结构体类型的大小和字节对齐值。
///
/// ```objc
/// // 第一个 Foobar 为结构体的真实名字，是 TypeEncoding 捕获的名字；
/// // 第二个 Foobar 为结构体的别名，不能用在类型编码中。
/// typedef struct Foobar {
///     int a;
///     float b;
/// } Foobar;
/// // 注册该自定义类型的 size 和 alignment
/// [XZObjcTypeDescriptor setSize:sizeof(Foobar) alignment:_Alignof(Foobar) forType:\@encode(Foobar)];
/// // 或者使用宏
/// XZObjcTypeRegister(Foobar);
/// ```
///
/// - 类型的名字必须是原始名字，非 typedef 定义的别名。
/// - 只有别名的结构体，类型编码变成一个匿名的结构体，如 {?=if} 。
///
/// - Parameters:
///   - size: 大小
///   - alignment: 对齐方式
///   - objcType: 结构体类型编码
+ (void)setSize:(size_t)size alignment:(size_t)alignment forObjcType:(const char *)objcType;

@end

/// 注册结构体字节大小和对齐的宏，比如 XZObjcTypeRegister(CGRect) 。
#define XZObjcTypeRegister(objcType) [XZObjcTypeDescriptor setSize:sizeof(objcType) alignment:_Alignof(objcType) forObjcType:@encode(objcType)]

@protocol XZObjcDescriptor <NSObject>
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) XZObjcTypeDescriptor *type;
@end

NS_ASSUME_NONNULL_END
