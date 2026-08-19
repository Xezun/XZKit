//
//  XZSegmentLineIndicatorView.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZSegmentedControl.h>
#import <XZKit/XZSegmentIndicatorView.h>
#else
#import "XZSegmentedControl.h"
#import "XZSegmentIndicatorView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZSegmentLineIndicatorView : XZSegmentIndicatorView
@end

@interface XZSegmentMarkLineIndicatorView : XZSegmentLineIndicatorView
@end

@interface XZSegmentNoteLineIndicatorView : XZSegmentLineIndicatorView
@end

NS_ASSUME_NONNULL_END
