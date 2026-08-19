//
//  XZSegmentLayout.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZSegmentedControl.h>
#import <XZKit/XZSegmentIndicatorView.h>
#else
#import "XZSegmentedControl.h"
#import "XZSegmentIndicatorView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZSegmentLayout ()
@property (nonatomic, weak, readonly) XZSegmentedControl *segmentedControl;
- (instancetype)initWithSegmentedControl:(XZSegmentedControl *)segmentedControl NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSInteger selectedIndex;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
@property (nonatomic, strong, nullable) UIColor *indicatorColor;
@property (nonatomic, strong, nullable) UIImage *indicatorImage;
@property (nonatomic) CGSize indicatorSize;
@property (nonatomic) CGFloat interactiveTransition;
@property (nonatomic) XZSegmentIndicatorStyle indicatorStyle;
@property (nonatomic, nullable) Class indicatorClass;
@end

NS_ASSUME_NONNULL_END
