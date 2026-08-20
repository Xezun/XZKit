//
//  XZSegmentLayout.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#import <UIKit/UIKit.h>
#import "XZSegmentedControl.h"
#import "XZSegmentIndicatorView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZSegmentLayout ()

- (instancetype)initWithSegmentedControl:(XZSegmentedControl *)segmentedControl indicatorClass:(Class)indicatorClass NS_DESIGNATED_INITIALIZER;

@property (nonatomic) Class indicatorClass;
@property (nonatomic, readonly) XZSegmentIndicatorLayoutAttributes *indicatorLayoutAttributes;

- (void)invalidateIndicatorLayout:(CGFloat)interactiveTransition;

@end

NS_ASSUME_NONNULL_END
