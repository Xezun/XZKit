//
//  UIView+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/6/22.
//

#import "UIView+XZKit.h"
@import ObjectiveC;

static UITextField *_secureView = nil;
static UIView      *_canvasView = nil;

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

- (void)xz_setSecureContentMode:(BOOL)xz_secureContentMode {
    if (xz_secureContentMode) {
        if (_secureView == nil) {
            _secureView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
            _canvasView = _secureView.textInputView;
            if (_canvasView == nil) {
                for (UIView *view in _secureView.subviews) {
                    // iOS 14.1 -> _UITextFieldCanvasView
                    // iOS 15.0 -> _UITextLayoutCanvasView
                    if ([NSStringFromClass(view.class) hasSuffix:@"CanvasView"]) {
                        _canvasView = view;
                        break;
                    }
                }
            }
        }
        if (_canvasView == nil) {
            return; // 没找到，则不支持
        }
        
        // 通过逆向 -[UITextField setSecureTextEntry:] 方法所知，实现防录屏、截屏功能最终是通过
        // 设置 [_textCanvasView.layer setDisableUpdateMask:0x12] 实现的。
        // https://sidorov.tech/en/all/mastering-screen-recording-detection-in-ios-apps/
        // 但是由于这是私有接口，所以我们通过 UITextField 来达到修改 CALayer.disableUpdateMask 属性的目的。
        // 1、通过 KVC 替换 UITextField->_textCanvasView 的 layer 为当前视图的 layer
        // 2、修改 UITextField.secureTextEntry 属性，就会实际修改的就是当前视图的 layer
        // 3、恢复 UITextField->_textCanvasView 的 layer
        // 由于 UIView.layer 是只读属性，通过 KVC 可以直接访问 layer 属性的实例变量。
        
        CALayer * const textLayer = _canvasView.layer;
        _secureView.secureTextEntry = NO;
        [_canvasView setValue:self.layer forKey:@"layer"];
        _secureView.secureTextEntry = YES;
        [_canvasView setValue:textLayer forKey:@"layer"];
    } else if (_canvasView) {
        CALayer * const textLayer = _canvasView.layer;
        _secureView.secureTextEntry = YES;
        [_canvasView setValue:self.layer forKey:@"layer"];
        _secureView.secureTextEntry = NO;
        [_canvasView setValue:textLayer forKey:@"layer"];
    }
    
    objc_setAssociatedObject(self, &_secureView, @(xz_secureContentMode), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)xz_secureContentMode {
    if (_canvasView == nil) {
        return NO;
    }
    return [objc_getAssociatedObject(self, &_secureView) boolValue];
}

@end


@implementation UIView (XZDescription)

- (NSString *)xz_description {
    NSMutableArray  * const descriptionsM = [NSMutableArray array];
    [self xz_enumerateHierarchy:^BOOL(NSInteger const hierarchy, UIView *subview, NSRange indexPath, BOOL *stop) {
        BOOL const isFirst = indexPath.location == 0;
        //BOOL const isLast  = indexPath.location == indexPath.length - 1;
        
        NSString * const clsName = NSStringFromClass(subview.class);
        NSString * const content = [subview xz_contentForDescription];
        NSString * const mark = (isFirst ? @"┏" : @"┣"); // • ┏ ━┗ ┣
        
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
