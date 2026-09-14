//
//  XZSegmentLayout.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#import <UIKit/UIKit.h>
#if __has_include("XZKit.h")
#import "XZSegmentedControl.h"
#import "XZSegmentIndicatorView.h"
#else
#import <XZKit/XZSegmentedControl.h>
#import <XZKit/XZSegmentIndicatorView.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZSegmentLayout ()

- (instancetype)initWithSegmentedControl:(XZSegmentedControl *)segmentedControl indicatorClass:(Class)indicatorClass NS_DESIGNATED_INITIALIZER;

@property (nonatomic) Class indicatorClass;
@property (nonatomic, readonly) XZSegmentIndicatorLayoutAttributes *indicatorLayoutAttributes;

- (void)invalidateIndicatorLayout:(CGFloat)interactiveTransition;

@end

NS_ASSUME_NONNULL_END
