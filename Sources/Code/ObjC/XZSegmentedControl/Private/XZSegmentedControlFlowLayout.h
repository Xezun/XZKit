//
//  XZSegmentedControlFlowLayout.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZSegmentedControl.h>
#import <XZKit/XZSegmentedControlIndicator.h>
#else
#import "XZSegmentedControl.h"
#import "XZSegmentedControlIndicator.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZSegmentedControlFlowLayout : UICollectionViewFlowLayout <XZSegmentedControlLayout>
@property (nonatomic, weak, readonly) XZSegmentedControl *segmentedControl;
- (instancetype)initWithSegmentedControl:(XZSegmentedControl *)segmentedControl NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@property (nonatomic, readonly) NSInteger selectedIndex;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
@property (nonatomic, strong, nullable) UIColor *indicatorColor;
@property (nonatomic, strong, nullable) UIImage *indicatorImage;
@property (nonatomic) CGSize indicatorSize;
@property (nonatomic) CGFloat interactiveTransition;
@property (nonatomic) XZSegmentedControlIndicatorStyle indicatorStyle;
@property (nonatomic, nullable) Class indicatorClass;
@end

NS_ASSUME_NONNULL_END
