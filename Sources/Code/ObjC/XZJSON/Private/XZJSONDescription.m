//
//  XZJSONDescription.m
//  XZJSON
//
//  Created by Xezun on 2024/12/3.
//

@import ObjectiveC;

#import "XZJSONDescription.h"
#import "XZJSON.h"
#import "XZJSONPrivate.h"
#import "NSCharacterSet+XZKit.h"
#import "NSData+XZKit.h"
#import "XZLog.h"

#pragma mark - NSDescription

static NSString * _Nonnull XZJSONArrayDescription(id<NSFastEnumeration> const anArray, NSUInteger const count, NSUInteger const indent) {
    if (count == 0) {
        return @"[]";
    }
    
    NSString * const padding = [@"" stringByPaddingToLength:indent * 4 withString:@" " startingAtIndex:0];
    
    NSMutableString *descriptionM = [NSMutableString stringWithString:@"[ \n"];
    for (id obj in anArray) {
        NSString *description = XZJSONObjectDescription(obj, indent + 1);
        [descriptionM appendFormat:@"%@    %@, \n", padding, description];
    }
    [descriptionM deleteCharactersInRange:NSMakeRange(descriptionM.length - 3, 1)];
    [descriptionM appendFormat:@"%@]", padding];
    
    return descriptionM;
}

static NSString * _Nonnull XZJSONDictionaryDescription(NSDictionary * const _Unsafe aDictionary, NSUInteger const indent) {
    // 空字典
    if (aDictionary.count == 0) {
        return @"{}";
    }
    
    // 开头不带缩进，只在换行之后添加缩进，以方便使用者自由控制缩进。
    NSMutableString * const descriptionM = [NSMutableString stringWithString:@"{ \n"];
    
    NSString * const padding = [@"" stringByPaddingToLength:indent * 4 withString:@" " startingAtIndex:0];
    [aDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString * const keyString = [key description];
        NSString * const objString = XZJSONObjectDescription(obj, indent + 1);
        [descriptionM appendFormat:@"%@    %@: %@, \n", padding, keyString, objString];
    }];
    [descriptionM deleteCharactersInRange:NSMakeRange(descriptionM.length - 3, 1)];
    [descriptionM appendFormat:@"%@}", padding];
    
    return descriptionM;
}

static NSString * _Nonnull XZJSONModelDescription(id const _Unsafe model, XZJSONClass * const JSONClass, NSUInteger const indent) {
    if (JSONClass->_sortedProperties.count == 0) {
        return [NSString stringWithFormat:@"<%@: %p>", JSONClass->_raw.raw, model];
    }
    NSString * const padding = [@"" stringByPaddingToLength:indent * 4 withString:@" " startingAtIndex:0];
    
    NSMutableString * const descriptionM = [NSMutableString stringWithFormat:@"<%@: %p, { \n", JSONClass->_raw.raw, model];
    [JSONClass->_sortedProperties enumerateObjectsUsingBlock:^(XZJSONProperty * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * const key = property->_name;
        NSString * value = nil;
        switch (property->_type) {
            case XZStdcTypeBool: {
                BOOL const aValue = ((BOOL (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = aValue ? @"true" : @"false";
                break;
            }
            case XZStdcTypeChar: {
                char const aValue = ((char (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%c", aValue];
                break;
            }
            case XZStdcTypeUnsignedChar: {
                unsigned char const aValue = ((unsigned char (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%c", aValue];
                break;
            }
            case XZStdcTypeShort: {
                short const aValue = ((short (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%d", aValue];
                break;
            }
            case XZStdcTypeUnsignedShort: {
                unsigned short const aValue = ((unsigned short (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%u", aValue];
                break;
            }
            case XZStdcTypeInt: {
                int const aValue = ((int (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%d", aValue];
                break;
            }
            case XZStdcTypeUnsignedInt: {
                unsigned int const aValue = ((unsigned int (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%u", aValue];
                break;
            }
            case XZStdcTypeLong: {
                long const aValue = ((long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%ld", aValue];
                break;
            }
            case XZStdcTypeUnsignedLong: {
                unsigned long const aValue = ((unsigned long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lu", aValue];
                break;
            }
            case XZStdcTypeFloat: {
                float const aValue = ((float (*)(id, SEL))(void *)xz_objc_msgSend_ftret)(model, property->_getter);
                value = [NSString stringWithFormat:@"%f", aValue];
                break;
            }
            case XZStdcTypeDouble: {
                double const aValue = ((double (*)(id, SEL))(void *)xz_objc_msgSend_dbret)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lf", aValue];
                break;
            }
            case XZStdcTypeLongDouble: {
                long double const aValue = ((long double (*)(id, SEL))(void *)xz_objc_msgSend_ldret)(model, property->_getter);
                value = [NSString stringWithFormat:@"%Lf", aValue];
                break;
            }
            case XZStdcTypeLongLong: {
                long long const aValue = ((long long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lld", aValue];
                break;
            }
            case XZStdcTypeUnsignedLongLong: {
                unsigned long long const aValue = ((unsigned long long (*)(id, SEL))(void *)objc_msgSend)(model, property->_getter);
                value = [NSString stringWithFormat:@"%lld", aValue];
                break;
            }
            case XZStdcTypeObject: {
                id const object = ((id (*)(id _Nonnull, SEL _Nonnull))objc_msgSend)((id)model, property->_getter);
                value = XZJSONObjectDescription(object, indent + 1);
                break;
            }
            case XZStdcTypeClass: {
                Class const aClass = ((id (*)(id _Nonnull, SEL _Nonnull))objc_msgSend)((id)model, property->_getter);
                value = object_isClass(aClass) ? NSStringFromClass(aClass) : @"Nil";
                break;
            }
            case XZStdcTypeSelector: {
                SEL selector = ((SEL (*)(id, SEL))(void *)objc_msgSend)((id)model, property->_getter);
                value = selector ? NSStringFromSelector(selector) : @"NULL";
                break;
            }
            case XZStdcTypeArray:
            case XZStdcTypeString:
            case XZStdcTypePointer:
            case XZStdcTypeUnknown: {
                break;
            }
            case XZStdcTypeStruct: {
                value = XZJSONEncodeStructProperty(model, property);
                break;
            }
            case XZStdcTypeUnion: {
                break;
            }
            case XZStdcTypeVoid:
            case XZStdcTypeBitField:
            case XZStdcTypeInt128:
            case XZStdcTypeUnsignedInt128:
            case XZStdcTypeVector:
                break;
        }
        if (value == nil && JSONClass->_usesPropertyJSONEncodingMethod) {
            value = [NSString stringWithFormat:@"%@", [(id<XZJSONCoding>)model JSONEncodeValueForKey:key]];
        }
        if (value) {
            [descriptionM appendFormat:@"%@    %@: %@, \n", padding, key, value];
        }
    }];
    [descriptionM deleteCharactersInRange:NSMakeRange(descriptionM.length - 3, 1)];
    [descriptionM appendFormat:@"%@}>", padding];
    
    return descriptionM;
}

NSString * _Nonnull XZJSONObjectDescription(id const _Unsafe object, NSUInteger const indent) {
    if (!object) {
        return @"<nil>";
    }

    if (object == (id)kCFNull) {
        return @"<null>";
    }

    XZJSONClass * const JSONClass = [XZJSONClass classForClass:object_getClass(object)];

    switch (JSONClass->_cocoaClass) {
        case XZJSONCocoaClassNSString:
        case XZJSONCocoaClassNSMutableString: {
            return (NSString *)object;
        }
        case XZJSONCocoaClassNSValue: {
            return ((NSValue *)object).description;
            break;
        }
        case XZJSONCocoaClassNSNumber: {
            return [(NSNumber *)object stringValue];
        }
        case XZJSONCocoaClassNSData:
        case XZJSONCocoaClassNSMutableData: {
            NSString *base64String = [(NSData *)object base64EncodedStringWithOptions:(kNilOptions)];
            return [NSString stringWithFormat:@"data:base64,%@", base64String];
        }
        case XZJSONCocoaClassNSDecimalNumber: {
            return [(NSDecimalNumber *)object stringValue];
        }
        case XZJSONCocoaClassNSDate: {
            return [XZJSON.dateFormatter stringFromDate:(NSDate *)object];
        }
        case XZJSONCocoaClassNSURL: {
            return ((NSURL *)object).absoluteString;
        }
        case XZJSONCocoaClassNSSet:
        case XZJSONCocoaClassNSMutableSet:
        case XZJSONCocoaClassNSCountedSet: {
            return XZJSONArrayDescription(((NSSet *)object).allObjects, ((NSSet *)object).count, indent);
        }
        case XZJSONCocoaClassNSOrderedSet:
        case XZJSONCocoaClassNSMutableOrderedSet: {
            return XZJSONArrayDescription((NSOrderedSet *)object, ((NSOrderedSet *)object).count, indent);
        }
        case XZJSONCocoaClassNSArray:
        case XZJSONCocoaClassNSMutableArray: {
            return XZJSONArrayDescription((NSArray *)object, ((NSArray *)object).count, indent);
        }
        case XZJSONCocoaClassNSDictionary:
        case XZJSONCocoaClassNSMutableDictionary: {
            return XZJSONDictionaryDescription((NSDictionary *)object, indent);
        }
        case XZJSONCocoaClassUnknown: {
            return XZJSONModelDescription(object, JSONClass, indent);
        }
    }
}
