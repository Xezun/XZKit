//
//  XZObjCTypeDescriptor.h
//  XZKit
//
//  Created by Xezun on 2021/2/12.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZKitDefines.h>
#import <UIKit/UIKit.h>
#import <XZKit/XZGeometry.h>

NS_ASSUME_NONNULL_BEGIN

/// 官方文档 [Objective-C Runtime Programming Guide - Type Encodings]
/// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
typedef NS_ENUM(NSUInteger, XZObjCType) {
    /// A char
    XZObjCTypeChar             = 'c',
    /// An int
    XZObjCTypeInt              = 'i',
    /// A short
    XZObjCTypeShort            = 's',
    /// A long
    /// @note l is treated as a 32-bit quantity on 64-bit programs.
    XZObjCTypeLong             = 'l',
    /// A long long
    XZObjCTypeLongLong         = 'q',
    /// An unsigned char
    XZObjCTypeUnsignedChar     = 'C',
    /// An unsigned int
    XZObjCTypeUnsignedInt      = 'I',
    /// An unsigned short
    XZObjCTypeUnsignedShort    = 'S',
    /// An unsigned long
    XZObjCTypeUnsignedLong     = 'L',
    /// An unsigned long long
    XZObjCTypeUnsignedLongLong = 'Q',
    /// A float
    XZObjCTypeFloat            = 'f',
    /// A double
    XZObjCTypeDouble           = 'd',
    /// A bool
    XZObjCTypeBool             = 'B',
    /// A void
    XZObjCTypeVoid             = 'v',
    /// C 字符串 char *
    XZObjCTypeString           = '*',
    /// id. An object (whether statically typed or typed id)
    XZObjCTypeObject           = '@',
    /// 类对象的类型
    XZObjCTypeClass            = '#',
    /// SEL
    XZObjCTypeSEL              = ':',
    /// C 数组
    XZObjCTypeArray            = '[',
    /// C 结构体；类结构体，如 NSObject 为 {NSObject=#}
    XZObjCTypeStruct           = '{',
    /// C 共用体
    XZObjCTypeUnion            = '(',
    /// A bit field of num bits
    /// @code
    /// // 位域结构体的成员的类型即为 bit field
    /// struct Bitfield {
    ///     int a:1;
    ///     char b:2;
    /// }
    /// @endcode
    XZObjCTypeBitField         = 'b',
    /// A pointer to type
    XZObjCTypePointer          = '^',
    /// An unknown type (among other things, this code is used for function pointers)
    /// @note 匿名的结构体、共用体也会被编码为此名字，如 {?=ics}。
    XZObjCTypeUnknown          = '?',
} NS_SWIFT_NAME(ObjCType);

/// 描述通过 `\@encoding(type)` 所表述的 Type Encoding 详细信息。
XZ_FINAL_CLASS
@interface XZObjCTypeDescriptor : NSObject

/// 类型
@property (nonatomic, readonly) XZObjCType type;

/// 名称
@property (nonatomic, copy, readonly) NSString *name;

/// 大小，占用的空间大小，度量单位”字节byte“。
@property (nonatomic, readonly) size_t size;

/// 大小，占用的空间大小，度量单位”位bit“。
/// @note 对于结构体 sizeInBit 才是 bit field 成员类型的实际大小。
@property (nonatomic, readonly) size_t sizeInBit;

/// 字节对齐，度量单位“字节byte”。
/// @note 由于使用 `#pragma pack (value)` 或 `__attribute__((packed))` 可以自定义字节对齐,
///       所以对于自定义类型，特别是非默认字节对齐的类型，需要先通过方法
///       `+[XZObjCTypeDescriptor setSize:alignment:forType:]`
///       注册对齐方式，否则此属性值可能并不一定准确。
@property (nonatomic, readonly) size_t alignment;

/// 当前对象所描述的类型的编码。
@property (nonatomic, copy, readonly) NSString *encoding;

/// 当前类型的子类型，仅对于结构体、共用体等。
@property (nonatomic, copy, readonly) NSArray<XZObjCTypeDescriptor *> *subtypes;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 构造类型描述。
/// @note 因为类型不能直接作为参数，而枚举 XZObjCType 并不包含完整的类型信息，因此需要使用类型编码来构造。
/// @param typeEncoding 类型编码
+ (XZObjCTypeDescriptor *)descriptorWithTypeEncoding:(const char *)typeEncoding;

/// 设置结构体类型的大小和字节对齐值。
/// @code
/// // 第一个 Example 为结构体的真实名字，是 TypeEncoding 捕获的名字；
/// // 第二个 Example 为结构体的别名，不能用在类型编码中。
/// typedef struct Example {
///     int a;
///     float b;
/// } Example;
/// // 注册该自定义类型的 size 和 alignment
/// [XZObjCTypeDescriptor setSize:sizeof(Example) alignment:_Alignof(Example) forType:@"Example"];
/// @endcode
///
/// @note 类型的名字必须是原始名字，非 typedef 定义的别名。
/// @note 只有别名的结构体，类型编码变成一个匿名的结构体，如 {?=if} 。
///
/// @param size 大小
/// @param alignment 对齐方式
/// @param name 自定义类型的名字，只有结构体
+ (void)setSize:(size_t)size alignment:(size_t)alignment forType:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
