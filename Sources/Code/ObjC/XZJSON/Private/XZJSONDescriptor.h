//
//  XZJSONDescriptor.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>
#import "XZObjcTypeDescriptor.h"

/// 原生对象类型枚举。Foundation Class Type
typedef NS_ENUM (NSUInteger, XZJSONFoundationClassType) {
    XZJSONFoundationClassTypeUnknown = 0,
    XZJSONFoundationClassTypeNSString,
    XZJSONFoundationClassTypeNSMutableString,
    XZJSONFoundationClassTypeNSValue,
    XZJSONFoundationClassTypeNSNumber,
    XZJSONFoundationClassTypeNSDecimalNumber,
    XZJSONFoundationClassTypeNSData,
    XZJSONFoundationClassTypeNSMutableData,
    XZJSONFoundationClassTypeNSDate,
    XZJSONFoundationClassTypeNSURL,
    XZJSONFoundationClassTypeNSArray,
    XZJSONFoundationClassTypeNSMutableArray,
    XZJSONFoundationClassTypeNSSet,
    XZJSONFoundationClassTypeNSMutableSet,
    XZJSONFoundationClassTypeNSCountedSet,
    XZJSONFoundationClassTypeNSOrderedSet,
    XZJSONFoundationClassTypeNSMutableOrderedSet,
    XZJSONFoundationClassTypeNSDictionary,
    XZJSONFoundationClassTypeNSMutableDictionary,
};

/// Get the Foundation class type from property info.
FOUNDATION_STATIC_INLINE XZJSONFoundationClassType XZJSONFoundationClassTypeFromClass(Class aClass) {
    if (aClass == Nil) return XZJSONFoundationClassTypeUnknown;
    if ([aClass isSubclassOfClass:[NSMutableString class]])        return XZJSONFoundationClassTypeNSMutableString;
    if ([aClass isSubclassOfClass:[NSString class]])               return XZJSONFoundationClassTypeNSString;
    if ([aClass isSubclassOfClass:[NSDecimalNumber class]])        return XZJSONFoundationClassTypeNSDecimalNumber;
    if ([aClass isSubclassOfClass:[NSNumber class]])               return XZJSONFoundationClassTypeNSNumber;
    if ([aClass isSubclassOfClass:[NSValue class]])                return XZJSONFoundationClassTypeNSValue;
    if ([aClass isSubclassOfClass:[NSMutableData class]])          return XZJSONFoundationClassTypeNSMutableData;
    if ([aClass isSubclassOfClass:[NSData class]])                 return XZJSONFoundationClassTypeNSData;
    if ([aClass isSubclassOfClass:[NSDate class]])                 return XZJSONFoundationClassTypeNSDate;
    if ([aClass isSubclassOfClass:[NSURL class]])                  return XZJSONFoundationClassTypeNSURL;
    if ([aClass isSubclassOfClass:[NSMutableArray class]])         return XZJSONFoundationClassTypeNSMutableArray;
    if ([aClass isSubclassOfClass:[NSArray class]])                return XZJSONFoundationClassTypeNSArray;
    if ([aClass isSubclassOfClass:[NSMutableDictionary class]])    return XZJSONFoundationClassTypeNSMutableDictionary;
    if ([aClass isSubclassOfClass:[NSDictionary class]])           return XZJSONFoundationClassTypeNSDictionary;
    if ([aClass isSubclassOfClass:[NSCountedSet class]])           return XZJSONFoundationClassTypeNSCountedSet;
    if ([aClass isSubclassOfClass:[NSMutableSet class]])           return XZJSONFoundationClassTypeNSMutableSet;
    if ([aClass isSubclassOfClass:[NSSet class]])                  return XZJSONFoundationClassTypeNSSet;
    if ([aClass isSubclassOfClass:[NSMutableOrderedSet class]])    return XZJSONFoundationClassTypeNSMutableOrderedSet;
    if ([aClass isSubclassOfClass:[NSOrderedSet class]])           return XZJSONFoundationClassTypeNSOrderedSet;
    return XZJSONFoundationClassTypeUnknown;
}


typedef NS_ENUM(NSUInteger, XZJSONFoundationStructType) {
    XZJSONFoundationStructTypeUnknown = 0,
    XZJSONFoundationStructTypeCGRect,
    XZJSONFoundationStructTypeCGSize,
    XZJSONFoundationStructTypeCGPoint,
    XZJSONFoundationStructTypeUIEdgeInsets,
    XZJSONFoundationStructTypeCGVector,
    XZJSONFoundationStructTypeCGAffineTransform,
    XZJSONFoundationStructTypeNSDirectionalEdgeInsets,
    XZJSONFoundationStructTypeUIOffset
};

FOUNDATION_STATIC_INLINE XZJSONFoundationStructType XZJSONFoundationStructTypeFromString(NSString *name) {
    if ([name isEqualToString:@"CGRect"]) {
        return XZJSONFoundationStructTypeCGRect;
    }
    if ([name isEqualToString:@"CGSize"]) {
        return XZJSONFoundationStructTypeCGSize;
    }
    if ([name isEqualToString:@"CGPoint"]) {
        return XZJSONFoundationStructTypeCGPoint;
    }
    if ([name isEqualToString:@"UIEdgeInsets"]) {
        return XZJSONFoundationStructTypeUIEdgeInsets;
    }
    if ([name isEqualToString:@"CGVector"]) {
        return XZJSONFoundationStructTypeCGVector;
    }
    if ([name isEqualToString:@"CGAffineTransform"]) {
        return XZJSONFoundationStructTypeCGAffineTransform;
    }
    if ([name isEqualToString:@"NSDirectionalEdgeInsets"]) {
        return XZJSONFoundationStructTypeNSDirectionalEdgeInsets;
    }
    if ([name isEqualToString:@"UIOffset"]) {
        return XZJSONFoundationStructTypeUIOffset;
    }
    return XZJSONFoundationStructTypeUnknown;
}

FOUNDATION_STATIC_INLINE XZJSONFoundationStructType XZJSONFoundationStructTypeFromType(XZObjcTypeDescriptor *type) {
    switch (type.type) {
        case XZObjcTypeStruct:
            return XZJSONFoundationStructTypeFromString(type.name);
        default:
            return XZJSONFoundationStructTypeUnknown;
    }
}


