//
//  XZImageBorders.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageBorders.h"
#import "XZImageBorders+Extension.h"
#import "XZImageBorder.h"
#import "XZImageLine+Extension.h"
#import "XZImageLineDash+Extension.h"
#import "XZImageBorder+Extension.h"

@implementation XZImageBorders

@synthesize top = _top;
@synthesize left = _left;
@synthesize bottom = _bottom;
@synthesize right = _right;

- (void)dealloc {
    XZImageBorderArrow * const arrowIfLoaded = self.arrowIfLoaded;
    [arrowIfLoaded removeObserver:self forKeyPath:@"width"];
    [arrowIfLoaded removeObserver:self forKeyPath:@"height"];
    [arrowIfLoaded removeObserver:self forKeyPath:@"vector"];
    [arrowIfLoaded removeObserver:self forKeyPath:@"anchor"];
}

- (void)arrowDidLoad {
    [self.arrow addObserver:self forKeyPath:@"width" options:(NSKeyValueObservingOptionNew) context:nil];
    [self.arrow addObserver:self forKeyPath:@"height" options:(NSKeyValueObservingOptionNew) context:nil];
    [self.arrow addObserver:self forKeyPath:@"vector" options:(NSKeyValueObservingOptionNew) context:nil];
    [self.arrow addObserver:self forKeyPath:@"anchor" options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)dashDidLoad {
    self.dash.delegate = self;
}

- (XZImageBorder *)top {
    if (_top == nil) {
        _top = [[XZImageBorder alloc] initWithBorder:self];
    }
    return _top;
}

- (XZImageBorder *)topIfLoaded {
    return _top;
}

- (XZImageBorder *)left {
    if (_left == nil) {
        _left = [[XZImageBorder alloc] initWithBorder:self];
    }
    return _left;
}

- (XZImageBorder *)leftIfLoaded {
    return _left;
}

- (XZImageBorder *)bottom {
    if (_bottom == nil) {
        _bottom = [[XZImageBorder alloc] initWithBorder:self];
    }
    return _bottom;
}

- (XZImageBorder *)bottomIfLoaded {
    return _bottom;
}

- (XZImageBorder *)right {
    if (_right == nil) {
        _right = [[XZImageBorder alloc] initWithBorder:self];
    }
    return _right;
}

- (XZImageBorder *)rightIfLoaded {
    return _right;
}

#pragma mark - 同步属性到下级

- (void)setColor:(UIColor *)color {
    [super setColor:color];
    self.topIfLoaded.color    = color;
    self.leftIfLoaded.color   = color;
    self.bottomIfLoaded.color = color;
    self.rightIfLoaded.color  = color;
}

- (void)setWidth:(CGFloat)width {
    [super setWidth:width];
    self.topIfLoaded.width    = width;
    self.leftIfLoaded.width   = width;
    self.bottomIfLoaded.width = width;
    self.rightIfLoaded.width  = width;
}

- (void)lineDashDidUpdate:(XZImageLineDash *)lineDash {
    [self.topIfLoaded.dash    updateWithLineDash:self.dashIfLoaded];
    [self.leftIfLoaded.dash   updateWithLineDash:self.dashIfLoaded];
    [self.bottomIfLoaded.dash updateWithLineDash:self.dashIfLoaded];
    [self.rightIfLoaded.dash  updateWithLineDash:self.dashIfLoaded];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.arrow) {
        if ([keyPath isEqual:@"width"]) {
            self.topIfLoaded.arrow.width    = self.arrow.width;
            self.leftIfLoaded.arrow.width   = self.arrow.width;
            self.bottomIfLoaded.arrow.width = self.arrow.width;
            self.rightIfLoaded.arrow.width  = self.arrow.width;
        } else if ([keyPath isEqual:@"height"]) {
            self.topIfLoaded.arrow.height    = self.arrow.height;
            self.leftIfLoaded.arrow.height   = self.arrow.height;
            self.bottomIfLoaded.arrow.height = self.arrow.height;
            self.rightIfLoaded.arrow.height  = self.arrow.height;
        } else if ([keyPath isEqual:@"vector"]) {
            self.topIfLoaded.arrow.vector    = self.arrow.vector;
            self.leftIfLoaded.arrow.vector   = self.arrow.vector;
            self.bottomIfLoaded.arrow.vector = self.arrow.vector;
            self.rightIfLoaded.arrow.vector  = self.arrow.vector;
        } else if ([keyPath isEqual:@"anchor"]) {
            self.topIfLoaded.arrow.anchor    = self.arrow.anchor;
            self.leftIfLoaded.arrow.anchor   = self.arrow.anchor;
            self.bottomIfLoaded.arrow.anchor = self.arrow.anchor;
            self.rightIfLoaded.arrow.anchor  = self.arrow.anchor;
        }
    }
}

@end
