//
//  XZObjcIvar.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcIvar.h"

@implementation XZObjcIvar

+ (instancetype)ivarForIvar:(Ivar)rawIvar {
    if (rawIvar == nil) {
        return nil;
    }

    const char * const name = ivar_getName(rawIvar);

    if (name == nil) {
        return nil;
    }

    const char * const typeEncoding = ivar_getTypeEncoding(rawIvar);

    if (typeEncoding == nil) {
        return nil;
    }
    
    XZObjcType * _type = [XZObjcType typeWithEncoding:typeEncoding];
    if (_type == nil) {
        return nil;
    }

    NSString *_name = [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
    return [[self alloc] initWithIvar:rawIvar name:_name type:_type];
}

- (instancetype)initWithIvar:(Ivar)ivar name:(NSString *)name type:(XZObjcType *)type {
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
