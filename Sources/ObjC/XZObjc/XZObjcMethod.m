//
//  XZObjcMethod.m
//  XZKit
//
//  Created by Xezun on 2025/1/26.
//

#import "XZObjcMethod.h"
#import "XZObjcType.h"

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
    for (unsigned int i = 2; i < numberOfArguments; i++) {
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
        _type = type;
        _encoding = typeEncoding;
        _selector = selector;
        _implementation = implementation;
        _arguments = arguments.copy;
    }
    return self;
}

- (NSString *)description {
    NSString *type = self.type.name;
    
    NSString *arguments = nil;
    if (self.arguments.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"("];
        [self.arguments enumerateObjectsUsingBlock:^(XZObjcType * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"%@, ", obj.name];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 2)];
        [stringM appendString:@")"];
        arguments = stringM;
    } else {
        arguments = @"()";
    }
    
    return [NSString stringWithFormat:@"<%@: %p, { \n"
            "    name: %@, \n"
            "    type: %@, \n"
            "    implementation: %p, \n"
            "    encoding: %@, \n"
            "    arguments: %@ \n"
            "}>", self.class, self, self.name, type, self.implementation, self.encoding, arguments];
}

@end
