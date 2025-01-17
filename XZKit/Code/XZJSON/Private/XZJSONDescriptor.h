//
//  XZJSONDescriptor.h
//  Pods
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>

/// Foundation Class Type
typedef NS_ENUM (NSUInteger, XZJSONEncodingNSType) {
    XZJSONEncodingUnknown = 0,
    XZJSONEncodingNSString,
    XZJSONEncodingNSMutableString,
    XZJSONEncodingNSValue,
    XZJSONEncodingNSNumber,
    XZJSONEncodingNSDecimalNumber,
    XZJSONEncodingNSData,
    XZJSONEncodingNSMutableData,
    XZJSONEncodingNSDate,
    XZJSONEncodingNSURL,
    XZJSONEncodingNSArray,
    XZJSONEncodingNSMutableArray,
    XZJSONEncodingNSDictionary,
    XZJSONEncodingNSMutableDictionary,
    XZJSONEncodingNSSet,
    XZJSONEncodingNSMutableSet,
};

/// Get the Foundation class type from property info.
FOUNDATION_STATIC_INLINE XZJSONEncodingNSType XZJSONEncodingNSTypeFromClass(Class aClass) {
    if (aClass == Nil) return XZJSONEncodingUnknown;
    if ([aClass isSubclassOfClass:[NSMutableString class]])        return XZJSONEncodingNSMutableString;
    if ([aClass isSubclassOfClass:[NSString class]])               return XZJSONEncodingNSString;
    if ([aClass isSubclassOfClass:[NSDecimalNumber class]])        return XZJSONEncodingNSDecimalNumber;
    if ([aClass isSubclassOfClass:[NSNumber class]])               return XZJSONEncodingNSNumber;
    if ([aClass isSubclassOfClass:[NSValue class]])                return XZJSONEncodingNSValue;
    if ([aClass isSubclassOfClass:[NSMutableData class]])          return XZJSONEncodingNSMutableData;
    if ([aClass isSubclassOfClass:[NSData class]])                 return XZJSONEncodingNSData;
    if ([aClass isSubclassOfClass:[NSDate class]])                 return XZJSONEncodingNSDate;
    if ([aClass isSubclassOfClass:[NSURL class]])                  return XZJSONEncodingNSURL;
    if ([aClass isSubclassOfClass:[NSMutableArray class]])         return XZJSONEncodingNSMutableArray;
    if ([aClass isSubclassOfClass:[NSArray class]])                return XZJSONEncodingNSArray;
    if ([aClass isSubclassOfClass:[NSMutableDictionary class]])    return XZJSONEncodingNSMutableDictionary;
    if ([aClass isSubclassOfClass:[NSDictionary class]])           return XZJSONEncodingNSDictionary;
    if ([aClass isSubclassOfClass:[NSMutableSet class]])           return XZJSONEncodingNSMutableSet;
    if ([aClass isSubclassOfClass:[NSSet class]])                  return XZJSONEncodingNSSet;
    return XZJSONEncodingUnknown;
}

/// Whether the type is c number.
FOUNDATION_STATIC_INLINE BOOL XZObjcTypeIsCNumber(XZObjcType type) {
    switch (type & XZObjcTypeMask) {
        case XZObjcTypeBool:
        case XZObjcTypeInt8:
        case XZObjcTypeUInt8:
        case XZObjcTypeInt16:
        case XZObjcTypeUInt16:
        case XZObjcTypeInt32:
        case XZObjcTypeUInt32:
        case XZObjcTypeInt64:
        case XZObjcTypeUInt64:
        case XZObjcTypeFloat:
        case XZObjcTypeDouble:
        case XZObjcTypeLongDouble:
            return YES;
        default:
            return NO;
    }
}
