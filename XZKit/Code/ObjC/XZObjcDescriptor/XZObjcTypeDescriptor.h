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

/// Get the type from a Type-Encoding string.
///
/// 1. 官方文档 [Objective-C Runtime Programming Guide - Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)
///
/// 2. [Objective-C Runtime Programming Guide - Declared Properties](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html)
typedef NS_ENUM(NSUInteger, XZObjcType) {
    /// char
    XZObjcTypeChar             = 'c',
    /// int
    XZObjcTypeInt              = 'i',
    /// short
    XZObjcTypeShort            = 's',
    /// long
    /// @note l is treated as a 32-bit quantity on 64-bit programs.
    XZObjcTypeLong             = 'l',
    /// long long
    XZObjcTypeLongLong         = 'q',
    /// unsigned char
    XZObjcTypeUnsignedChar     = 'C',
    /// unsigned int
    XZObjcTypeUnsignedInt      = 'I',
    /// unsigned short
    XZObjcTypeUnsignedShort    = 'S',
    /// unsigned long
    XZObjcTypeUnsignedLong     = 'L',
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
    /// id. An object (whether statically typed or typed id)
    XZObjcTypeObject           = '@',
    /// 类对象的类型
    XZObjcTypeClass            = '#',
    /// SEL
    XZObjcTypeSEL              = ':',
    /// C 数组
    XZObjcTypeArray            = '[',
    /// C 结构体；类结构体，如 NSObject 为 {NSObject=#}
    XZObjcTypeStruct           = '{',
    /// C 共用体
    XZObjcTypeUnion            = '(',
    /// bit field of num bits
    /// @code
    /// // 位域结构体的成员的类型即为 bit field
    /// struct Bitfield {
    ///     int a:1;
    ///     char b:2;
    /// }
    /// @endcode
    XZObjcTypeBitField         = 'b',
    /// pointer to type
    XZObjcTypePointer          = '^',
    /// unknown type (among other things, this code is used for function pointers)
    /// @note 匿名的结构体、共用体也会被编码为此名字，如 {?=ics}。
    XZObjcTypeUnknown          = '?',
};

/// 类型修饰符。
typedef NS_OPTIONS(NSUInteger, XZObjcQualifiers) {
    // Qualifiers for Variables
    XZObjcVariableQualifiers = 0xFF00,
    XZObjcQualifierConst  = 1 << 8,     /// const
    XZObjcQualifierIn     = 1 << 9,     /// in
    XZObjcQualifierInout  = 1 << 10,    /// inout
    XZObjcQualifierOut    = 1 << 11,    /// out
    XZObjcQualifierByCopy = 1 << 12,    /// bycopy
    XZObjcQualifierByRef  = 1 << 13,    /// byref
    XZObjcQualifierOneway = 1 << 14,    /// oneway
    // Qualifier for Properties
    XZObjcPropertyQualifiers = 0xFF0000,
    XZObjcQualifierReadonly  = 1 << 16,   /// readonly
    // 没有 assign/unsafe_unretained 修饰符，只能反向判断
    XZObjcQualifierCopy      = 1 << 17,   /// copy
    XZObjcQualifierRetain    = 1 << 18,   /// retain
    XZObjcQualifierWeak      = 1 << 20,   /// weak
    XZObjcQualifierNonatomic = 1 << 19,   /// nonatomic
    XZObjcQualifierGetter    = 1 << 21,   /// getter=
    XZObjcQualifierSetter    = 1 << 22,   /// setter=
    XZObjcQualifierDynamic   = 1 << 23,   /// @dynamic
};

/// 描述通过 `@encoding(type)` 所表述的 Type Encoding 详细信息。
@interface XZObjcTypeDescriptor : NSObject

/// 类型。
@property (nonatomic, readonly) XZObjcType type;

/// 修饰符。
@property (nonatomic, readonly) XZObjcQualifiers qualifiers;

/// 名称
@property (nonatomic, copy, readonly) NSString *name;

/// 大小，占用的空间大小，度量单位”字节byte“。
@property (nonatomic, readonly) size_t size;

/// 大小，占用的空间大小，度量单位”位bit“。
/// > 对于结构体 sizeInBit 才是 bit field 成员类型的实际大小。
@property (nonatomic, readonly) size_t sizeInBit;

/// 字节对齐，度量单位“字节byte”。
///
/// 使用 `#pragma pack (value)` 或 `__attribute__((packed))` 可以自定义字节对齐。
/// 所以对于自定义类型，特别是非默认字节对齐的类型，需要先注册对齐方式，否则此属性值可能并不一定准确。
/// ```objc
/// +[XZObjcTypeDescriptor setSize:alignment:forType:]
/// ```
@property (nonatomic, readonly) size_t alignment;

/// 当前对象所描述的类型的编码。
@property (nonatomic, copy, readonly) NSString *encoding;

/// 当前类型的成员类型，仅对于结构体、共用体等。
@property (nonatomic, copy, readonly, nullable) NSArray<XZObjcTypeDescriptor *> *members;

/// 对象类型的子类型。
@property (nonatomic, readonly, nullable) Class subtype;

/// 类型为对象时，对象已实现的协议。
@property (nonatomic, copy, readonly, nullable) NSArray<Protocol *> *protocols;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 构造类型描述。
/// @note 因为类型不能直接作为参数，而枚举 XZObjcType 并不包含完整的类型信息，因此需要使用类型编码来构造。
/// @param typeEncoding 类型编码，可以是类型编码中的子类型
+ (nullable XZObjcTypeDescriptor *)descriptorForTypeEncoding:(const char *)typeEncoding;

/// 构造类型描述符。
/// @param typeEncoding 类型编码
/// @param qualifiers 一般为属性修饰符，因为属性修饰符不包含在类型编码中，可通过此参数提供
+ (nullable XZObjcTypeDescriptor *)descriptorForTypeEncoding:(const char *)typeEncoding qualifiers:(XZObjcQualifiers)qualifiers;

/// 设置结构体类型的大小和字节对齐值。
/// @code
/// // 第一个 Foobar 为结构体的真实名字，是 TypeEncoding 捕获的名字；
/// // 第二个 Foobar 为结构体的别名，不能用在类型编码中。
/// typedef struct Foobar {
///     int a;
///     float b;
/// } Foobar;
/// // 注册该自定义类型的 size 和 alignment
/// [XZObjcTypeDescriptor setSize:sizeof(Foobar) alignment:_Alignof(Foobar) forType:@encode(Foobar)];
/// // 或者使用宏
/// XZObjcTypeRegister(Foobar);
/// @endcode
///
/// @note 类型的名字必须是原始名字，非 typedef 定义的别名。
/// @note 只有别名的结构体，类型编码变成一个匿名的结构体，如 {?=if} 。
///
/// @param size 大小
/// @param alignment 对齐方式
/// @param typeEncoding 结构体类型编码
+ (void)setSize:(size_t)size alignment:(size_t)alignment forType:(const char *)typeEncoding;

@end

/// 注册结构体字节大小和对齐的宏，比如 XZObjcTypeRegister(CGRect) 。
#define XZObjcTypeRegister(aType) [XZObjcTypeDescriptor setSize:sizeof(aType) alignment:_Alignof(aType) forType:@encode(aType)]

@protocol XZObjcDescriptor <NSObject>
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) XZObjcTypeDescriptor *type;
@end

NS_ASSUME_NONNULL_END
