//
//  XZJSONDescriptor.h
//  XZJSON
//
//  Created by Xezun on 2024/9/29.
//

#import <Foundation/Foundation.h>
#import "XZObjcTypeDescriptor.h"

/// 原生对象类型枚举。Foundation Class Type
typedef NS_ENUM (NSUInteger, XZJSONFoundationClass) {
    XZJSONFoundationClassUnknown = 0,
    XZJSONFoundationClassNSString,
    XZJSONFoundationClassNSMutableString,
    XZJSONFoundationClassNSValue,
    XZJSONFoundationClassNSNumber,
    XZJSONFoundationClassNSDecimalNumber,
    XZJSONFoundationClassNSData,
    XZJSONFoundationClassNSMutableData,
    XZJSONFoundationClassNSDate,
    XZJSONFoundationClassNSURL,
    XZJSONFoundationClassNSArray,
    XZJSONFoundationClassNSMutableArray,
    XZJSONFoundationClassNSSet,
    XZJSONFoundationClassNSMutableSet,
    XZJSONFoundationClassNSCountedSet,
    XZJSONFoundationClassNSOrderedSet,
    XZJSONFoundationClassNSMutableOrderedSet,
    XZJSONFoundationClassNSDictionary,
    XZJSONFoundationClassNSMutableDictionary,
};

/// Get the Foundation class type from property info.
FOUNDATION_STATIC_INLINE XZJSONFoundationClass XZJSONFoundationClassFromClass(Class aClass) {
    if (aClass == Nil) return XZJSONFoundationClassUnknown;
    if ([aClass isSubclassOfClass:[NSMutableString class]])        return XZJSONFoundationClassNSMutableString;
    if ([aClass isSubclassOfClass:[NSString class]])               return XZJSONFoundationClassNSString;
    if ([aClass isSubclassOfClass:[NSDecimalNumber class]])        return XZJSONFoundationClassNSDecimalNumber;
    if ([aClass isSubclassOfClass:[NSNumber class]])               return XZJSONFoundationClassNSNumber;
    if ([aClass isSubclassOfClass:[NSValue class]])                return XZJSONFoundationClassNSValue;
    if ([aClass isSubclassOfClass:[NSMutableData class]])          return XZJSONFoundationClassNSMutableData;
    if ([aClass isSubclassOfClass:[NSData class]])                 return XZJSONFoundationClassNSData;
    if ([aClass isSubclassOfClass:[NSDate class]])                 return XZJSONFoundationClassNSDate;
    if ([aClass isSubclassOfClass:[NSURL class]])                  return XZJSONFoundationClassNSURL;
    if ([aClass isSubclassOfClass:[NSMutableArray class]])         return XZJSONFoundationClassNSMutableArray;
    if ([aClass isSubclassOfClass:[NSArray class]])                return XZJSONFoundationClassNSArray;
    if ([aClass isSubclassOfClass:[NSMutableDictionary class]])    return XZJSONFoundationClassNSMutableDictionary;
    if ([aClass isSubclassOfClass:[NSDictionary class]])           return XZJSONFoundationClassNSDictionary;
    if ([aClass isSubclassOfClass:[NSCountedSet class]])           return XZJSONFoundationClassNSCountedSet;
    if ([aClass isSubclassOfClass:[NSMutableSet class]])           return XZJSONFoundationClassNSMutableSet;
    if ([aClass isSubclassOfClass:[NSSet class]])                  return XZJSONFoundationClassNSSet;
    if ([aClass isSubclassOfClass:[NSMutableOrderedSet class]])    return XZJSONFoundationClassNSMutableOrderedSet;
    if ([aClass isSubclassOfClass:[NSOrderedSet class]])           return XZJSONFoundationClassNSOrderedSet;
    return XZJSONFoundationClassUnknown;
}


typedef NS_ENUM(NSUInteger, XZJSONFoundationStruct) {
    XZJSONFoundationStructUnknown = 0,
    XZJSONFoundationStructCGRect,
    XZJSONFoundationStructCGSize,
    XZJSONFoundationStructCGPoint,
    XZJSONFoundationStructUIEdgeInsets,
    XZJSONFoundationStructCGVector,
    XZJSONFoundationStructCGAffineTransform,
    XZJSONFoundationStructNSDirectionalEdgeInsets,
    XZJSONFoundationStructUIOffset
};

FOUNDATION_STATIC_INLINE XZJSONFoundationStruct XZJSONFoundationStructFromString(NSString *name) {
    if ([name isEqualToString:@"CGRect"]) {
        return XZJSONFoundationStructCGRect;
    }
    if ([name isEqualToString:@"CGSize"]) {
        return XZJSONFoundationStructCGSize;
    }
    if ([name isEqualToString:@"CGPoint"]) {
        return XZJSONFoundationStructCGPoint;
    }
    if ([name isEqualToString:@"UIEdgeInsets"]) {
        return XZJSONFoundationStructUIEdgeInsets;
    }
    if ([name isEqualToString:@"CGVector"]) {
        return XZJSONFoundationStructCGVector;
    }
    if ([name isEqualToString:@"CGAffineTransform"]) {
        return XZJSONFoundationStructCGAffineTransform;
    }
    if ([name isEqualToString:@"NSDirectionalEdgeInsets"]) {
        return XZJSONFoundationStructNSDirectionalEdgeInsets;
    }
    if ([name isEqualToString:@"UIOffset"]) {
        return XZJSONFoundationStructUIOffset;
    }
    return XZJSONFoundationStructUnknown;
}

FOUNDATION_STATIC_INLINE XZJSONFoundationStruct XZJSONFoundationStructFromType(XZObjcTypeDescriptor *type) {
    switch (type.type) {
        case XZObjcTypeStruct:
            return XZJSONFoundationStructFromString(type.name);
        default:
            return XZJSONFoundationStructUnknown;
    }
}


