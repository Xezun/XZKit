//
//  XZJSONDescriptor.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>

/// 原生对象类型枚举。Foundation Class Type
typedef NS_ENUM (NSUInteger, XZJSONClassType) {
    XZJSONClassTypeUnknown = 0,
    XZJSONClassTypeNSString,
    XZJSONClassTypeNSMutableString,
    XZJSONClassTypeNSValue,
    XZJSONClassTypeNSNumber,
    XZJSONClassTypeNSDecimalNumber,
    XZJSONClassTypeNSData,
    XZJSONClassTypeNSMutableData,
    XZJSONClassTypeNSDate,
    XZJSONClassTypeNSURL,
    XZJSONClassTypeNSArray,
    XZJSONClassTypeNSMutableArray,
    XZJSONClassTypeNSDictionary,
    XZJSONClassTypeNSMutableDictionary,
    XZJSONClassTypeNSSet,
    XZJSONClassTypeNSMutableSet,
};

/// Get the Foundation class type from property info.
FOUNDATION_STATIC_INLINE XZJSONClassType XZJSONClassTypeFromClass(Class aClass) {
    if (aClass == Nil) return XZJSONClassTypeUnknown;
    if ([aClass isSubclassOfClass:[NSMutableString class]])        return XZJSONClassTypeNSMutableString;
    if ([aClass isSubclassOfClass:[NSString class]])               return XZJSONClassTypeNSString;
    if ([aClass isSubclassOfClass:[NSDecimalNumber class]])        return XZJSONClassTypeNSDecimalNumber;
    if ([aClass isSubclassOfClass:[NSNumber class]])               return XZJSONClassTypeNSNumber;
    if ([aClass isSubclassOfClass:[NSValue class]])                return XZJSONClassTypeNSValue;
    if ([aClass isSubclassOfClass:[NSMutableData class]])          return XZJSONClassTypeNSMutableData;
    if ([aClass isSubclassOfClass:[NSData class]])                 return XZJSONClassTypeNSData;
    if ([aClass isSubclassOfClass:[NSDate class]])                 return XZJSONClassTypeNSDate;
    if ([aClass isSubclassOfClass:[NSURL class]])                  return XZJSONClassTypeNSURL;
    if ([aClass isSubclassOfClass:[NSMutableArray class]])         return XZJSONClassTypeNSMutableArray;
    if ([aClass isSubclassOfClass:[NSArray class]])                return XZJSONClassTypeNSArray;
    if ([aClass isSubclassOfClass:[NSMutableDictionary class]])    return XZJSONClassTypeNSMutableDictionary;
    if ([aClass isSubclassOfClass:[NSDictionary class]])           return XZJSONClassTypeNSDictionary;
    if ([aClass isSubclassOfClass:[NSMutableSet class]])           return XZJSONClassTypeNSMutableSet;
    if ([aClass isSubclassOfClass:[NSSet class]])                  return XZJSONClassTypeNSSet;
    return XZJSONClassTypeUnknown;
}


