//
//  XZObjcType.h
//  XZKit
//
//  Created by Xezun on 2021/2/12.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

#if LONG_BIT == __LLONG_WIDTH__
/// 在不同的架构中，long 的实际类型可能不同。
/// - 在 arm64 架构中，long 会被编译为 long long 类型，即会被编码为`q`而不是`l`。
/// > 官方文档相关说明：`l` is treated as a 32-bit quantity on 64-bit programs.
#define XZ_TYPE_LLONG_IS_LONG 1
#else
#define XZ_TYPE_LLONG_IS_LONG 0
#endif

/// 标准 C 数据类型枚举。
///
/// 1.  [Objective-C Runtime Programming Guide - Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)
///
/// 2. [Objective-C Runtime Programming Guide - Declared Properties](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html)
typedef NS_ENUM(NSUInteger, XZStdcType) {
    /// unknown type (among other things, this code is used for function pointers)
    /// > 匿名的结构体、共用体也会被编码为此名字，如 {?=ics}。
    XZStdcTypeUnknown          = _C_UNDEF,
    /// char，有符号单字符型。
    XZStdcTypeChar             = _C_CHR,
    /// unsigned char，无符号单字符型。
    XZStdcTypeUnsignedChar     = _C_UCHR,
    /// int，有符号整型。
    XZStdcTypeInt              = _C_INT,
    /// unsigned int，无符号整型。
    XZStdcTypeUnsignedInt      = _C_UINT,
    /// short，有符号短整型。
    XZStdcTypeShort            = _C_SHT,
    /// unsigned short，无符号短整型。
    XZStdcTypeUnsignedShort    = _C_USHT,
    /// long，有符号长整型。
    ///
    /// 64位编译器会将 long 当作 long long 处理，在代码中，可使用 ``XZ_TYPE_LLONG_IS_LONG`` 宏进行条件编译。
    XZStdcTypeLong             = _C_LNG,
    /// unsigned long，无符号长整型。
    ///
    /// 64位编译器会将 unsigned long 当作 unsigned long long 处理，在代码中，可使用 ``XZ_TYPE_LLONG_IS_LONG`` 宏进行条件编译。
    XZStdcTypeUnsignedLong     = _C_ULNG,
    /// 有符号 128 位整型。当前平台不支持。
    XZStdcTypeInt128           = _C_INT128,
    /// 无符号 128 位整型。当前平台不支持。
    XZStdcTypeUnsignedInt128   = _C_UINT128,
    /// long long，有符号超长整型。
    XZStdcTypeLongLong         = _C_LNG_LNG,
    /// unsigned long long，无符号超长整型。
    XZStdcTypeUnsignedLongLong = _C_ULNG_LNG,
    /// float，单精度浮点型。
    XZStdcTypeFloat            = _C_FLT,
    /// double，双精度浮点型。
    XZStdcTypeDouble           = _C_DBL,
    /// long double，长双精度浮点型。
    XZStdcTypeLongDouble       = _C_LNG_DBL,
    /// bool，布尔型。
    XZStdcTypeBool             = _C_BOOL,
    /// void，空型。
    XZStdcTypeVoid             = _C_VOID,
    /// char[n]，C 字符串。
    XZStdcTypeString           = _C_CHARPTR,
    /// SEL，选择器。
    XZStdcTypeSelector         = _C_SEL,
    /// C 指针。pointer to type
    XZStdcTypePointer          = _C_PTR,
    /// C 动态数组，Vector
    XZStdcTypeVector           = _C_VECTOR,
    /// C 数组
    XZStdcTypeArray            = _C_ARY_B,
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

enum {
    /// 数据类型掩码。
    XZStdcTypeMask             = 0x00000FF,
    /// 变量修饰符掩码。
    XZStdcVariableModifierMask = 0x003FF00,
    /// 属性修饰符掩码。
    XZStdcPropertyModifierMask = 0x3FC0000,
    /// 属性或变量修饰符掩码。
    XZStdcModifierMask = XZStdcPropertyModifierMask | XZStdcVariableModifierMask,
};

/// 变量或属性的类型修饰符。
///
/// 可使用 NSUInteger 将类型、修饰符融合在一起，通过掩码来获取指定部分的值。
///
/// > 没有 assign/unsafe_unretained 修饰符，只能反向判断。
typedef NS_OPTIONS(NSUInteger, XZStdcModifiers) {
    /// const
    XZStdcModifierConst       = 1 << (8 + 0),
    /// in
    XZStdcModifierIn          = 1 << (8 + 1),
    /// inout
    XZStdcModifierInout       = 1 << (8 + 2),
    /// out
    XZStdcModifierOut         = 1 << (8 + 3),
    /// bycopy
    XZStdcModifierByCopy      = 1 << (8 + 4),
    /// byref
    XZStdcModifierByRef       = 1 << (8 + 5),
    /// oneway
    XZStdcModifierOneway      = 1 << (8 + 6),
    /// complex
    XZStdcModifierComplex     = 1 << (8 + 7),
    /// atomic
    XZStdcModifierAtomic      = 1 << (8 + 8),
    /// GNU register
    XZStdcModifierGNURegister = 1 << (8 + 9),
    // 以下为用于修饰属性的修饰符。
    /// readonly
    XZStdcModifierReadonly    = 1 << (8 + 10),
    /// copy
    XZStdcModifierCopy        = 1 << (8 + 11),
    /// retain
    XZStdcModifierRetain      = 1 << (8 + 12),
    /// weak
    XZStdcModifierWeak        = 1 << (8 + 13),
    /// nonatomic
    XZStdcModifierNonatomic   = 1 << (8 + 14),
    /// getter=
    XZStdcModifierGetter      = 1 << (8 + 15),
    /// setter=
    XZStdcModifierSetter      = 1 << (8 + 16),
    /// dynamic
    XZStdcModifierDynamic     = 1 << (8 + 17),
};


/// 常用 C 复合数据类型：结构体。
typedef NS_ENUM(NSUInteger, XZStdcStructType) {
    XZStdcStructTypeUnknown = 0,
    XZStdcStructTypeCGRect,
    XZStdcStructTypeCGSize,
    XZStdcStructTypeCGPoint,
    XZStdcStructTypeCGVector,
    XZStdcStructTypeCGAffineTransform,
    XZStdcStructTypeNSDirectionalEdgeInsets,
    XZStdcStructTypeNSRange,
    XZStdcStructTypeUIEdgeInsets,
    XZStdcStructTypeUIOffset
};

/// 描述数据类型的对象。
///
/// 数据类型，通常也称为变量类型。在 objc 中，数据类型包括 c 基础类型，比如 int、float 等，和 NSObject 等对象类型，可通过 `@encoding(type)` 可将类型编码为字符串。
@interface XZObjcType : NSObject

/// 类型。改名为 type 或 prototype
@property (nonatomic, readonly) XZStdcType type;

/// 通用名称。
@property (nonatomic, readonly) NSString *name;

/// 类型的原始值，即类型的编码。
@property (nonatomic, readonly) NSString *encoding;

/// 集合类型：C数组、位域、指针。
@property (nonatomic, readonly, nullable) XZObjcType *elementType;
/// 集合类型的容量。非集合类型返回零。
@property (nonatomic, readonly) NSInteger capacity;

/// 复合类型的实际类型枚举。
@property (nonatomic, readonly) XZStdcStructType structType;
/// 复合类型的成员组成。
@property (nonatomic, readonly) NSArray<XZObjcType *> *members;

/// 对象类型的类对象类型。classType
@property (nonatomic, readonly, nullable) Class classType;
/// 对象类型遵循的协议。
@property (nonatomic, readonly) NSArray<Protocol *> *protocols;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 获取 C 类型的描述。
/// - Parameter type: 标准 C 类型枚举，若参数值不合法，此方法将抛出异常。
+ (XZObjcType *)typeForType:(XZStdcType)type;

/// 构造类型描述。
///
/// 可以通过 `\@encode(type-name)` 语法对类型进行编码。
///
/// ```objc
/// [XZObjcType typeForEncoding:\@encode(NSInteger)];
/// ```
///
/// - Parameter encoding: 类型编码，或者复合类型编码中的子类型。
+ (nullable XZObjcType *)typeForEncoding:(const char * _Nullable)encoding NS_SWIFT_NAME(init(for:));

@end

/// 通过结构体的名称获取结构体的类型。
/// - Parameter name: 结构体名。
FOUNDATION_EXPORT XZStdcStructType XZStdcStructTypeFromString(NSString *name);

/// 将 XZStdcType 枚举值转换为对应的字符串。
/// - Parameter type: XZStdcType 枚举值
FOUNDATION_EXPORT NSString *NSStringFromXZStdcType(XZStdcType type);

/// 将 XZStdcModifiers 中包含的修饰符，以数组的形式，转化为字符串。
/// - Parameter modifiers: XZStdcModifiers 修饰符
FOUNDATION_EXPORT NSString *NSStringFromXZStdcModifiers(XZStdcModifiers modifiers);

/// 如果 type 是已知结构体类型，返回其对应的类型，否则返回 XZStdcStructTypeUnknown 类型。
/// - Parameter type: XZObjcType 类型对象
FOUNDATION_STATIC_INLINE XZStdcStructType XZStdcStructTypeFromType(XZObjcType *type) {
    if (type.type == XZStdcTypeStruct) {
        return XZStdcStructTypeFromString(type.name);
    }
    return XZStdcStructTypeUnknown;
}



NS_ASSUME_NONNULL_END
