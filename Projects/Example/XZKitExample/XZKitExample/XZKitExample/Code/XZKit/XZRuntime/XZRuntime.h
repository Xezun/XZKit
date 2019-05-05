//
//  XZRuntime.h
//  XZKit
//
//  Created by mlibai on 2016/11/12.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  获取当前时间戳，精确到微秒。
 *
 *  @return 单位为秒，小数点后为微秒。
 */
FOUNDATION_EXTERN NSTimeInterval xz_timestamp(void);

/**
 *  输出信息到控制台，末尾自动换行。不附加任何其它信息。
 *
 *  @param format 输出格式
 *  @param ...    参数列表
 */
FOUNDATION_EXTERN void XZPrint(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);
FOUNDATION_EXTERN void XZPrintv(NSString *format, va_list args) NS_FORMAT_FUNCTION(1, 0);

#undef NSLog
#define NSLog(format, ...) XZPrint(@"%@:%d [%.03f] %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], (int)__LINE__, (double)xz_timestamp(), [NSString stringWithFormat:format, ##__VA_ARGS__])

#ifdef DEBUG
#define XZLog NSLog
FOUNDATION_EXTERN void xz_debug_available(void (^statements)(void)); // 仅在 DEBUG 模式下编译运行的代码块。
#else
#define XZLog(...)
#define xz_debug_available(...)
#endif

/**
 判断当前 iOS 系统版本是否在某一范围内。
 
 @param ios_version_min 最低版本，包含
 @param ios_version_max 最高版本，包含
 @return 如果当前版本在范围内，返回 YES ；否则返回 NO 。
 */
FOUNDATION_EXTERN BOOL xz_ios_availability(CGFloat ios_version_min, CGFloat ios_version_max);
FOUNDATION_EXTERN void xz_objc_exchange_methods_implementations(Class class1, SEL selector1, Class class2, SEL selector2);
FOUNDATION_EXTERN void xz_trim(char *str, char c);
FOUNDATION_EXTERN void xz_class_property_enumerator(Class aClass, void (^enumerator)(objc_property_t property_t, NSInteger index, BOOL *stop));


typedef NS_ENUM(NSInteger, XZDataType) {
    XZDataType_char = 0,
    XZDataType_int,
    XZDataType_short,
    XZDataType_long,
    XZDataType_long_long,
    XZDataType_unsigned_char, // 5
    XZDataType_unsigned_int,
    XZDataType_unsigned_short,
    XZDataType_unsigned_long,
    XZDataType_unsigned_long_long,
    XZDataType_float, // 10
    XZDataType_double,
    XZDataType_bool,
    XZDataType_void,
    XZDataType_char_v,
    XZDataType_id, // 15
    XZDataType_Class,
    XZDataType_SEL,
    
    XZDataType_array,
    XZDataType_structure,
    XZDataType_union,
    XZDataType_bnum,
    XZDataType_type_v,
    XZDataType_func, // or unknown
    
    // structure
    XZDataType_CGRect,
    XZDataType_CGSize,
    XZDataType_CGPoint,
    XZDataType_CGVector,
    XZDataType_CGAffineTransform,
    XZDataType_UIEdgeInsets,
    XZDataType_UIOffset,
    
    XZDataTypeUnknown,
    XZDataTypeCount = XZDataTypeUnknown
};

FOUNDATION_EXTERN NSString *NSStringFromXZDataType(XZDataType dataType);
FOUNDATION_EXTERN const char * const XZDataTypeEncoding[XZDataTypeCount];
FOUNDATION_EXTERN XZDataType XZDataTypeFromEncoding(const char *type_encoding);

typedef NS_ENUM(NSInteger, XZDataTypeSubtype) {
    XZDataTypeSubtypeNone, // no subtype
    XZDataTypeSubtypeInstance,
    XZDataTypeSubtypeProtocol
};


NS_ASSUME_NONNULL_END
