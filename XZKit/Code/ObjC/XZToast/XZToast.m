//
//  XZToast.m
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import "XZToast.h"

@implementation XZToast

- (instancetype)initWithContentView:(UIView *)contentView {
    self = [super init];
    if (self) {
        _contentView = contentView;
    }
    return self;
}

//- (instancetype)initWithType:(XZToastType)type text:(NSString *)text image:(UIImage *)image view:(UIView *)view isExclusive:(BOOL)isExclusive {
//    self = [super init];
//    if (self) {
//        _type = type;
//        _text = text.copy;
//        _image = image;
//        _view = view;
//        _isExclusive = isExclusive;
//    }
//    return self;
//}
//
//+ (XZToast *)messageToast:(NSString *)text {
//    return [[self alloc] initWithType:(XZToastTypeMessage) text:text image:nil view:nil isExclusive:NO];
//}
//
//+ (XZToast *)loadingToast:(NSString *)text {
//    return [[self alloc] initWithType:(XZToastTypeLoading) text:text image:nil view:nil isExclusive:NO];
//}

@end


@implementation UIResponder (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset exclusive:(BOOL)exclusive completion:(void (^)(BOOL))completion {
    
}

- (void)xz_hideToast:(void (^)(BOOL))completion {
    
}

@end

@implementation UIView (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset exclusive:(BOOL)exclusive completion:(void (^)(BOOL))completion {
    [self.nextResponder xz_showToast:toast duration:duration position:position offset:offset exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(void (^)(BOOL))completion {
    [self.nextResponder xz_hideToast:completion];
}

@end


@implementation UIWindow (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset exclusive:(BOOL)exclusive completion:(void (^)(BOOL))completion {
    [self.rootViewController xz_showToast:toast duration:duration position:position offset:offset exclusive:exclusive completion:completion];
}

- (void)xz_hideToast:(void (^)(BOOL))completion {
    [self.rootViewController xz_hideToast:completion];
}

@end


@implementation UIViewController (XZToast)

- (void)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(NSDirectionalRectEdge)position offset:(CGFloat)offset exclusive:(BOOL)exclusive completion:(void (^)(BOOL))completion {
    
}

- (void)xz_hideToast:(void (^)(BOOL))completion {
    
}

@end

@interface XZToastItem : NSObject

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSDirectionalRectEdge edge;
@property (nonatomic) CGFloat offset;
@property (nonatomic, copy) id completion;

@property (nonatomic, readonly) UIView *view;

@end


@interface XZToastManager : NSObject

@property (nonatomic, readonly) BOOL isExclusive;

@property (nonatomic) NSArray<XZToastItem *> *items;

- (void)pushItem:(XZToastItem *)item;

@property (nonatomic) NSArray<UIView *> *subviews;

@end

@implementation XZToastManager {
    NSMutableArray<XZToastItem *> *_waitingToasts;
    NSMutableArray<XZToastItem *> *_showingToasts;
    
    BOOL _needsDisplayToasts;
    NSMutableArray<UIView *> *_toastViews;
    UIView *_containerView;
}

- (void)pushItem:(XZToastItem *)item {
    [_waitingToasts addObject:item];
    
}

- (void)setNeedsDisplayToasts {
    if (_needsDisplayToasts) {
        return;
    }
    _needsDisplayToasts = YES;
    [NSRunLoop.mainRunLoop performInModes:@[NSRunLoopCommonModes] block:^{
        [self displayToastsIfNeeded];
    }];
}

- (void)displayToastsIfNeeded {
    if (!_needsDisplayToasts) {
        return;
    }
    
    XZToastItem *item = _waitingToasts.firstObject;
    if (item == nil) {
        _needsDisplayToasts = NO;
        return;
    }
    [_waitingToasts removeObjectAtIndex:0];
    
    UIView *toastView = item.view;
    
    NSUInteger index = [_toastViews indexOfObject:toastView];
    if (index == NSNotFound) {
        [_toastViews addObject:toastView];
        
        [toastView sizeToFit];
        
        toastView.alpha = 0;
        
        CGRect frame = toastView.frame;
        //toastView.frame = CGRectZero;
        
        
        [UIView animateWithDuration:0.3 animations:^{
            for (UIView *toastView in _toastViews) {
                toastView.frame = CGRectOffset(toastView.frame, 0, -10 - frame.size.height);
            }
            toastView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self displayToastsIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            [toastView sizeToFit];
            
            CGRect frame = toastView.frame;
            
            for (NSUInteger i = index + 1; i < _toastViews.count; i++) {
                UIView *toastView = _toastViews[i];
                toastView.frame = CGRectOffset(toastView.frame, 0, -10.0 - frame.size.height);
            }
            
            if (index != _toastViews.count - 1) {
                [_toastViews removeObjectAtIndex:index];
                [_toastViews addObject:toastView];
            }
            
            
        } completion:^(BOOL finished) {
            [self displayToastsIfNeeded];
        }];
    }
    
    
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
    } completion:^(BOOL finished) {
        
    }];
    
    
    NSRange const range = NSMakeRange(0, MIN(3, _waitingToasts.count));
    
    NSArray<XZToastItem *> *items = [_waitingToasts subarrayWithRange:range];
    [_waitingToasts removeObjectsInRange:range];
    
    
    
    for (NSInteger i = 0; i < 3 && i < _waitingToasts.count; i++) {
        XZToastItem *item = _waitingToasts.firstObject;
        [_waitingToasts removeObjectAtIndex:0];
        [_showingToasts addObject:item];
    }
    _needsDisplayToasts = NO;
}

- (void)displayToastViews {
    
}

@end
