//
//  XZMocoaModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/8/25.
//

#import "XZMocoaModel.h"
#import "XZRuntime.h"
#import <objc/runtime.h>

static const void * const _mocoaName = &_mocoaName;

@implementation NSObject (XZMocoaModel)

+ (void)load {
    if (self == [NSObject class]) {
        // 已经实现 XZMocoaModel 就不添加默认实现。
        if ([self conformsToProtocol:@protocol(XZMocoaModel)]) {
            return;
        }
        xz_objc_class_copyMethod(self, @selector(__xz_mocoa_mocoaName),
                                 self, @selector(mocoaName));
        xz_objc_class_copyMethod(self, @selector(__xz_mocoa_setMocoaName:),
                                 self, @selector(setMocoaName:));
    }
}

- (XZMocoaName)__xz_mocoa_mocoaName {
    return objc_getAssociatedObject(self, _mocoaName);
}

- (void)__xz_mocoa_setMocoaName:(XZMocoaName)mocoaName {
    objc_setAssociatedObject(self, _mocoaName, mocoaName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
