//
//  XZImageBorder.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageBorder.h"
#import "XZImageBorder+Extension.h"
#import "XZImageBorders.h"

@implementation XZImageBorder

- (BOOL)isEffective {
    return super.isEffective || self.arrowIfLoaded.isEffective;
}

- (instancetype)initWithImageBorders:(XZImageBorders *)imageBorders {
    self = [super initWithSuperAttribute:imageBorders];
    if (self) {
        [self updateWithLineValue:imageBorders];
        
        XZImageArrow *arrow = imageBorders.arrowIfLoaded;
        if (arrow != nil) {
            _arrow = [[XZImageArrow alloc] initWithBorder:self];
            [_arrow updateWithBorderArrowValue:arrow];
        }
    }
    return self;
}

@synthesize arrow = _arrow;

- (XZImageArrow *)arrow {
    if (_arrow == nil) {
        _arrow = [[XZImageArrow alloc] initWithBorder:self];
    }
    return _arrow;
}

- (XZImageArrow *)arrowIfLoaded {
    return _arrow;
}

@end


