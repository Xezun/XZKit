//
//  XZMocoaModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/8/25.
//

#import "XZMocoaModel.h"
#import <objc/runtime.h>

static const void * const _mocoaName = &_mocoaName;

@implementation NSObject (XZMocoaModel)

- (XZMocoaName)mocoaName {
    return objc_getAssociatedObject(self, _mocoaName);
}

- (void)setMocoaName:(XZMocoaName)mocoaName {
    objc_setAssociatedObject(self, _mocoaName, mocoaName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

#import "XZMocoaViewModel.h"


