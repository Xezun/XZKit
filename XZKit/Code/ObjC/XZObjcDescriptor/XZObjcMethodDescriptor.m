//
//  XZObjcMethodDescriptor.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcMethodDescriptor.h"

@implementation XZObjcMethodDescriptor

+ (instancetype)descriptorForMethod:(Method)method {
    if (method == nil) {
        return nil;
    }

    SEL const _selector = method_getName(method);
    if (_selector == nil) {
        return nil;
    }
    
    NSString * const _name = NSStringFromSelector(_selector);
    
    if (_name == nil || _name.length == 0) {
        return nil;
    }

    const char * const typeEncoding = method_getTypeEncoding(method);

    if (typeEncoding == nil) {
        return nil;
    }
    
    IMP const _implementation = method_getImplementation(method);
    NSString * const _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    XZObjcTypeDescriptor *_returnType = nil;
    NSMutableArray *_argumentsTypes = nil;
    
    char *returnType = method_copyReturnType(method);
    if (returnType != nil) {
        _returnType = [XZObjcTypeDescriptor descriptorForTypeEncoding:returnType];
        free(returnType);
    } else {
        _returnType = [XZObjcTypeDescriptor descriptorForTypeEncoding:@encode(void)];
    }

    unsigned int const count = method_getNumberOfArguments(method);
    if (count > 0) {
        _argumentsTypes = [NSMutableArray arrayWithCapacity:count];
        for (unsigned int i = 0; i < count; i++) {
            char *argumentType = method_copyArgumentType(method, i);
            if (argumentType) {
                XZObjcTypeDescriptor *type = [XZObjcTypeDescriptor descriptorForTypeEncoding:argumentType];
                if (type) {
                    [_argumentsTypes addObject:type];
                }
                free(argumentType);
            }
        }
    }

    return [[self alloc] initWithMethod:method name:_name selector:_selector implementation:_implementation typeEncoding:_typeEncoding returnType:_returnType argumentsTypes:_argumentsTypes];
}

- (instancetype)initWithMethod:(Method)method name:(NSString *)name selector:(SEL)selector implementation:(IMP)implementation typeEncoding:(NSString *)typeEncoding returnType:(XZObjcTypeDescriptor *)returnType argumentsTypes:(NSArray *)argumentsTypes {
    self = [super init];
    if (self) {
        _raw = method;
        _name = name;
        _selector = selector;
        _implementation = implementation;
        _encoding = typeEncoding;
        _type = returnType;
        _argumentsTypes = argumentsTypes;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, name: %@, implementation: %p, typeEncoding: %@, returnType: %@, argumentsTypes: %@>", NSStringFromClass(self.class), self, self.name, self.implementation, self.encoding, self.type, self.argumentsTypes];
}

@end
