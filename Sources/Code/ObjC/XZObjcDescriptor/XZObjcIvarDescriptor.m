//
//  XZObjcIvarDescriptor.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcIvarDescriptor.h"

@implementation XZObjcIvarDescriptor

+ (instancetype)descriptorWithIvar:(Ivar)ivar {
    if (ivar == nil) {
        return nil;
    }

    const char * const name = ivar_getName(ivar);

    if (name == nil) {
        return nil;
    }

    const char * const typeEncoding = ivar_getTypeEncoding(ivar);

    if (typeEncoding == nil) {
        return nil;
    }
    
    XZObjcTypeDescriptor * _type = [XZObjcTypeDescriptor descriptorForObjcType:typeEncoding];
    if (_type == nil) {
        return nil;
    }

    NSString *_name = [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
    return [[self alloc] initWithIvar:ivar name:_name type:_type];
}

- (instancetype)initWithIvar:(Ivar)ivar name:(NSString *)name type:(XZObjcTypeDescriptor *)type {
    self = [super init];
    if (self) {
        _raw = ivar;
        _name = name;
        _offset = ivar_getOffset(ivar);
        _type = type;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, name: %@, type: <%p: %@>, offset: %ld>", NSStringFromClass(self.class), self, self.name, self.type, ((id)self.type.subtype ?: self.type.name), self.offset];
}

@end
