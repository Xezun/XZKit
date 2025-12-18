//
//  XZOBJCType.h
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
/// 1. 官方文档 [Objective-C Runtime Programming Guide - Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)
///
/// 2. [Objective-C Runtime Programming Guide - Declared Properties](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html)
typedef NS_ENUM(NSInteger, XZISOCType) {
    /// unknown type (among other things, this code is used for function pointers)
    /// > 匿名的结构体、共用体也会被编码为此名字，如 {?=ics}。
    XZISOCTypeUnknown          = _C_UNDEF,
    /// char
    XZISOCTypeChar             = _C_CHR,
    /// unsigned char
    XZISOCTypeUnsignedChar     = _C_UCHR,
    /// int
    XZISOCTypeInt              = _C_INT,
    /// unsigned int
    XZISOCTypeUnsignedInt      = _C_UINT,
    /// short
    XZISOCTypeShort            = _C_SHT,
    /// unsigned short
    XZISOCTypeUnsignedShort    = _C_USHT,
    /// long
    /// > 64位编译器会将 long 当作 long long 处理，在代码中，可使用 `XZ_LONG_IS_LLONG` 宏进行条件编译。
    XZISOCTypeLong             = _C_LNG,
    /// unsigned long
    /// > 64位编译器会将 unsigned long 当作 unsigned long long 处理，在代码中，可使用 `XZ_LONG_IS_LLONG` 宏进行条件编译。
    XZISOCTypeUnsignedLong     = _C_ULNG,
    XZISOCTypeInt128           = _C_INT128,
    XZISOCTypeUnsignedInt128   = _C_UINT128,
    /// long long
    XZISOCTypeLongLong         = _C_LNG_LNG,
    /// unsigned long long
    XZISOCTypeUnsignedLongLong = _C_ULNG_LNG,
    /// float
    XZISOCTypeFloat            = _C_FLT,
    /// double
    XZISOCTypeDouble           = _C_DBL,
    /// long double
    XZISOCTypeLongDouble       = _C_LNG_DBL,
    /// bool
    XZISOCTypeBool             = _C_BOOL,
    /// void
    XZISOCTypeVoid             = _C_VOID,
    /// C 字符串 char *
    XZISOCTypeString           = _C_CHARPTR,
    /// SEL
    XZISOCTypeSEL              = _C_SEL,
    /// pointer to type
    XZISOCTypePointer          = _C_PTR,
    /// C 数组
    XZISOCTypeArray            = _C_ARY_B,
    /// C 动态数组，Vector 
    XZISOCTypeVector           = _C_VECTOR,
    /// bit field of num bits
    /// @code
    /// // 位域结构体的成员的类型即为 bit field
    /// struct Bitfield {
    ///     int a:1;
    ///     char b:2;
    /// }
    /// @endcode
    XZISOCTypeBitField         = _C_BFLD,
    /// C 共用体
    XZISOCTypeUnion            = _C_UNION_B,
    /// C 结构体；类结构体，如 NSObject 为 {NSObject=#}
    XZISOCTypeStruct           = _C_STRUCT_B,
    /// 类对象的类型
    XZISOCTypeClass            = _C_CLASS,
    /// id. An object (whether statically typed or typed id)
    XZISOCTypeObject           = _C_ID,
};

/// 类型修饰符。Modifiers
typedef NS_OPTIONS(NSUInteger, XZISOCModifiers) {
    // modifiers for Variables
    XZISOCVariableModifiers = 0x3FF00,
    /// const
    XZISOCModifierConst  = 1 << 8,
    /// in
    XZISOCModifierIn     = 1 << 9,
    /// inout
    XZISOCModifierInout  = 1 << 10,
    /// out
    XZISOCModifierOut    = 1 << 11,
    /// bycopy
    XZISOCModifierByCopy = 1 << 12,
    /// byref
    XZISOCModifierByRef  = 1 << 13,
    /// oneway
    XZISOCModifierOneway      = 1 << 14,
    XZISOCModifierComplex     = 1 << 15,
    XZISOCModifierAtomic      = 1 << 16,
    XZISOCModifierGNURegister = 1 << 17,
    /// modifiers for Properties
    /// > 没有 assign/unsafe_unretained 修饰符，只能反向判断
    XZISOCPropertyModifiers = 0xFF00000,
    /// readonly
    XZISOCModifierReadonly  = 1 << (20 + 0),
    /// copy
    XZISOCModifierCopy      = 1 << (20 + 1),
    /// retain
    XZISOCModifierRetain    = 1 << (20 + 2),
    /// weak
    XZISOCModifierWeak      = 1 << (20 + 3),
    /// nonatomic
    XZISOCModifierNonatomic = 1 << (20 + 4),
    /// getter=
    XZISOCModifierGetter    = 1 << (20 + 5),
    /// setter=
    XZISOCModifierSetter    = 1 << (20 + 6),
    /// @dynamic
    XZISOCModifierDynamic   = 1 << (20 + 7),
};

@class XZOBJCType;

@protocol XZOBJCType <NSObject>
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) XZOBJCType *type;
@end

/// 类型描述词，描述数据类型的对象。
///
/// 数据类型，通常也称为变量类型。在 objc 中，数据类型包括 c 基础类型，比如 int、float 等，和 NSObject 等对象类型，可通过 `@encoding(type)` 可将类型编码为字符串。
@interface XZOBJCType : NSObject <XZOBJCType>

/// 类型名称。
@property (nonatomic, readonly) NSString *name;

/// 返回自身。
@property (nonatomic, readonly) XZOBJCType *type;

/// 类型。
@property (nonatomic, readonly) XZISOCType raw;

/// 类型修饰符。
@property (nonatomic, readonly) XZISOCModifiers modifiers;

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
/// +[XZOBJCType setSize:sizeof(Type) alignment:_Alignof(Type) forType:\@encode(Type)];
/// // 或
/// XZOBJCTypeRegister(Type);
/// ```
@property (nonatomic, readonly) size_t alignment;

/// 当前类型的成员类型，比如结构体、共用体的组成成员，或者指针类型（一般被认为是数组）的值的类型等。
@property (nonatomic, readonly, nullable) NSArray<XZOBJCType *> *members;

/// 子类型，对象的类型。
///
/// 此属性仅在 `type` 为 `XZISOCTypeObject` 时才可能有值。
@property (nonatomic, readonly, nullable) Class subtype;

/// 对象类型遵循的协议。
///
/// 此属性仅在 `type` 为 `XZISOCTypeObject` 时才可能有值。
@property (nonatomic, readonly, nullable) NSArray<Protocol *> *protocols;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 构造类型描述。
/// > 因为类型不能直接作为参数，而枚举 XZOBJCType 并不包含完整的类型信息，因此需要使用类型编码来构造。
/// - Parameter encoding: 类型编码，可以是类型编码中的子类型
+ (nullable XZOBJCType *)typeWithEncoding:(const char * _Nullable)encoding NS_SWIFT_NAME(init(encoding:));

/// 构造类型描述符。
///
/// - Parameters:
///   - encoding: 类型编码
///   - modifiers: 修饰符，因为属性修饰符不包含在类型编码中，可通过此参数提供
+ (nullable XZOBJCType *)typeWithEncoding:(const char * _Nullable)encoding modifiers:(XZISOCModifiers)modifiers NS_SWIFT_NAME(init(encoding:modifiers:));
+ (nullable XZOBJCType *)typeWithEncoding:(const char * _Nullable)encoding size:(size_t)size alignment:(size_t)alignment NS_SWIFT_NAME(init(encoding:size:alignment:));

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
/// [XZOBJCType setSize:sizeof(Foobar) alignment:_Alignof(Foobar) forType:\@encode(Foobar)];
/// // 或者使用宏
/// XZOBJCTypeRegister(Foobar);
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

/// @function XZOBJCTypeRegister
/// 注册结构体、联合体的大小和内存对齐。
///
/// @param objcType
/// 类型，比如 CGRect 等
///
/// 注册结构体字节大小和对齐的宏，比如 XZOBJCTypeRegister(CGRect) 。
#define XZOBJCTypeRegister(objcType) [XZOBJCType registerSize:sizeof(objcType) alignment:_Alignof(objcType) forType:@encode(objcType)]



NS_ASSUME_NONNULL_END
