//
//  XZMocoaTargetAction.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import "XZMocoaTargetAction.h"
#import "XZMocoaViewModel.h"
@import ObjectiveC;

@implementation XZMocoaTargetAction {
    NSInteger _type;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        _type = 0;
        const char * const str = sel_getName(action);
        const size_t       len = strlen(str);
        
        for (size_t i = 0; i < len; i++) {
            switch (str[i]) {
                case ':':
                    _type += 1;
                    break;
                default:
                    break;
            }
        }
        _target  = target;
        _action  = action;
        _handler = nil;
    }
    return self;
}

- (instancetype)initWithTarget:(id)target handler:(XZMocoaTargetHandler)handler {
    self = [super init];
    if (self) {
        _type    = -1;
        _target  = target;
        _action  = nil;
        _handler = [handler copy];
    }
    return self;
}

- (void)sendActionForKey:(XZMocoaKey)key value:(id)value sender:(id)sender {
    switch (_type) {
        case -1:
            _handler(sender, _target, value, key);
            break;
        case 0:
            ((void (*)(id, SEL))objc_msgSend)(_target, _action);
            break;
        case 1:
            ((void (*)(id, SEL, id))objc_msgSend)(_target, _action, sender);
            break;
        case 2:
            ((void (*)(id, SEL, id, id))objc_msgSend)(_target, _action, sender, value);
            break;
        case 3:
            ((void (*)(id, SEL, id, id, XZMocoaKey))objc_msgSend)(_target, _action, sender, value, key);
        default:
            break;
    }
}

@end
