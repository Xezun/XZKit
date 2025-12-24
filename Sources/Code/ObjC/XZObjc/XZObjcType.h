//
//  XZObjcType.h
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

/// ANSI/ISO C 数据类型枚举。
///
/// 1.  [Objective-C Runtime Programming Guide - Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)
///
/// 2. [Objective-C Runtime Programming Guide - Declared Properties](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html)
typedef NS_ENUM(NSInteger, XZStdcType) {
    /// unknown type (among other things, this code is used for function pointers)
    /// > 匿名的结构体、共用体也会被编码为此名字，如 {?=ics}。
    XZStdcTypeUnknown          = _C_UNDEF,
    /// char
    XZStdcTypeChar             = _C_CHR,
    /// unsigned char
    XZStdcTypeUnsignedChar     = _C_UCHR,
    /// int
    XZStdcTypeInt              = _C_INT,
    /// unsigned int
    XZStdcTypeUnsignedInt      = _C_UINT,
    /// short
    XZStdcTypeShort            = _C_SHT,
    /// unsigned short
    XZStdcTypeUnsignedShort    = _C_USHT,
    /// long
    /// > 64位编译器会将 long 当作 long long 处理，在代码中，可使用 `XZ_LONG_IS_LLONG` 宏进行条件编译。
    XZStdcTypeLong             = _C_LNG,
    /// unsigned long
    /// > 64位编译器会将 unsigned long 当作 unsigned long long 处理，在代码中，可使用 `XZ_LONG_IS_LLONG` 宏进行条件编译。
    XZStdcTypeUnsignedLong     = _C_ULNG,
    XZStdcTypeInt128           = _C_INT128,
    XZStdcTypeUnsignedInt128   = _C_UINT128,
    /// long long
    XZStdcTypeLongLong         = _C_LNG_LNG,
    /// unsigned long long
    XZStdcTypeUnsignedLongLong = _C_ULNG_LNG,
    /// float
    XZStdcTypeFloat            = _C_FLT,
    /// double
    XZStdcTypeDouble           = _C_DBL,
    /// long double
    XZStdcTypeLongDouble       = _C_LNG_DBL,
    /// bool
    XZStdcTypeBool             = _C_BOOL,
    /// void
    XZStdcTypeVoid             = _C_VOID,
    /// C 字符串 char *
    XZStdcTypeString           = _C_CHARPTR,
    /// SEL
    XZStdcTypeSEL              = _C_SEL,
    /// pointer to type
    XZStdcTypePointer          = _C_PTR,
    /// C 数组
    XZStdcTypeArray            = _C_ARY_B,
    /// C 动态数组，Vector 
    XZStdcTypeVector           = _C_VECTOR,
    /// bit field of num bits
    /// ```objc
    /// // 位域结构体的成员的类型即为 bit field
    /// struct Bitfield {
    ///     int a:1;
    ///     char b:2;
    /// }
    /// ```
    XZStdcTypeBitField         = _C_BFLD,
    /// C 共用体
    XZStdcTypeUnion            = _C_UNION_B,
    /// C 结构体；类结构体，如 NSObject 为 {NSObject=#}
    XZStdcTypeStruct           = _C_STRUCT_B,
    /// 类对象的类型
    XZStdcTypeClass            = _C_CLASS,
    /// id. An object (whether statically typed or typed id)
    XZStdcTypeObject           = _C_ID,
};

/// 类型修饰符。Modifiers
typedef NS_OPTIONS(NSUInteger, XZStdcModifiers) {
    // modifiers for Variables
    XZStdcVariableModifiers = 0x3FF00,
    /// const
    XZStdcModifierConst  = 1 << 8,
    /// in
    XZStdcModifierIn     = 1 << 9,
    /// inout
    XZStdcModifierInout  = 1 << 10,
    /// out
    XZStdcModifierOut    = 1 << 11,
    /// bycopy
    XZStdcModifierByCopy = 1 << 12,
    /// byref
    XZStdcModifierByRef  = 1 << 13,
    /// oneway
    XZStdcModifierOneway      = 1 << 14,
    XZStdcModifierComplex     = 1 << 15,
    XZStdcModifierAtomic      = 1 << 16,
    XZStdcModifierGNURegister = 1 << 17,
    /// modifiers for Properties
    /// > 没有 assign/unsafe_unretained 修饰符，只能反向判断
    XZStdcPropertyModifiers = 0xFF00000,
    /// readonly
    XZStdcModifierReadonly  = 1 << (20 + 0),
    /// copy
    XZStdcModifierCopy      = 1 << (20 + 1),
    /// retain
    XZStdcModifierRetain    = 1 << (20 + 2),
    /// weak
    XZStdcModifierWeak      = 1 << (20 + 3),
    /// nonatomic
    XZStdcModifierNonatomic = 1 << (20 + 4),
    /// getter=
    XZStdcModifierGetter    = 1 << (20 + 5),
    /// setter=
    XZStdcModifierSetter    = 1 << (20 + 6),
    /// @dynamic
    XZStdcModifierDynamic   = 1 << (20 + 7),
};

@class XZObjcType;

@protocol XZObjcType <NSObject>
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) XZObjcType *type;
@end

/// 类型描述词，描述数据类型的对象。
///
/// 数据类型，通常也称为变量类型。在 objc 中，数据类型包括 c 基础类型，比如 int、float 等，和 NSObject 等对象类型，可通过 `@encoding(type)` 可将类型编码为字符串。
@interface XZObjcType : NSObject <XZObjcType>

/// 类型名称。
@property (nonatomic, readonly) NSString *name;

/// 返回自身。
@property (nonatomic, readonly) XZObjcType *type;

/// 类型。
@property (nonatomic, readonly) XZStdcType raw;

/// 类型修饰符。
@property (nonatomic, readonly) XZStdcModifiers modifiers;

/// 类型的原始值，即类型的编码。
@property (nonatomic, readonly) NSString *encoding;

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
/// +[XZObjcType setSize:sizeof(Type) alignment:_Alignof(Type) forType:\@encode(Type)];
/// // 或
/// XZObjcTypeRegister(Type);
/// ```
@property (nonatomic, readonly) size_t alignment;

/// 当前类型的成员类型，比如结构体、共用体的组成成员，或者指针类型（一般被认为是数组）的值的类型等。
@property (nonatomic, readonly, nullable) NSArray<XZObjcType *> *members;

/// 子类型，对象的类型。
///
/// 此属性仅在 `type` 为 `XZStdcTypeObject` 时才可能有值。
@property (nonatomic, readonly, nullable) Class subtype;

/// 对象类型遵循的协议。
///
/// 此属性仅在 `type` 为 `XZStdcTypeObject` 时才可能有值。
@property (nonatomic, readonly, nullable) NSArray<Protocol *> *protocols;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 构造类型描述。
/// > 因为类型不能直接作为参数，而枚举 XZObjcType 并不包含完整的类型信息，因此需要使用类型编码来构造。
/// - Parameter encoding: 类型编码，可以是类型编码中的子类型
+ (nullable XZObjcType *)typeWithEncoding:(const char * _Nullable)encoding NS_SWIFT_NAME(init(encoding:));

/// 构造类型描述符。
///
/// - Parameters:
///   - encoding: 类型编码
///   - modifiers: 修饰符，因为属性修饰符不包含在类型编码中，可通过此参数提供
+ (nullable XZObjcType *)typeWithEncoding:(const char * _Nullable)encoding modifiers:(XZStdcModifiers)modifiers NS_SWIFT_NAME(init(encoding:modifiers:));
+ (nullable XZObjcType *)typeWithEncoding:(const char * _Nullable)encoding size:(size_t)size alignment:(size_t)alignment NS_SWIFT_NAME(init(encoding:size:alignment:));

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
/// [XZObjcType setSize:sizeof(Foobar) alignment:_Alignof(Foobar) forType:\@encode(Foobar)];
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
+ (void)registerSize:(size_t)size alignment:(size_t)alignment forType:(const char *)objcType;

@end

/// @function XZObjcTypeRegister
/// 注册结构体、联合体的大小和内存对齐。
///
/// @param objcType
/// 类型，比如 CGRect 等
///
/// 注册结构体字节大小和对齐的宏，比如 XZObjcTypeRegister(CGRect) 。
#define XZObjcTypeRegister(objcType) [XZObjcType registerSize:sizeof(objcType) alignment:_Alignof(objcType) forType:@encode(objcType)]



NS_ASSUME_NONNULL_END
