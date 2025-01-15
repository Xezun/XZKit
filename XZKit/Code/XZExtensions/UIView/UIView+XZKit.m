//
//  UIView+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/6/22.
//

#import "UIView+XZKit.h"

@implementation UIView (XZKit)

- (void)xz_enumerateHierarchy:(NS_NOESCAPE XZViewHierarchyEnumerator)block {
    BOOL stop = NO;
    [self xz_enumerateHierarchy:block hierarchy:0 range:NSMakeRange(0, 0) stop:&stop];
}

/// 返回值为是否终止遍历。
- (BOOL)xz_enumerateHierarchy:(NS_NOESCAPE XZViewHierarchyEnumerator)block hierarchy:(NSInteger)hierarchy range:(NSRange)range stop:(BOOL *)stop {
    // 将当前视图被遍历，并获取是否继续遍历子视图。
    if (!block(hierarchy, self, range, stop)) {
        return *stop;
    }
    
    // 遍历终止了。
    if (*stop) {
        return YES;
    }
    
    // 遍历子视图。
    hierarchy += 1;
    NSArray * const subviews = self.subviews;
    range.length = subviews.count;
    for (range.location = 0; range.location < range.length; range.location++) {
        UIView * const subview = subviews[range.location];
        if ([subview xz_enumerateHierarchy:block hierarchy:hierarchy range:range stop:stop]) {
            return YES;
        }
    }
    
    return NO;
}

- (UIImage *)xz_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    CGRect const kBounds = self.bounds;
    UIGraphicsBeginImageContextWithOptions(kBounds.size, YES, 0);
    [self drawViewHierarchyInRect:kBounds afterScreenUpdates:afterUpdates];
    UIImage *snapImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapImage;
}

@end


@implementation UIView (XZDescription)

- (NSString *)xz_description {
    NSMutableArray  * const descriptionsM = [NSMutableArray array];
    [self xz_enumerateHierarchy:^BOOL(NSInteger const hierarchy, UIView *subview, NSRange indexPath, BOOL *stop) {
        BOOL const isFirst = indexPath.location == 0;
        BOOL const isLast  = indexPath.location == indexPath.length - 1;
        
        NSString * const clsName = NSStringFromClass(subview.class);
        NSString * const content = [subview xz_contentForDescription];
        NSString * const mark = (isFirst ? @"┏" : @"┣"); // • ┏ ┗ ┣
        
        NSString * const padding = [@"" stringByPaddingToLength:(hierarchy * 4) withString:@"┃   " startingAtIndex:0];
        
        NSString *description = [NSString stringWithFormat:@"%@%@ %@<%p, %@>", padding, mark, clsName, self, content];;
        [descriptionsM addObject:description];
        
        return YES;
    }];
    return [descriptionsM componentsJoinedByString:@"\n"];
}

- (NSString *)xz_contentForDescription {
    CGRect const frame = self.frame;
    CGFloat const x = CGRectGetMinX(frame);
    CGFloat const y = frame.origin.y;
    CGFloat const w = frame.size.width;
    CGFloat const h = frame.size.height;
    CGFloat const maxX = CGRectGetMaxX(frame);
    CGFloat const maxY = CGRectGetMaxY(frame);
    NSString * const frameDescription = [NSString stringWithFormat:@"frame({%.2f, %.2f}, {%.2f, %.2f}, {%.2f, %.2f})", x, y, w, h, maxX, maxY];
    NSString * const isHidden = self.isHidden ? @"YES" : @"NO";
    NSString * const interactive = self.isUserInteractionEnabled ? @"YES" : @"NO";
    return [NSString stringWithFormat:@"%@, hidden: %@, interactive: %@", frameDescription, isHidden, interactive];
}

@end

@implementation UILabel (XZDescription)

- (NSString *)xz_contentForDescription {
    NSString *text = self.text;
    if (text.length > 10) {
        return [NSString stringWithFormat:@"%@, text(%@...)", super.xz_contentForDescription, text];
    }
    return [NSString stringWithFormat:@"%@, text(%@)", super.xz_contentForDescription, text];
}

@end

@implementation UIImageView (XZDescription)

- (NSString *)xz_contentForDescription {
    UIImage * const image = self.image;
    if (image == nil) {
        [NSString stringWithFormat:@"%@, image(nil)", super.xz_contentForDescription];
    }
    CGSize const size = image.size;
    return [NSString stringWithFormat:@"%@, image(%.2f, %.2f, @%.0fx)", super.xz_contentForDescription,  size.width, size.height, image.scale];
}

@end
