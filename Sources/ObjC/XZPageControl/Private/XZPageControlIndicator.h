//
//  XZPageControlIndicator.h
//  XZPageControl
//
//  Created by Xezun on 2024/6/10.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZPageControlDefines.h>
#import <XZKit/XZPageControlAttributes.h>
#else
#import "XZPageControlDefines.h"
#import "XZPageControlAttributes.h"
#endif

@class XZPageControl;

NS_ASSUME_NONNULL_BEGIN

/// 在视图创建或设置之前，对象 Item 负责记录对 XZPageControl 的样式设置，
/// 并在需要创建视图，或者被赋值视图时，将这些值传递给视图渲染，这样就不需要
/// 实时的创建视图，而是仅在必要的时候创建即可。
@interface XZPageControlIndicator : NSObject <XZPageControlIndicator>
/// 设置 frame 会懒加载指示器视图。
@property (nonatomic) CGRect frame;
/// XZPageControl 应避免操作此视图。
@property (nonatomic, strong) UIView<XZPageControlIndicator> *view;
@property (nonatomic, strong, readonly) XZPageControlAttributes *attributes;
- (instancetype)initWithPageControl:(XZPageControl *)pageControl attributes:(XZPageControlAttributes *)attributes;
@end

NS_ASSUME_NONNULL_END
