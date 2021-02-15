//
//  XZKitGeometry.m
//  XZKit
//
//  Created by 徐臻 on 2019/3/27.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import "XZKit+Geometry.h"

XZEdgeInsets const XZEdgeInsetsZero = {0, 0, 0, 0};

BOOL XZEdgeInsetsEqualToEdgeInsets(XZEdgeInsets e1, XZEdgeInsets e2) {
    return (e1.top == e2.top) && (e1.leading == e2.leading) && (e1.trailing == e2.trailing) && (e1.bottom == e2.bottom);
}

XZEdgeInsets XZEdgeInsetsMake(CGFloat top, CGFloat leading, CGFloat bottom, CGFloat trailing) {
    XZEdgeInsets edgeInsets;
    edgeInsets.top = top;
    edgeInsets.leading = leading;
    edgeInsets.bottom = bottom;
    edgeInsets.trailing = trailing;
    return edgeInsets;
}

XZEdgeInsets XZEdgeInsetsFromUIEdgeInsets(UIEdgeInsets edgeInsets, UIUserInterfaceLayoutDirection layoutDirection) {
    switch (layoutDirection) {
        case UIUserInterfaceLayoutDirectionLeftToRight:
            return XZEdgeInsetsMake(edgeInsets.top, edgeInsets.left, edgeInsets.bottom, edgeInsets.right);
        case UIUserInterfaceLayoutDirectionRightToLeft:
            return XZEdgeInsetsMake(edgeInsets.top, edgeInsets.right, edgeInsets.bottom, edgeInsets.left);
    }
}

UIEdgeInsets UIEdgeInsetsFromXZEdgeInsets(XZEdgeInsets edgeInsets, UIUserInterfaceLayoutDirection layoutDirection) {
    switch (layoutDirection) {
        case UIUserInterfaceLayoutDirectionLeftToRight:
            return UIEdgeInsetsMake(edgeInsets.top, edgeInsets.leading, edgeInsets.bottom, edgeInsets.trailing);
        case UIUserInterfaceLayoutDirectionRightToLeft:
            return UIEdgeInsetsMake(edgeInsets.top, edgeInsets.trailing, edgeInsets.bottom, edgeInsets.leading);
    }
}

BOOL CGRectContainsPointInEdgeInsets(CGRect bounds, UIEdgeInsets edgeInsets, CGPoint point) {
    return (point.x < CGRectGetMinX(bounds) + edgeInsets.left) || (point.x > CGRectGetMaxX(bounds) - edgeInsets.right) || (point.y < CGRectGetMinY(bounds) + edgeInsets.top) || (point.y > CGRectGetMaxY(bounds) - edgeInsets.bottom);
}


NSString *NSStringFromXZEdgeInsets(XZEdgeInsets edgeInsets) {
    return [NSString stringWithFormat:@"{%g, %g, %g, %g}", edgeInsets.top, edgeInsets.leading, edgeInsets.bottom, edgeInsets.trailing];
}

XZEdgeInsets XZEdgeInsetsFromString(NSString * _Nullable aString) {
    assert([aString isKindOfClass:NSString.class]);
    aString = [aString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{} \n\t"]];
    NSArray<NSString *> *insets = [aString componentsSeparatedByString:@","];
    if (insets.count != 4) {
        return XZEdgeInsetsZero;
    }
#if CGFLOAT_IS_DOUBLE
    return XZEdgeInsetsMake(insets[0].doubleValue, insets[1].doubleValue, insets[2].doubleValue, insets[3].doubleValue);
#else
    return XZEdgeInsetsMake(insets[0].floatValue, insets[1].floatValue, insets[2].floatValue, insets[3].floatValue);
#endif
}

NSString *NSStringFromXZRectEdge(XZRectEdge rectEdge) {
    NSMutableArray<NSString *> *edgesM = [NSMutableArray arrayWithCapacity:4];
    XZRectEdge edge = 1;
    while (edge <= XZRectEdgeTrailing) {
        if (edge & rectEdge) {
            switch (edge) {
                case XZRectEdgeTop:
                    [edgesM addObject:@".top"];
                    break;
                case XZRectEdgeLeading:
                    [edgesM addObject:@".leading"];
                    break;
                case XZRectEdgeBottom:
                    [edgesM addObject:@".bottom"];
                    break;
                case XZRectEdgeTrailing:
                    [edgesM addObject:@".trailing"];
                    break;
                default:
                    break;
            }
        }
        edge <<= 1;
    }
    
    if (edgesM.count > 1) {
        return [NSString stringWithFormat:@"[%@]", [edgesM componentsJoinedByString:@", "]];
    }
    return edgesM.firstObject;
}

XZRectEdge XZRectEdgeFromString(NSString * _Nullable aString) {
    XZRectEdge edges = 0;
    if ([aString isKindOfClass:NSString.class] && aString.length > 0) {
        NSArray * const edgeStrings = @[
            @".top", @".leading",
            @".bottom", @".trailing"
        ];
        for (NSInteger i = 0; i < 4; i++) {
            if ([aString containsString:edgeStrings[i]]) {
                edges |= (1 << i);
            }
        }
    }
    return edges;
}


@implementation NSValue (XZKitGeometry)

+ (NSValue *)valueWithXZEdgeInsets:(XZEdgeInsets)insets {
    return [NSValue valueWithBytes:&insets objCType:@encode(XZEdgeInsets)];
}

+ (NSValue *)valueWithXZRectEdge:(XZRectEdge)edge {
    return [NSValue valueWithBytes:&edge objCType:@encode(XZRectEdge)];
}

- (XZEdgeInsets)XZEdgeInsetsValue {
    XZEdgeInsets insets = XZEdgeInsetsZero;
    [self getValue:&insets];
    return insets;
}

- (XZRectEdge)XZRectEdgeValue {
    XZRectEdge edge = 0;
    [self getValue:&edge];
    return edge;
}

@end


@implementation NSCoder (XZKitGeometry)

- (void)encodeXZEdgeInsets:(XZEdgeInsets)insets forKey:(NSString *)key {
    NSValue *value = [NSValue valueWithXZEdgeInsets:insets];
    [self encodeObject:value forKey:key];
}

- (XZEdgeInsets)decodeXZEdgeInsetsForKey:(NSString *)key {
    NSValue *value = [self decodeObjectForKey:key];
    return [value XZEdgeInsetsValue];
}

@end
