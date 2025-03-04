//
//  XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import "XZToast.h"

static XZToast *_messageToast(NSString *message) {
    return [[XZToast alloc] initWithType:(XZToastTypeMessage) text:message];
}

static XZToast *_loadingToast(NSString *message) {
    return [[XZToast alloc] initWithType:(XZToastTypeLoading) text:message];
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

+ (XZTextToast)message {
    return _messageToast;
}

+ (XZTextToast)loading {
    return _loadingToast;
}

@end
