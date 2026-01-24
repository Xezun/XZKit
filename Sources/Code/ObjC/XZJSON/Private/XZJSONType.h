//
//  XZJSONType.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>
#import "XZObjcType.h"

#ifdef _Unsafe
#undef _Unsafe
#endif
#define _Unsafe __unsafe_unretained

/// 原生对象类型枚举。Foundation Class Type
typedef NS_ENUM (NSUInteger, XZJSONCocoaType) {
    XZJSONCocoaTypeUnknown = 0,
    XZJSONCocoaTypeNSString,
    XZJSONCocoaTypeNSMutableString,
    XZJSONCocoaTypeNSValue,
    XZJSONCocoaTypeNSNumber,
    XZJSONCocoaTypeNSDecimalNumber,
    XZJSONCocoaTypeNSData,
    XZJSONCocoaTypeNSMutableData,
    XZJSONCocoaTypeNSDate,
    XZJSONCocoaTypeNSURL,
    XZJSONCocoaTypeNSArray,
    XZJSONCocoaTypeNSMutableArray,
    XZJSONCocoaTypeNSSet,
    XZJSONCocoaTypeNSMutableSet,
    XZJSONCocoaTypeNSCountedSet,
    XZJSONCocoaTypeNSOrderedSet,
    XZJSONCocoaTypeNSMutableOrderedSet,
    XZJSONCocoaTypeNSDictionary,
    XZJSONCocoaTypeNSMutableDictionary,
};

/// Get the Foundation class type from property info.
FOUNDATION_STATIC_INLINE XZJSONCocoaType XZJSONCocoaTypeFromClass(Class aClass) {
    if (aClass == Nil) return XZJSONCocoaTypeUnknown;
    if ([aClass isSubclassOfClass:[NSMutableString class]])        return XZJSONCocoaTypeNSMutableString;
    if ([aClass isSubclassOfClass:[NSString class]])               return XZJSONCocoaTypeNSString;
    if ([aClass isSubclassOfClass:[NSDecimalNumber class]])        return XZJSONCocoaTypeNSDecimalNumber;
    if ([aClass isSubclassOfClass:[NSNumber class]])               return XZJSONCocoaTypeNSNumber;
    if ([aClass isSubclassOfClass:[NSValue class]])                return XZJSONCocoaTypeNSValue;
    if ([aClass isSubclassOfClass:[NSMutableData class]])          return XZJSONCocoaTypeNSMutableData;
    if ([aClass isSubclassOfClass:[NSData class]])                 return XZJSONCocoaTypeNSData;
    if ([aClass isSubclassOfClass:[NSDate class]])                 return XZJSONCocoaTypeNSDate;
    if ([aClass isSubclassOfClass:[NSURL class]])                  return XZJSONCocoaTypeNSURL;
    if ([aClass isSubclassOfClass:[NSMutableArray class]])         return XZJSONCocoaTypeNSMutableArray;
    if ([aClass isSubclassOfClass:[NSArray class]])                return XZJSONCocoaTypeNSArray;
    if ([aClass isSubclassOfClass:[NSMutableDictionary class]])    return XZJSONCocoaTypeNSMutableDictionary;
    if ([aClass isSubclassOfClass:[NSDictionary class]])           return XZJSONCocoaTypeNSDictionary;
    if ([aClass isSubclassOfClass:[NSCountedSet class]])           return XZJSONCocoaTypeNSCountedSet;
    if ([aClass isSubclassOfClass:[NSMutableSet class]])           return XZJSONCocoaTypeNSMutableSet;
    if ([aClass isSubclassOfClass:[NSSet class]])                  return XZJSONCocoaTypeNSSet;
    if ([aClass isSubclassOfClass:[NSMutableOrderedSet class]])    return XZJSONCocoaTypeNSMutableOrderedSet;
    if ([aClass isSubclassOfClass:[NSOrderedSet class]])           return XZJSONCocoaTypeNSOrderedSet;
    return XZJSONCocoaTypeUnknown;
}


