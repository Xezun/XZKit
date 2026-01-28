//
//  XZJSONPrivateDefines.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>
#import "XZObjc.h"

#ifdef _Unsafe
#undef _Unsafe
#endif
#define _Unsafe __unsafe_unretained

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

/// Get the Foundation class type from property info.
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


