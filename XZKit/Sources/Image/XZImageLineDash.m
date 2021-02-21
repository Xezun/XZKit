//
//  XZImageLineDash.m
//  XZKit
//
//  Created by Xezun on 2021/2/20.
//

#import "XZImageLineDash.h"
#import "XZImageLineDash+Extension.h"

@implementation XZImageLineDash {
    NSInteger _capacity;
}

- (void)dealloc {
    free(_segments);
    _capacity = 0;
    _segments = NULL;
    _numberOfSegments = 0;
}

@synthesize segments = _segments;

- (instancetype)initWithPhase:(CGFloat)phase {
    self = [super init];
    if (self) {
        _phase = phase;
        _capacity = 8;
        _segments = calloc(_capacity, sizeof(CGFloat));
        _numberOfSegments = 0;
    }
    return self;
}

+ (instancetype)lineDashWithLineDash:(XZImageLineDash *)lineDash {
    XZImageLineDash *dash = [[XZImageLineDash alloc] initWithPhase:0];
    [dash updateWithLineDash:lineDash];
    return dash;
}

- (BOOL)isEmpty {
    return (_numberOfSegments == 0);
}

- (void)xz_setPhase:(CGFloat)phase {
    _phase = phase;
}

- (void)setPhase:(CGFloat)phase {
    [self xz_setPhase:phase];
    
    [self didUpdateAttribute:@"phase"];
}

- (void)setSegments:(NSArray<NSNumber *> *)segments {
    [self xz_setSegments:segments];
    
    [self didUpdateAttribute:@"segments"];
}

- (void)setSegments:(const CGFloat *)segments length:(NSInteger)length {
    [self xz_setSegments:segments length:length];
    
    [self didUpdateAttribute:@"segments"];
}

- (void)xz_setSegments:(NSArray<NSNumber *> * _Nullable)segments {
    _numberOfSegments = segments.count;
    [self adjustsCapacityToFitSegments];
    
    for (NSInteger i = 0; i < _numberOfSegments; i++) {
        _segments[i] = segments[i].doubleValue;
    }
}

- (void)xz_setSegments:(const CGFloat *)segments length:(NSInteger)length {
    _numberOfSegments = length;
    [self adjustsCapacityToFitSegments];
    
    if (segments != NULL) {
        memcpy(_segments, segments, length * sizeof(CGFloat));
    }
}

- (BOOL)isEqual:(id)object {
    return [self isEqualToDash:object];
}

- (BOOL)isEqualToDash:(XZImageLineDash *)dash {
    if (self == dash) {
        return YES;
    }
    if ([dash isKindOfClass:[XZImageLineDash class]]) {
        if (self.phase != dash.phase) {
            return NO;
        }
        CGFloat * const segments1 = self.segments;
        CGFloat * const segments2 = dash.segments;
        if (segments1 == segments2) {
            return YES;
        }
        NSInteger const numberOfSegments = self.numberOfSegments;
        if (numberOfSegments != dash.numberOfSegments) {
            return NO;
        }
        for (NSInteger i = 0; i < numberOfSegments; i++) {
            if (segments1[i] != segments2[i]) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (void)setWidth:(CGFloat)width {
    if (width <= 0) {
        [self setSegments:NULL length:0];
        return;
    }
    
    if (_numberOfSegments == 0 || _numberOfSegments > 2) {
        CGFloat segments[2] = {width, width};
        [self setSegments:segments length:2];
    } else if (_numberOfSegments == 2) {
        CGFloat segments[2] = {width, _segments[1]};
        [self setSegments:segments length:2];
    } else {
        [self setSegments:&width length:1];
    }
}

- (CGFloat)width {
    if (_numberOfSegments < 1) {
        return 0;
    }
    return _segments[0];
}

- (void)setSpace:(CGFloat)space {
    if (_numberOfSegments == 2) {
        if (space <= 0) {
            CGFloat width = _segments[0];
            [self setSegments:&width length:1];
        } else {
            CGFloat segments[2] = {_segments[0], space};
            [self setSegments:segments length:2];
        }
    } else if (_numberOfSegments == 1) {
        if (space > 0) {
            CGFloat segments[2] = {_segments[0], space};
            [self setSegments:segments length:2];
        }
    } else {
        CGFloat segments[2] = {space, space};
        [self setSegments:segments length:2];
    }
}

- (CGFloat)space {
    if (_numberOfSegments < 2) {
        return 0;
    }
    return _segments[1];
}

#pragma mark - 私有方法

- (void)updateWithLineDash:(XZImageLineDash *)lineDash {
    if (lineDash == self) {
        return;
    }
    [self xz_setPhase:lineDash.phase];
    [self xz_setSegments:lineDash.segments length:lineDash.numberOfSegments];
}

- (void)adjustsCapacityToFitSegments {
    // 数目比容量少，缩容到8，避免频繁扩容和浪费
    if (_numberOfSegments < _capacity) {
        NSInteger newCapacity = MAX(8, _numberOfSegments);
        if (newCapacity == _capacity) {
            return;
        }
        _capacity = newCapacity;
        _segments = realloc(_segments, sizeof(CGFloat) * _capacity);
        return;
    }
    
    // 当前容量不够，扩容
    if (_numberOfSegments > _capacity) {
        _capacity = _numberOfSegments;
        _segments = realloc(_segments, sizeof(CGFloat) * _capacity);
    }
}

@end
