//
//  XZImageBorder.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageBorder.h"
#import "XZImageBorder+Extension.h"

@implementation XZImageBorder

- (instancetype)initWithBorder:(XZImageBorder *)border {
    self = [super initWithLine:border];
    if (self) {
        XZImageBorderArrow *arrow = border.arrowIfLoaded;
        if (arrow != nil) {
            _arrow = [[XZImageBorderArrow alloc] initWithArrow:arrow];
            _arrow.minWidth = self.width * 2.0;
            _arrow.superAttribute = self;
        }
    }
    return self;
}

@synthesize arrow = _arrow;

- (XZImageBorderArrow *)arrow {
    if (_arrow == nil) {
        _arrow = [[XZImageBorderArrow alloc] initWithArrow:nil];
        _arrow.minWidth = self.width * 2.0;
        _arrow.superAttribute = self;
    }
    return _arrow;
}

- (XZImageBorderArrow *)arrowIfLoaded {
    return _arrow;
}

- (void)setWidth:(CGFloat)width {
    [super setWidth:width];
    
    self.arrowIfLoaded.minWidth = self.width * 2.0;
}

@end


