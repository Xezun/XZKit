//
//  XZObjcIvar.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcIvar.h"
#import "XZObjcType.h"

@implementation XZObjcIvar

+ (instancetype)ivarWithIvar:(Ivar)ivar {
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
    
    XZObjcType * _type = [XZObjcType typeForEncoding:typeEncoding];
    if (_type == nil) {
        return nil;
    }

    NSString *_name = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
    return [[self alloc] initWithIvar:ivar name:_name type:_type];
}

- (instancetype)initWithIvar:(Ivar)ivar name:(NSString *)name type:(XZObjcType *)type {
    self = [super init];
    if (self) {
        _raw = ivar;
        _name = name;
        _type = type;
        _offset = ivar_getOffset(ivar);
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"< \n"
            "    %@: %p, \n"
            "    name: %@, \n"
            "    type: %@, \n"
            "    offset: %ld \n"
            ">", NSStringFromClass(self.class), self, self.name, self.type.name, self.offset];
}

@end
