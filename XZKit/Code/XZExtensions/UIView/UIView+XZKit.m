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
    [self xz_enumerateHierarchy:block hierarchy:0 stop:&stop];
}

/// 返回值为是否终止遍历。
- (BOOL)xz_enumerateHierarchy:(NS_NOESCAPE XZViewHierarchyEnumerator)block hierarchy:(NSInteger)hierarchy stop:(BOOL *)stop {
    // 将当前视图被遍历，并获取是否继续遍历子视图。
    if (!block(self, hierarchy, stop)) {
        return *stop;
    }
    
    // 遍历终止了。
    if (*stop) {
        return YES;
    }
    
    // 遍历子视图。
    hierarchy += 1;
    for (UIView *subview in self.subviews) {
        if ([subview xz_enumerateHierarchy:block hierarchy:hierarchy stop:stop]) {
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
    NSMutableArray * const descriptionsM = [NSMutableArray array];
    [self xz_enumerateHierarchy:^BOOL(__kindof UIView * _Nonnull subview, NSInteger const hierarchy, BOOL * _Nonnull stop) {
        NSString * const clsName = NSStringFromClass(subview.class);
        NSString * const content = [subview xz_contentForDescription];
        NSString * const padding = [@"|" stringByPaddingToLength:(hierarchy * 4 + 1) withString:@"   |" startingAtIndex:0];
        
        NSString * const description = [NSString stringWithFormat:@"%@ %@<%p, %@>", padding, clsName, self, content];
        [descriptionsM addObject:description];
        
        return YES;
    }];
    return [descriptionsM componentsJoinedByString:@"\n"];
}

- (NSString *)xz_contentForDescription {
    CGRect const frame = self.frame;
    return [NSString stringWithFormat:@"frame(%.2f, %.2f, %.2f, %.2f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height];
}

@end

@implementation UILabel (XZDescription)

- (NSString *)xz_contentForDescription {
    NSString *text = self.text;
    if (text.length > 10) {
        return [NSString stringWithFormat:@"text(%@...), %@", text, super.xz_contentForDescription];
    }
    return [NSString stringWithFormat:@"text(%@), %@", text, super.xz_contentForDescription];
}

@end

@implementation UIImageView (XZDescription)

- (NSString *)xz_contentForDescription {
    UIImage * const image = self.image;
    if (image == nil) {
        [NSString stringWithFormat:@"image(nil), %@", super.xz_contentForDescription];
    }
    CGSize const size = image.size;
    return [NSString stringWithFormat:@"image(%.2f, %.2f, @%.0fx), %@", size.width, size.height, image.scale, super.xz_contentForDescription];
}

@end
