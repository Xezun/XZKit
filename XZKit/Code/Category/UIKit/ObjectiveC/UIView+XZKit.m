//
//  UIView.m
//  XZKit
//
//  Created by Xezun on 2019/3/16.
//

#import "UIView+XZKit.h"

@implementation UIView (XZKit)

+ (UIView *)xz_snapshotViewAfterScreenUpdates:(BOOL)afterUpdates {
    UIView *snapView1 = [UIApplication.sharedApplication.keyWindow snapshotViewAfterScreenUpdates:NO];
    if (snapView1 == nil) {
        return nil;
    }
    UIView *snapView2 = [(UIView *)[UIApplication.sharedApplication valueForKey:@"statusBar"] snapshotViewAfterScreenUpdates:NO];
    if (snapView2 != nil) {
        [snapView1 addSubview:snapView2];
    }
    return snapView1;
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
