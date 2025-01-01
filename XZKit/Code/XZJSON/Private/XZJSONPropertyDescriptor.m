//
//  XZJSONPropertyDescriptor.m
//  XZJSON
//
//  Created by 徐臻 on 2024/9/29.
//

#import "XZJSONPropertyDescriptor.h"
#import "XZJSONDefines.h"

@implementation XZJSONPropertyDescriptor

+ (XZJSONPropertyDescriptor *)descriptorWithClass:(XZObjcClassDescriptor *)aClass property:(XZObjcPropertyDescriptor *)property elementClass:(Class)elementClass {
    
    // support pseudo generic class with protocol name
    if (!elementClass && property.protocols) {
        for (NSString *protocol in property.protocols) {
            Class cls = objc_getClass(protocol.UTF8String);
            if (cls) {
                elementClass = cls;
                break;
            }
        }
    }
    
    XZJSONPropertyDescriptor *descriptor = [self new];
    descriptor->_property     = property;
    descriptor->_name         = property.name;
    descriptor->_type         = property.type;
    descriptor->_elementClass = elementClass;
    
    if ((descriptor->_type & XZObjcTypeMask) == XZObjcTypeObject) {
        descriptor->_nsType = XZJSONEncodingNSTypeFromClass(property.subtype);
    } else {
        descriptor->_isCNumber = XZObjcTypeIsCNumber(descriptor->_type);
    }
    
    if ((descriptor->_type & XZObjcTypeMask) == XZObjcTypeStruct) {
        /// It seems that NSKeyedUnarchiver cannot decode NSValue except these structs:
        static NSSet *types = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *set = [NSMutableSet new];
            // 32 bit
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];
            // 64 bit
            [set addObject:@"{CGSize=dd}"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGPoint=dd}{CGSize=dd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];
            types = set;
        });
        if ([types containsObject:property.typeEncoding]) {
            descriptor->_isNSCodingStruct = YES;
        }
    }
    descriptor->_class = property.subtype;
    
    if ([aClass.raw instancesRespondToSelector:property.getter]) {
        descriptor->_getter = property.getter;
    }
    
    if (property.setter && [aClass.raw instancesRespondToSelector:property.setter]) {
        descriptor->_setter = property.setter;
    }
    
    if (descriptor->_getter && descriptor->_setter) {
        /*
         KVC invalid type:
         long double
         pointer (such as SEL/CoreFoundation object)
         */
        switch (descriptor->_type & XZObjcTypeMask) {
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
            case XZObjcTypeObject:
            case XZObjcTypeClass:
            case XZObjcTypeBlock:
            case XZObjcTypeStruct:
            case XZObjcTypeUnion: {
                descriptor->_isKVCCompatible = YES;
                break;
            }
            default: {
                break;
            }
        }
    }
    
    return descriptor;
}
@end
