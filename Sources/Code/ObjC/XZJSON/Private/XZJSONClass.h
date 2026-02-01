//
//  XZJSONClass.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZObjc.h>
#else
#import "XZObjc.h"
#endif

#ifdef _Unsafe
#undef _Unsafe
#endif
#define _Unsafe __unsafe_unretained

NS_ASSUME_NONNULL_BEGIN

/// 原生对象类型枚举。Foundation Class Type
typedef NS_ENUM (NSUInteger, XZJSONCocoaClass) {
    XZJSONCocoaClassUnknown = 0,
    XZJSONCocoaClassNSString,
    XZJSONCocoaClassNSMutableString,
    XZJSONCocoaClassNSValue,
    XZJSONCocoaClassNSNumber,
    XZJSONCocoaClassNSDecimalNumber,
    XZJSONCocoaClassNSData,
    XZJSONCocoaClassNSMutableData,
    XZJSONCocoaClassNSDate,
    XZJSONCocoaClassNSURL,
    XZJSONCocoaClassNSArray,
    XZJSONCocoaClassNSMutableArray,
    XZJSONCocoaClassNSSet,
    XZJSONCocoaClassNSMutableSet,
    XZJSONCocoaClassNSCountedSet,
    XZJSONCocoaClassNSOrderedSet,
    XZJSONCocoaClassNSMutableOrderedSet,
    XZJSONCocoaClassNSDictionary,
    XZJSONCocoaClassNSMutableDictionary,
};

@class XZJSONProperty;

/// 用于描述进行 JSON 模型化或序列化的 Class 信息。
@interface XZJSONClass : NSObject {
    @package
    /// 描述类基本信息的对象。
    XZObjcClass *_raw;
    
    /// 如果是，原生对象的类型。 Model class type.
    XZJSONCocoaClass _cocoaClass;
    
    /// 所有可模型化或序列化的属性的数量。
    NSUInteger _numberOfProperties;
    
    /// 按名称排序的，所有可模型化、序列化的属性的集合，包括从超类继承的。
    NSArray<XZJSONProperty *> *_sortedProperties;
    
    /// 以属性名为键的，所有可模型化、序列化属性组成的字典，包括从超类继承的。
    NSDictionary<NSString *, XZJSONProperty *> *_namedProperties;
    
    /// 使用 key 映射的属性。
    NSDictionary<NSString *, XZJSONProperty *> *_keyProperties;
    /// 使用 keyPath 映射的属性。
    NSArray<XZJSONProperty *> *_keyPathProperties;
    /// 使用 keyArray 映射的属性。
    NSArray<XZJSONProperty *> *_keyArrayProperties;
    
    /// 是否需要转发模型解析。
    BOOL _forwardsDecodingClass;
    /// 是否校验数据。
    BOOL _verifiesDecodingValue;
    
    /// 是否使用自定义模型化方法，即 -decodeFromJSONDictionary: 方法。
    BOOL _usesJSONDecodingMethod;
    /// 是否使用自定义序列化方法，即 -encodeIntoJSONDictionary: 方法。
    BOOL _usesJSONEncodingMethod;
    
    /// 是否使用自定义属性模型化方法，即 -JSONDecodeValue:forKey: 方法。
    BOOL _usesPropertyJSONDecodingMethod;
    /// 是否使用自定义属性序列化方法，即 -JSONEncodeValueForKey: 方法。
    BOOL _usesPropertyJSONEncodingMethod;
}

- (instancetype)init NS_UNAVAILABLE;
+ (nullable XZJSONClass *)classForClass:(nullable Class)class;

@end

FOUNDATION_STATIC_INLINE XZJSONCocoaClass XZJSONCocoaClassFromClass(Class aClass) {
    if (aClass == Nil) return XZJSONCocoaClassUnknown;
    if ([aClass isSubclassOfClass:[NSMutableString class]])        return XZJSONCocoaClassNSMutableString;
    if ([aClass isSubclassOfClass:[NSString class]])               return XZJSONCocoaClassNSString;
    if ([aClass isSubclassOfClass:[NSDecimalNumber class]])        return XZJSONCocoaClassNSDecimalNumber;
    if ([aClass isSubclassOfClass:[NSNumber class]])               return XZJSONCocoaClassNSNumber;
    if ([aClass isSubclassOfClass:[NSValue class]])                return XZJSONCocoaClassNSValue;
    if ([aClass isSubclassOfClass:[NSMutableData class]])          return XZJSONCocoaClassNSMutableData;
    if ([aClass isSubclassOfClass:[NSData class]])                 return XZJSONCocoaClassNSData;
    if ([aClass isSubclassOfClass:[NSDate class]])                 return XZJSONCocoaClassNSDate;
    if ([aClass isSubclassOfClass:[NSURL class]])                  return XZJSONCocoaClassNSURL;
    if ([aClass isSubclassOfClass:[NSMutableArray class]])         return XZJSONCocoaClassNSMutableArray;
    if ([aClass isSubclassOfClass:[NSArray class]])                return XZJSONCocoaClassNSArray;
    if ([aClass isSubclassOfClass:[NSMutableDictionary class]])    return XZJSONCocoaClassNSMutableDictionary;
    if ([aClass isSubclassOfClass:[NSDictionary class]])           return XZJSONCocoaClassNSDictionary;
    if ([aClass isSubclassOfClass:[NSCountedSet class]])           return XZJSONCocoaClassNSCountedSet;
    if ([aClass isSubclassOfClass:[NSMutableSet class]])           return XZJSONCocoaClassNSMutableSet;
    if ([aClass isSubclassOfClass:[NSSet class]])                  return XZJSONCocoaClassNSSet;
    if ([aClass isSubclassOfClass:[NSMutableOrderedSet class]])    return XZJSONCocoaClassNSMutableOrderedSet;
    if ([aClass isSubclassOfClass:[NSOrderedSet class]])           return XZJSONCocoaClassNSOrderedSet;
    return XZJSONCocoaClassUnknown;
}

NS_ASSUME_NONNULL_END
