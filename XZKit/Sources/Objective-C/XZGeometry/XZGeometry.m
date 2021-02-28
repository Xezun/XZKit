//
//  XZGeometry.m
//  XZKit
//
//  Created by 徐臻 on 2019/3/27.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import "XZGeometry.h"

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
    if (rectEdge & XZRectEdgeTop) {
        [edgesM addObject:@".top"];
    }
    if (rectEdge & XZRectEdgeLeading) {
        [edgesM addObject:@".leading"];
    }
    if (rectEdge & XZRectEdgeBottom) {
        [edgesM addObject:@".bottom"];
    }
    if (rectEdge & XZRectEdgeTrailing) {
        [edgesM addObject:@".trailing"];
    }
    NSString *string = [edgesM componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"[%@]", string];
}

XZRectEdge XZRectEdgeFromString(NSString * _Nullable aString) {
    XZRectEdge edges = 0;
    if (aString.length >= 4) {
        if ([aString containsString:@".top"]) {
            edges |= XZRectEdgeTop;
        }
        if ([aString containsString:@".leading"]) {
            edges |= XZRectEdgeLeading;
        }
        if ([aString containsString:@".bottom"]) {
            edges |= XZRectEdgeBottom;
        }
        if ([aString containsString:@".trailing"]) {
            edges |= XZRectEdgeTrailing;
        }
    }
    return edges;
}

CGRect CGRectAdjustingSizeByUsingContentMode(CGRect const rect, CGSize const size, UIViewContentMode const contentMode) {
    switch (contentMode) {
        case UIViewContentModeScaleToFill: {
            return rect;
        }
        case UIViewContentModeScaleAspectFit: {
            if (size.width == 0) {
                return CGRectMake(CGRectGetMidX(rect), 0, 0, rect.size.height);
            }
            if (size.height == 0) {
                return CGRectMake(0, CGRectGetMidY(rect), rect.size.width, 0);
            }
            // 先尝试把当前宽度缩放到与容器同宽，判断高度是否大于容器的高度。
            CGFloat const scaledHeight = rect.size.width * (size.height / size.width);
            if (scaledHeight > rect.size.height) {
                // 高度比容器高，那么以容器的高为最大值，计算宽度。
                CGFloat const scaledWidth = rect.size.height * size.width / size.height;
                CGFloat x = (rect.size.width - scaledWidth) * 0.5 + CGRectGetMinX(rect);
                return CGRectMake(x, CGRectGetMinY(rect), scaledWidth, rect.size.height);
            }
            // 高度没有容器高，计算其在垂直方向居中的坐标。
            CGFloat y = (rect.size.height - scaledHeight) * 0.5 + CGRectGetMinY(rect);
            return CGRectMake(CGRectGetMinX(rect), y, rect.size.width, scaledHeight);
        }
        case UIViewContentModeScaleAspectFill: {
            if (size.width == 0 || size.height == 0) {
                return rect;
            }
            // 高度比容器低，则以容器的高度为最大值，计算宽度，并计算其在水平方向居中的坐标。
            CGFloat const scaledHeight = rect.size.width * (size.height / size.width);
            if (scaledHeight < rect.size.height) {
                CGFloat const scaledWidth = rect.size.height * size.width / size.height;
                CGFloat const x = (rect.size.width - scaledWidth) * 0.5 + CGRectGetMinX(rect);
                return CGRectMake(x, CGRectGetMinY(rect), scaledWidth, rect.size.height);
            }
            CGFloat y = (rect.size.height - scaledHeight) * 0.5 + CGRectGetMinY(rect);
            return CGRectMake(CGRectGetMinX(rect), y, rect.size.width, scaledHeight);
        }
        case UIViewContentModeCenter: {
            CGFloat const x = (rect.size.width - size.width) * 0.5 + CGRectGetMinX(rect);
            CGFloat const y = (rect.size.height - size.height) * 0.5 + CGRectGetMinY(rect);
            return CGRectMake(x, y, size.width, size.height);
        }
        case UIViewContentModeTop: {
            CGFloat const x = (rect.size.width - size.width) * 0.5 + CGRectGetMinX(rect);
            return CGRectMake(x, CGRectGetMinY(rect), size.width, size.height);
        }
        case UIViewContentModeBottom: {
            CGFloat const x = (rect.size.width - size.width) * 0.5 + CGRectGetMinX(rect);
            CGFloat const y = CGRectGetMaxY(rect) - size.height;
            return CGRectMake(x, y, size.width, size.height);
        }
        case UIViewContentModeLeft: {
            CGFloat const y = (rect.size.height - size.height) * 0.5 + CGRectGetMinY(rect);
            return CGRectMake(CGRectGetMinX(rect), y, size.width, size.height);
        }
        case UIViewContentModeRight: {
            CGFloat const x = CGRectGetMaxX(rect) - size.height;
            CGFloat const y = (rect.size.height - size.height) * 0.5 + CGRectGetMinY(rect);
            return CGRectMake(x, y, size.width, size.height);
        }
        case UIViewContentModeTopLeft: {
            return CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), size.width, size.height);
        }
        case UIViewContentModeTopRight: {
            CGFloat const x = CGRectGetMaxX(rect) - size.width;
            return CGRectMake(x, CGRectGetMinY(rect), size.width, size.height);
        }
        case UIViewContentModeBottomLeft: {
            CGFloat const y = CGRectGetMaxY(rect) - size.height;
            return CGRectMake(CGRectGetMinX(rect), y, size.width, size.height);
        }
        case UIViewContentModeBottomRight: {
            CGFloat const x = CGRectGetMaxX(rect) - size.width;
            CGFloat const y = CGRectGetMaxY(rect) - size.height;
            return CGRectMake(x, y, size.width, size.height);
        }
        default: {
            return rect;
        }
    }
}
