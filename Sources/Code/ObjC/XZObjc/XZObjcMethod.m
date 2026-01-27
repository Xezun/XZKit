//
//  XZObjcMethod.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcMethod.h"

@implementation XZObjcMethod

+ (instancetype)methodWithMethod:(Method)method {
    if (method == nil) {
        return nil;
    }

    SEL const _selector = method_getName(method);
    if (_selector == nil) {
        return nil;
    }

    const char * const encoding = method_getTypeEncoding(method);
    if (encoding == NULL) {
        return nil;
    }
    NSString * const _encoding = [NSString stringWithUTF8String:encoding];
    
    IMP const _implementation = method_getImplementation(method);
    
    XZObjcType *_type = nil;
    char * const typeEncoding = method_copyReturnType(method);
    if (typeEncoding != nil) {
        _type = [XZObjcType typeForEncoding:typeEncoding];
    } else {
        _type = [XZObjcType typeForEncoding:@encode(void)];
    }
    free(typeEncoding);
    
    unsigned int const numberOfArguments = method_getNumberOfArguments(method);
    NSMutableArray * const _arguments = [NSMutableArray arrayWithCapacity:numberOfArguments];
    for (unsigned int i = 0; i < numberOfArguments; i++) {
        char * const argument = method_copyArgumentType(method, i);
        XZObjcType * const argumentType = [XZObjcType typeForEncoding:argument];
        if (argumentType) {
            [_arguments addObject:argumentType];
        } else {
            [_arguments addObject:[XZObjcType typeForType:(XZStdcTypeUnknown)]];
        }
        free(argument);
    }

    return [[self alloc] initWithMethod:method selector:_selector implementation:_implementation arguments:_arguments type:_type encoding:_encoding];
}

- (instancetype)initWithMethod:(Method)method selector:(SEL)selector implementation:(IMP)implementation arguments:(NSArray *)arguments type:(XZObjcType *)type encoding:(NSString *)typeEncoding {
    self = [super init];
    if (self) {
        _raw = method;
        _name = NSStringFromSelector(selector);
        _selector = selector;
        _implementation = implementation;
        _encoding = typeEncoding;
        _type = type;
        _arguments = arguments;
    }
    return self;
}

- (NSString *)description {
    NSString *type = [NSString stringWithFormat:@"<%p, %@>", self.type, ((id)self.type.classType ?: self.type.name)];
    
    NSString *argumentsTypes = nil;
    if (self.arguments.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.arguments enumerateObjectsUsingBlock:^(XZObjcType * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    <%p, %@>,\n", obj, ((id)obj.classType ?: obj.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        argumentsTypes = stringM;
    }
    return [NSString stringWithFormat:@"<%@: %p, name: %@, type: %@, implementation: %p, typeEncoding: %@, argumentsTypes: %@>", NSStringFromClass(self.class), self, self.name, type, self.implementation, self.encoding, argumentsTypes];
}

@end
