//
//  XZImageBorders.m
//  XZKit
//
//  Created by Xezun on 2021/2/17.
//

#import "XZImageBorders.h"
#import "XZImageBorder.h"

@implementation XZImageBorders

@synthesize top = _top;
@synthesize left = _left;
@synthesize bottom = _bottom;
@synthesize right = _right;

- (void)dealloc {
    [self.arrow removeObserver:self forKeyPath:@"width"];
    [self.arrow removeObserver:self forKeyPath:@"height"];
    [self.arrow removeObserver:self forKeyPath:@"vector"];
    [self.arrow removeObserver:self forKeyPath:@"anchor"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.arrow addObserver:self forKeyPath:@"width" options:(NSKeyValueObservingOptionNew) context:nil];
        [self.arrow addObserver:self forKeyPath:@"height" options:(NSKeyValueObservingOptionNew) context:nil];
        [self.arrow addObserver:self forKeyPath:@"vector" options:(NSKeyValueObservingOptionNew) context:nil];
        [self.arrow addObserver:self forKeyPath:@"anchor" options:(NSKeyValueObservingOptionNew) context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.arrow) {
        if ([keyPath isEqual:@"width"]) {
            self.top.arrow.width = self.arrow.width;
            self.left.arrow.width = self.arrow.width;
            self.bottom.arrow.width = self.arrow.width;
            self.right.arrow.width = self.arrow.width;
        } else if ([keyPath isEqual:@"height"]) {
            self.top.arrow.height = self.arrow.height;
            self.left.arrow.height = self.arrow.height;
            self.bottom.arrow.height = self.arrow.height;
            self.right.arrow.height = self.arrow.height;
        } else if ([keyPath isEqual:@"vector"]) {
            self.top.arrow.vector = self.arrow.vector;
            self.left.arrow.vector = self.arrow.vector;
            self.bottom.arrow.vector = self.arrow.vector;
            self.right.arrow.vector = self.arrow.vector;
        } else if ([keyPath isEqual:@"anchor"]) {
            self.top.arrow.anchor = self.arrow.anchor;
            self.left.arrow.anchor = self.arrow.anchor;
            self.bottom.arrow.anchor = self.arrow.anchor;
            self.right.arrow.anchor = self.arrow.anchor;
        }
    }
}

- (XZImageBorder *)top {
    if (_top == nil) {
        _top = [[XZImageBorder alloc] init];
    }
    return _top;
}

- (XZImageBorder *)left {
    if (_left == nil) {
        _left = [[XZImageBorder alloc] init];
    }
    return _left;
}

- (XZImageBorder *)bottom {
    if (_bottom == nil) {
        _bottom = [[XZImageBorder alloc] init];
    }
    return _bottom;
}

- (XZImageBorder *)right {
    if (_right == nil) {
        _right = [[XZImageBorder alloc] init];
    }
    return _right;
}

- (void)setColor:(UIColor *)color {
    [super setColor:color];
    self.top.color = color;
    self.left.color = color;
    self.bottom.color = color;
    self.right.color = color;
}

- (UIColor *)color {
    return [super color] ?: _top.color ?: _left.color ?: _bottom.color ?: _right.color;
}

- (void)setWidth:(CGFloat)width {
    [super setWidth:width];
    self.top.width = width;
    self.left.width = width;
    self.bottom.width = width;
    self.right.width = width;
}

- (CGFloat)width {
    return [super width] ?: _top.width ?: _left.width ?: _bottom.width ?: _right.width;
}

- (void)setDash:(XZImageLineDash)dash {
    [super setDash:dash];
    self.top.dash = dash;
    self.left.dash = dash;
    self.bottom.dash = dash;
    self.right.dash = dash;
}

- (XZImageLineDash)dash {
    if ([super dash].width && [super dash].space) {
        return [super dash];
    }
    if ([_top dash].width && [_top dash].space) {
        return [_top dash];
    }
    if ([_left dash].width && [_left dash].space) {
        return [_left dash];
    }
    if ([_bottom dash].width && [_bottom dash].space) {
        return [_bottom dash];
    }
    return [_right dash];
}

@end
