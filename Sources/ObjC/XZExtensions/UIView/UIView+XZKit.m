//
//  UIView+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/6/22.
//

#import "UIView+XZKit.h"
@import ObjectiveC;

static const void * const _secureContentDisplay = &_secureContentDisplay;

@implementation UIView (XZKit)

- (void)xz_enumerateSubviewsByUsingBlock:(NS_NOESCAPE XZViewHierarchyEnumerator)enumerator {
    [self xz_enumerateSubviewsWithHierarchy:0 byUsingBlock:enumerator];
}

- (BOOL)xz_enumerateSubviewsWithHierarchy:(NSInteger)hierarchy byUsingBlock:(NS_NOESCAPE XZViewHierarchyEnumerator)enumerator {
    NSArray * const subviews = self.subviews;
    BOOL stop = NO;
    for (NSRange indexPath = NSMakeRange(0, subviews.count); indexPath.location < indexPath.length; indexPath.location++) {
        UIView * const subview = subviews[indexPath.location];
        if (!enumerator(subview, hierarchy, indexPath, &stop)) {
            break;
        }
        if (stop) {
            return YES;
        }
        if ([subview xz_enumerateSubviewsWithHierarchy:(hierarchy + 1) byUsingBlock:enumerator]) {
            return YES;
        }
    }
    return stop;
}

- (UIImage *)xz_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    CGRect const kBounds = self.bounds;
    UIGraphicsBeginImageContextWithOptions(kBounds.size, YES, 0);
    [self drawViewHierarchyInRect:kBounds afterScreenUpdates:afterUpdates];
    UIImage *snapImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapImage;
}

- (void)xz_setSecureContentDisplay:(BOOL)xz_secureContentDisplay {
    if (self.xz_secureContentDisplay == xz_secureContentDisplay) {
        return;
    }
    
    // 通过逆向 -[UITextField setSecureTextEntry:] 方法所知，实现防录屏、截屏功能最终是通过
    // 设置 [_textCanvasView.layer setDisableUpdateMask:0x12] 实现的。
    // https://sidorov.tech/en/all/mastering-screen-recording-detection-in-ios-apps/
    // 但是由于这是私有接口，所以我们通过 UITextField 来达到修改 CALayer.disableUpdateMask 属性的目的。
    // 1、通过 KVC 替换 UITextField->_textCanvasView 的 layer 为当前视图的 layer
    // 2、修改 UITextField.secureTextEntry 属性，就会实际修改的就是当前视图的 layer
    // 3、恢复 UITextField->_textCanvasView 的 layer
    // 由于 UIView.layer 是只读属性，通过 KVC 可以直接访问 layer 属性的实例变量。
    static UITextField *_secureView = nil;
    static UIView      *_canvasView = nil;
    if (_secureView == nil) {
        _secureView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        // 优先使用 textInputView
        _canvasView = _secureView.textInputView;
        // 查找名称为 CanvasView 的视图
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
    
    if (xz_secureContentDisplay) {
        if (_canvasView) {
            CALayer * const textLayer = _canvasView.layer;
            _secureView.secureTextEntry = NO;
            [_canvasView setValue:self.layer forKey:@"layer"];
            _secureView.secureTextEntry = YES;
            [_canvasView setValue:textLayer forKey:@"layer"];
        } else {
            NSString *key = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:@"ZGlzYWJsZVVwZGF0ZU1hc2s=" options:kNilOptions] encoding:NSUTF8StringEncoding];
            [self.layer setValue:@(0x12) forKey:key];
        }
    } else if (_canvasView) {
        CALayer * const textLayer = _canvasView.layer;
        _secureView.secureTextEntry = YES;
        [_canvasView setValue:self.layer forKey:@"layer"];
        _secureView.secureTextEntry = NO;
        [_canvasView setValue:textLayer forKey:@"layer"];
    }
    
    objc_setAssociatedObject(self, _secureContentDisplay, @(xz_secureContentDisplay), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)xz_secureContentDisplay {
    return [objc_getAssociatedObject(self, _secureContentDisplay) boolValue];
}

- (UIViewController *)xz_viewController {
    UIViewController *viewController = (id)self.nextResponder;
    while (viewController != nil) {
        if ([viewController isKindOfClass:UIViewController.class]) {
            return viewController;
        }
        viewController = (id)viewController.nextResponder;
    }
    return nil;
}

- (UINavigationController *)xz_navigationController {
    UIViewController * const viewController = self.xz_viewController;
    if ([viewController isKindOfClass:UINavigationController.class]) {
        return (UINavigationController *)viewController;
    }
    return viewController.navigationController;
}

- (UITabBarController *)xz_tabBarController {
    UIViewController * const viewController = self.xz_viewController;
    if ([viewController isKindOfClass:UITabBarController.class]) {
        return (UITabBarController *)viewController;
    }
    return viewController.tabBarController;
}

@end

@implementation UIWindow (XZKit)

- (__kindof UIViewController *)xz_viewController {
    return self.rootViewController;
}

@end


@implementation UIView (XZDescription)

- (NSString *)xz_description {
    NSMutableArray  * const descriptionsM = [NSMutableArray array];
    [self xz_enumerateSubviewsByUsingBlock:^BOOL(UIView *subview, NSInteger const hierarchy, NSRange indexPath, BOOL *stop) {
        BOOL const isFirst = indexPath.location == 0;
        //BOOL const isLast  = indexPath.location == indexPath.length - 1;
        
        NSString * const clsName = NSStringFromClass(subview.class);
        NSString * const content = [subview xz_contentForDescription];
        NSString * const mark = (isFirst ? @"┏" : @"┣"); // • ┏ ━┗ ┣
        
        NSString * const padding = [@"" stringByPaddingToLength:(hierarchy * 4) withString:@"┃   " startingAtIndex:0];
        
        NSString *description = [NSString stringWithFormat:@"%@%@ %@<%p, %@>", padding, mark, clsName, subview, content];
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
        return [NSString stringWithFormat:@"%@, image(nil)", super.xz_contentForDescription];
    }
    CGSize const size = image.size;
    return [NSString stringWithFormat:@"%@, image(%.2f, %.2f, @%.0fx)", super.xz_contentForDescription,  size.width, size.height, image.scale];
}

@end


@implementation UIButton (XZKit)

- (NSString *)xz_title {
    return [self titleForState:(UIControlStateNormal)];
}

- (void)xz_setTitle:(NSString *)xz_title {
    [self setTitle:xz_title forState:(UIControlStateNormal)];
}

- (NSAttributedString *)xz_attributedTitle {
    return [self attributedTitleForState:(UIControlStateNormal)];
}

- (void)xz_setAttributedTitle:(NSAttributedString *)xz_attributedTitle {
    [self setAttributedTitle:xz_attributedTitle forState:(UIControlStateNormal)];
}

- (UIImage *)xz_image {
    return [self imageForState:(UIControlStateNormal)];
}

- (void)xz_setImage:(UIImage *)xz_image {
    [self setImage:xz_image forState:(UIControlStateNormal)];
}

- (UIImage *)xz_backgroundImage {
    return [self backgroundImageForState:(UIControlStateNormal)];
}

- (void)xz_setBackgroundImage:(UIImage *)image {
    [self setBackgroundImage:image forState:(UIControlStateNormal)];
}

@end
