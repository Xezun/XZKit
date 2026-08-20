//
//  XZSegmentLineIndicatorView.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#import "XZSegmentedControl.h"
#import "XZSegmentIndicatorView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZSegmentLineIndicatorView : XZSegmentIndicatorView
@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic, strong, nullable) UIImage *image;
@end

@interface XZSegmentMarkLineIndicatorView : XZSegmentLineIndicatorView
@end

@interface XZSegmentNoteLineIndicatorView : XZSegmentLineIndicatorView
@end

NS_ASSUME_NONNULL_END
