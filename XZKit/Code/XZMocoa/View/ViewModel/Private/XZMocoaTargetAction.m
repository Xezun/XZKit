//
//  XZMocoaTargetAction.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import "XZMocoaTargetAction.h"
@import ObjectiveC;

@implementation XZMocoaTargetAction {
    NSInteger _args;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    NSInteger __block count = 0;
    NSString *string = NSStringFromSelector(action);
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if ([substring isEqualToString:@":"]) {
            count += 1;
        }
    }];
    NSAssert(count <= 2, @"方法 %@ 不合法，通过 %@ 绑定的方法参数不能超过 2 个，当前为 %ld 个", string, NSStringFromSelector(@selector(addTarget:action:forKey:)), count);
    
    self = [super init];
    if (self) {
        _target = target;
        _action = action;
        _args = count;
    }
    return self;
}

- (void)sendActionWithValue:(id)value sender:(id)sender key:(XZMocoaKey)key {
    switch (_args) {
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
