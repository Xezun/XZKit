//
//  XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import "XZToast.h"

static XZToast *textToast(NSString *message) {
    return [[XZToast alloc] initWithType:(XZToastTypeMessage) text:message];
}

@implementation XZToast

- (instancetype)initWithType:(XZToastType)type text:(NSString *)text {
    self = [super init];
    if (self) {
        _type = type;
        _text = text;
    }
    return self;
}

+ (XZMessageToast)message {
    return textToast;
}

+ (XZLoadingToast)loading {
    return textToast;
}

@end
