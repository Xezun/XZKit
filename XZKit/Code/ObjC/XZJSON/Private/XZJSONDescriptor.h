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
    XZJSONClassTypeNSSet,
    XZJSONClassTypeNSMutableSet,
    XZJSONClassTypeNSCountedSet,
    XZJSONClassTypeNSOrderedSet,
    XZJSONClassTypeNSMutableOrderedSet,
    XZJSONClassTypeNSDictionary,
    XZJSONClassTypeNSMutableDictionary,
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
    if ([aClass isSubclassOfClass:[NSCountedSet class]])           return XZJSONClassTypeNSCountedSet;
    if ([aClass isSubclassOfClass:[NSMutableSet class]])           return XZJSONClassTypeNSMutableSet;
    if ([aClass isSubclassOfClass:[NSSet class]])                  return XZJSONClassTypeNSSet;
    if ([aClass isSubclassOfClass:[NSMutableOrderedSet class]])    return XZJSONClassTypeNSMutableOrderedSet;
    if ([aClass isSubclassOfClass:[NSOrderedSet class]])           return XZJSONClassTypeNSOrderedSet;
    return XZJSONClassTypeUnknown;
}


typedef NS_ENUM(NSUInteger, XZJSONStructType) {
    XZJSONStructTypeUnknown = 0,
    XZJSONStructTypeCGRect,
    XZJSONStructTypeCGSize,
    XZJSONStructTypeCGPoint,
    XZJSONStructTypeUIEdgeInsets,
    XZJSONStructTypeCGVector,
    XZJSONStructTypeCGAffineTransform,
    XZJSONStructTypeNSDirectionalEdgeInsets,
    XZJSONStructTypeUIOffset
};

FOUNDATION_STATIC_INLINE XZJSONStructType XZJSONStructTypeFromString(NSString *name) {
    if ([name isEqualToString:@"CGRect"]) {
        return XZJSONStructTypeCGRect;
    }
    if ([name isEqualToString:@"CGSize"]) {
        return XZJSONStructTypeCGSize;
    }
    if ([name isEqualToString:@"CGPoint"]) {
        return XZJSONStructTypeCGPoint;
    }
    if ([name isEqualToString:@"UIEdgeInsets"]) {
        return XZJSONStructTypeUIEdgeInsets;
    }
    if ([name isEqualToString:@"CGVector"]) {
        return XZJSONStructTypeCGVector;
    }
    if ([name isEqualToString:@"CGAffineTransform"]) {
        return XZJSONStructTypeCGAffineTransform;
    }
    if ([name isEqualToString:@"NSDirectionalEdgeInsets"]) {
        return XZJSONStructTypeNSDirectionalEdgeInsets;
    }
    if ([name isEqualToString:@"UIOffset"]) {
        return XZJSONStructTypeUIOffset;
    }
    return XZJSONStructTypeUnknown;
}

FOUNDATION_STATIC_INLINE XZJSONStructType XZJSONStructTypeFromType(XZObjcTypeDescriptor *type) {
    switch (type.type) {
        case XZObjcTypeStruct:
            return XZJSONStructTypeFromString(type.name);
        default:
            return XZJSONStructTypeUnknown;
    }
}


