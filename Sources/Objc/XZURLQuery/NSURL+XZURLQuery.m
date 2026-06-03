//
//  NSURL+XZURLQuery.m
//  XZURLQuery
//
//  Created by Xezun on 2023/7/30.
//

#import "NSURL+XZURLQuery.h"
#import "XZURLQuery.h"

@implementation NSURL (XZURLQuery)

- (XZURLQuery *)xz_query {
    return [[XZURLQuery alloc] initWithURL:self];
}

+ (instancetype)xz_URLWithFormat:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    NSURL *url = [self xz_URLWithFormat:format arguments:arguments];
    va_end(arguments);
    return url;
}

+ (instancetype)xz_URLWithFormat:(NSString *)format arguments:(va_list)arguments {
    return XZURLv(format, arguments);
}

@end

NSURL *XZURL(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSURL *url = XZURLv(format, arguments);
    va_end(arguments);
    return url;
}

NSURL *XZURLv(NSString *format, va_list arguments) {
    NSString *url = [[NSString alloc] initWithFormat:format arguments:arguments];
    return [NSURL URLWithString:url];
}
