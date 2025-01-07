//
//  XZMocoaModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/8/25.
//

#import "XZMocoaModel.h"
#import <objc/runtime.h>

static const void * const _mocoaName = &_mocoaName;

@interface NSObject (XZMocoaModel) <XZMocoaModel>
@end

@implementation NSObject (XZMocoaModel)

- (XZMocoaName)mocoaName {
    return objc_getAssociatedObject(self, _mocoaName);
}

- (void)setMocoaName:(XZMocoaName)mocoaName {
    if ([self.mocoaName isEqualToString:mocoaName]) {
        return;
    }
    objc_setAssociatedObject(self, _mocoaName, mocoaName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


#if !SWIFT_PACKAGE
@implementation XZMocoaModel
@synthesize mocoaName = _mocoaName;
@end
#endif
