//
//  XZGeometry.m
//  XZGeometry
//
//  Created by 徐臻 on 2025/4/27.
//

#import "XZGeometry.h"

CGSize CGSizeMakeAspectRatioInside(CGSize size, CGSize aspect) {
    if (aspect.width <= 0 || aspect.height <= 0) {
        return CGSizeZero;
    }
    if (size.width <= 0 || size.height <= 0) {
        return CGSizeZero;
    }
    CGFloat const width = aspect.width;
    CGFloat const height = aspect.width * size.height / size.width;
    if (height > aspect.height) {
        return CGSizeMake(width, height);
    }
    return CGSizeMake(aspect.height * size.width / size.height, aspect.height);
}

CGSize CGSizeScaleAspectRatioInside(CGSize size, CGSize aspect) {
    if (size.width <= aspect.width && size.height <= aspect.height) {
        return size;
    }
    return CGSizeMakeAspectRatioInside(aspect, size);
}

CGRect CGRectMakeAspectRatioWithMode(CGSize size, CGRect aspect, UIViewContentMode contentMode) {
    switch (contentMode) {
        case UIViewContentModeScaleToFill: {
            return aspect;
        }
        case UIViewContentModeScaleAspectFit: {
            if (aspect.size.width <= 0 || aspect.size.height <= 0) {
                return CGRectMake(CGRectGetMidX(aspect), CGRectGetMidY(aspect), 0, 0);
            }
            if (size.width <= 0 || size.height <= 0) {
                return CGRectMake(CGRectGetMidX(aspect), CGRectGetMidY(aspect), 0, 0);
            }
            CGFloat const height = aspect.size.width * size.height / size.width;
            if (height > aspect.size.height) {
                // 高度比容器高，那么以容器的高为准，重新计算宽度。
                CGFloat const width = aspect.size.height * size.width / size.height;
                CGFloat const x = (aspect.size.width - width) * 0.5 + CGRectGetMinX(aspect);
                return CGRectMake(x, CGRectGetMinY(aspect), width, aspect.size.height);
            }
            // 高度没有容器高，计算其在垂直方向居中的坐标。
            CGFloat const y = (aspect.size.height - height) * 0.5 + CGRectGetMinY(aspect);
            return CGRectMake(CGRectGetMinX(aspect), y, aspect.size.width, height);
        }
        case UIViewContentModeScaleAspectFill: {
            if (aspect.size.width <= 0) {
                CGFloat const h = MAX(0, aspect.size.height);
                return CGRectMake(CGRectGetMinX(aspect), CGRectGetMinY(aspect), 0, h);
            }
            if (aspect.size.height <= 0) {
                CGFloat const w = MAX(0, aspect.size.width);
                return CGRectMake(CGRectGetMinX(aspect), CGRectGetMinY(aspect), w, 0);
            }
            if (size.width <= 0) {
                return CGRectMake(CGRectGetMidX(aspect), CGRectGetMinY(aspect), 0, aspect.size.height);
            }
            if (size.height <= 0) {
                return CGRectMake(CGRectGetMinX(aspect), CGRectGetMidY(aspect), aspect.size.width, 0);
            }
            CGFloat const h = aspect.size.width * size.height / size.width;
            if (h < aspect.size.height) {
                CGFloat const w = aspect.size.height * size.width / size.height;
                CGFloat const x = (aspect.size.width - w) * 0.5 + CGRectGetMinX(aspect);
                return CGRectMake(x, CGRectGetMinY(aspect), w, aspect.size.height);
            }
            CGFloat const y = (aspect.size.height - h) * 0.5 + CGRectGetMinY(aspect);
            return CGRectMake(CGRectGetMinX(aspect), y, aspect.size.width, h);
        }
        case UIViewContentModeRedraw: {
            return aspect;
        }
        case UIViewContentModeCenter: {
            CGFloat const x = (aspect.size.width - size.width) * 0.5 + CGRectGetMinX(aspect);
            CGFloat const y = (aspect.size.height - size.height) * 0.5 + CGRectGetMinY(aspect);
            return CGRectMake(x, y, size.width, size.height);
        }
        case UIViewContentModeTop: {
            CGFloat const x = (aspect.size.width - size.width) * 0.5 + CGRectGetMinX(aspect);
            return CGRectMake(x, CGRectGetMinY(aspect), size.width, size.height);
        }
        case UIViewContentModeBottom: {
            CGFloat const x = (aspect.size.width - size.width) * 0.5 + CGRectGetMinX(aspect);
            CGFloat const y = CGRectGetMaxY(aspect) - size.height;
            return CGRectMake(x, y, size.width, size.height);
        }
        case UIViewContentModeLeft: {
            CGFloat const y = (aspect.size.height - size.height) * 0.5 + CGRectGetMinY(aspect);
            return CGRectMake(CGRectGetMinX(aspect), y, size.width, size.height);
        }
        case UIViewContentModeRight: {
            CGFloat const x = CGRectGetMaxX(aspect) - size.width;
            CGFloat const y = (aspect.size.height - size.height) * 0.5 + CGRectGetMinY(aspect);
            return CGRectMake(x, y, size.width, size.height);
        }
        case UIViewContentModeTopLeft: {
            return CGRectMake(CGRectGetMinX(aspect), CGRectGetMinY(aspect), size.width, size.height);
        }
        case UIViewContentModeTopRight: {
            CGFloat const x = CGRectGetMaxX(aspect) - size.width;
            return CGRectMake(x, CGRectGetMinY(aspect), size.width, size.height);
        }
        case UIViewContentModeBottomLeft: {
            CGFloat const y = CGRectGetMaxY(aspect) - size.height;
            return CGRectMake(CGRectGetMinX(aspect), y, size.width, size.height);
        }
        case UIViewContentModeBottomRight: {
            CGFloat const x = CGRectGetMaxX(aspect) - size.width;
            CGFloat const y = CGRectGetMaxY(aspect) - size.height;
            return CGRectMake(x, y, size.width, size.height);
        }
    }
}


CGRect CGRectScaleAspectRatioWithMode(CGSize size, CGRect aspect, UIViewContentMode contentMode) {
    return CGRectMakeAspectRatioWithMode(CGSizeMakeAspectRatioInside(size, aspect.size), aspect, contentMode);
}
