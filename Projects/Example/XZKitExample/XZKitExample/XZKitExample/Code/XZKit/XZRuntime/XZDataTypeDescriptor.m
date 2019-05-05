//
//  XZDataTypeDescriptor.m
//  XZKit
//
//  Created by mlibai on 2016/12/1.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZDataTypeDescriptor.h"

@implementation XZDataTypeDescriptor {
    NSMutableArray<Protocol *> *_conformedProtocols;
}

@synthesize conformedProtocols = _conformedProtocols;

- (instancetype)initWithTypeEncoding:(const char *)typeEncoding {
    self = [super init];
    if (self) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = XZDataTypeFromEncoding(typeEncoding);
        switch (_type) {
            case XZDataType_id: {
                size_t len = strlen(typeEncoding);
                if (len > 3) {
                    char *value = calloc(len + 1, sizeof(char));
                    strcpy(value, typeEncoding);
                    
                    // typeEncoding format may be:
                    // @"NSObject" or @"<UITableViewDelegate>" or @"UIView<Delegate>"
                    // @"<UITableViewDelegate><Delegate>" or @"UIView<UITableViewDelegate><Delegate>"
                    
                    BOOL meetClass = NO, meetProtocol = NO;
                    for (size_t i = 2, start = 0; i < len; i++) {
                        switch (typeEncoding[i]) {
                            case '<':
                                if (meetClass) {
                                    meetClass = NO;
                                    value[i] = '\0';
                                    _classType = objc_getClass(&value[start]);
                                }
                                meetProtocol = YES;
                                start = i + 1;
                                break;
                            case '>':
                                if (meetProtocol) {
                                    meetProtocol = NO;
                                    value[i] = '\0';
                                    Protocol *protocol = objc_getProtocol(&value[start]);
                                    if (protocol != nil) {
                                        if (_conformedProtocols == nil) {
                                            _conformedProtocols = [[NSMutableArray alloc] init];
                                        }
                                        [_conformedProtocols addObject:protocol];
                                    }
                                }
                                break;
                            case '"':
                                if (meetClass) {
                                    value[i] = '\0';
                                    _classType = objc_getClass(&value[start]);
                                }
                                meetClass = NO;
                                meetProtocol = NO;
                                break;
                            case '\0':
                                break;
                            default:
                                if (!meetClass && !meetProtocol) {
                                    meetClass = YES;
                                    start = i;
                                }
                                break;
                        }
                    }
                    free(value);
                    break;
                }
            }
            default:

                break;
        }
    }
    return self;
}

- (NSString *)description {
    NSMutableString *protocols = nil;
    if (_conformedProtocols != nil) {
        protocols = [[NSMutableString alloc] init];
        [_conformedProtocols enumerateObjectsUsingBlock:^(Protocol * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (protocols.length > 0) {
                [protocols appendFormat:@", %@", NSStringFromProtocol(obj)];
            } else {
                [protocols appendString:NSStringFromProtocol(obj)];
            }
        }];
    }
    return [NSString stringWithFormat:@"\nDescription Of `%@`: <%@: %p> {\n\ttype: %@, \n\tclassType: %@, \n\tconformedProtocols: %@\n}", self.typeEncoding, NSStringFromClass([self class]), self, NSStringFromXZDataType(self.type), NSStringFromClass([self classType]), protocols];
}

@end
