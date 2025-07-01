//
//  XZGeometry.m
//  XZGeometry
//
//  Created by 徐臻 on 2025/4/27.
//

#import "XZGeometry.h"

NSDirectionalEdgeInsets NSDirectionalEdgeInsetsFromUIEdgeInsets(UIEdgeInsets const edgeInsets, UIUserInterfaceLayoutDirection const layoutDirection) {
    switch (layoutDirection) {
        case UIUserInterfaceLayoutDirectionLeftToRight:
            return NSDirectionalEdgeInsetsMake(edgeInsets.top, edgeInsets.left, edgeInsets.bottom, edgeInsets.right);
        case UIUserInterfaceLayoutDirectionRightToLeft:
            return NSDirectionalEdgeInsetsMake(edgeInsets.top, edgeInsets.right, edgeInsets.bottom, edgeInsets.left);
    }
}

UIEdgeInsets UIEdgeInsetsFromNSDirectionalEdgeInsets(NSDirectionalEdgeInsets const edgeInsets, UIUserInterfaceLayoutDirection const layoutDirection) {
    switch (layoutDirection) {
        case UIUserInterfaceLayoutDirectionLeftToRight:
            return UIEdgeInsetsMake(edgeInsets.top, edgeInsets.leading, edgeInsets.bottom, edgeInsets.trailing);
        case UIUserInterfaceLayoutDirectionRightToLeft:
            return UIEdgeInsetsMake(edgeInsets.top, edgeInsets.trailing, edgeInsets.bottom, edgeInsets.leading);
    }
}

BOOL CGRectContainsPointInEdgeInsets(CGRect const rect, UIEdgeInsets const edgeInsets, CGPoint const point) {
    CGFloat const minX = CGRectGetMinX(rect);
    if (point.x < minX + edgeInsets.left) {
        return YES;
    }
    CGFloat const maxX = CGRectGetMaxX(rect);
    if (point.x > maxX - edgeInsets.right) {
        return YES;
    }
    CGFloat const minY = CGRectGetMinY(rect);
    if (point.y < minY + edgeInsets.top) {
        return YES;
    }
    return (point.y > CGRectGetMaxY(rect) - edgeInsets.bottom);
}

CGSize CGSizeMakeAspectRatioInside(CGSize const size, CGSize const ratio) {
    if (ratio.width <= 0) {
        return CGSizeMake(0, size.height);
    }
    if (ratio.height <= 0) {
        return CGSizeMake(size.width, 0);
    }
    if (size.width <= 0 || size.height <= 0) {
        return CGSizeZero;
    }
    CGFloat const width  = size.width;
    CGFloat const height = width * ratio.height / ratio.width;
    if (height <= size.height) {
        return CGSizeMake(width, height);
    }
    return CGSizeMake(size.height * ratio.width / ratio.height, size.height);
}

CGSize CGSizeScaleAspectRatioInside(CGSize const size, CGSize const aspect) {
    if (size.width >= aspect.width && size.height >= aspect.height) {
        return aspect;
    }
    return CGSizeMakeAspectRatioInside(size, aspect);
}

CGRect CGRectMakeAspectRatioWithMode(CGRect const rect, CGSize const aspect, UIViewContentMode const contentMode) {
    switch (contentMode) {
        case UIViewContentModeScaleToFill: {
            return rect;
        }
        case UIViewContentModeScaleAspectFit: {
            if (rect.size.width <= 0 || rect.size.height <= 0) {
                return CGRectMake(CGRectGetMidX(rect), CGRectGetMidY(rect), 0, 0);
            }
            if (aspect.width <= 0) {
                return CGRectMake(CGRectGetMidX(rect), CGRectGetMinY(rect), 0, CGRectGetHeight(rect));
            }
            if (aspect.height <= 0) {
                return CGRectMake(CGRectGetMinX(rect), CGRectGetMidY(rect), CGRectGetWidth(rect), 0);
            }
            // 先以容器 rect 宽度进行计算，如果高度超出容器，那么以容器的高为准，重新计算宽度。
            CGFloat const height = rect.size.width * aspect.height / aspect.width;
            if (height > rect.size.height) {
                CGFloat const w = rect.size.height * aspect.width / aspect.height;
                CGFloat const x = (rect.size.width - w) * 0.5 + CGRectGetMinX(rect);
                return CGRectMake(x, CGRectGetMinY(rect), w, rect.size.height);
            }
            CGFloat const y = (rect.size.height - height) * 0.5 + CGRectGetMinY(rect);
            return CGRectMake(CGRectGetMinX(rect), y, rect.size.width, height);
        }
        case UIViewContentModeScaleAspectFill: {
            // 理论上 aspect 宽度或高度为 0 时，当前适配模式下，另一边应该无穷大，这里取两边各 10 倍表示
            if (aspect.width <= 0) {
                CGFloat const y = CGRectGetMinY(rect) - rect.size.height * 10.0;
                return CGRectMake(CGRectGetMinX(rect), y, rect.size.width, rect.size.height * 21.0);
            }
            if (aspect.height <= 0) {
                CGFloat const x = CGRectGetMinX(rect) - rect.size.width * 10.0;
                return CGRectMake(x, CGRectGetMinY(rect), rect.size.width * 21.0, rect.size.height);
            }
            if (rect.size.width <= 0) {
                CGFloat const h = rect.size.height;
                CGFloat const w = h * aspect.width / aspect.height;
                CGFloat const x = CGRectGetMinX(rect) - w * 0.5;
                return CGRectMake(x, CGRectGetMinY(rect), 0, h);
            }
            if (rect.size.height <= 0) {
                CGFloat const w = rect.size.width;
                CGFloat const h = w * aspect.height / aspect.width;
                CGFloat const y = CGRectGetMinY(rect) - h * 0.5;
                return CGRectMake(CGRectGetMinX(rect), y, w, 0);
            }
            CGFloat const h = rect.size.width * aspect.height / aspect.width;
            if (h < rect.size.height) {
                CGFloat const w = rect.size.height * aspect.width / aspect.height;
                CGFloat const x = (rect.size.width - w) * 0.5 + CGRectGetMinX(rect);
                return CGRectMake(x, CGRectGetMinY(rect), w, rect.size.height);
            }
            CGFloat const y = CGRectGetMinY(rect) + (rect.size.height - h) * 0.5;
            return CGRectMake(CGRectGetMinX(rect), y, rect.size.width, h);
        }
        case UIViewContentModeRedraw: {
            return rect;
        }
        case UIViewContentModeCenter: {
            CGFloat const x = CGRectGetMinX(rect) + (rect.size.width - aspect.width) * 0.5;
            CGFloat const y = CGRectGetMinY(rect) + (rect.size.height - aspect.height) * 0.5;
            return CGRectMake(x, y, aspect.width, aspect.height);
        }
        case UIViewContentModeTop: {
            CGFloat const x = CGRectGetMinX(rect) + (rect.size.width - aspect.width) * 0.5;
            return CGRectMake(x, CGRectGetMinY(rect), aspect.width, aspect.height);
        }
        case UIViewContentModeBottom: {
            CGFloat const x = CGRectGetMinX(rect) + (rect.size.width - aspect.width) * 0.5;
            CGFloat const y = CGRectGetMaxY(rect) - aspect.height;
            return CGRectMake(x, y, aspect.width, aspect.height);
        }
        case UIViewContentModeLeft: {
            CGFloat const y = CGRectGetMinY(rect) + (rect.size.height - aspect.height) * 0.5;
            return CGRectMake(CGRectGetMinX(rect), y, aspect.width, aspect.height);
        }
        case UIViewContentModeRight: {
            CGFloat const x = CGRectGetMaxX(rect) - aspect.width;
            CGFloat const y = CGRectGetMinY(rect) + (rect.size.height - aspect.height) * 0.5;
            return CGRectMake(x, y, aspect.width, aspect.height);
        }
        case UIViewContentModeTopLeft: {
            return CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), aspect.width, aspect.height);
        }
        case UIViewContentModeTopRight: {
            CGFloat const x = CGRectGetMaxX(rect) - aspect.width;
            return CGRectMake(x, CGRectGetMinY(rect), aspect.width, aspect.height);
        }
        case UIViewContentModeBottomLeft: {
            CGFloat const y = CGRectGetMaxY(rect) - aspect.height;
            return CGRectMake(CGRectGetMinX(rect), y, aspect.width, aspect.height);
        }
        case UIViewContentModeBottomRight: {
            CGFloat const x = CGRectGetMaxX(rect) - aspect.width;
            CGFloat const y = CGRectGetMaxY(rect) - aspect.height;
            return CGRectMake(x, y, aspect.width, aspect.height);
        }
    }
}

CGRect CGRectMakeAspectRatioInsideWithMode(CGRect const rect, CGSize const ratio, UIViewContentMode const contentMode) {
    CGSize const size = CGSizeMakeAspectRatioInside(rect.size, ratio);
    switch (contentMode) {
        case UIViewContentModeScaleToFill:
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill:
            return CGRectMakeAspectRatioWithMode(rect, size, UIViewContentModeCenter);
        default: {
            return CGRectMakeAspectRatioWithMode(rect, size, contentMode);
        }
    }
}


CGRect CGRectScaleAspectRatioInsideWithMode(CGRect const rect, CGSize const aspect, UIViewContentMode const contentMode) {
    switch (contentMode) {
        case UIViewContentModeScaleToFill:
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill:
            if (aspect.width <= rect.size.width && aspect.height <= rect.size.width) {
                return CGRectMakeAspectRatioWithMode(rect, aspect, UIViewContentModeCenter);
            }
            return CGRectMakeAspectRatioInsideWithMode(rect, aspect, UIViewContentModeCenter);
        default: {
            if (aspect.width <= rect.size.width && aspect.height <= rect.size.width) {
                return CGRectMakeAspectRatioWithMode(rect, aspect, contentMode);
            }
            return CGRectMakeAspectRatioInsideWithMode(rect, aspect, contentMode);
        }
    }
}
