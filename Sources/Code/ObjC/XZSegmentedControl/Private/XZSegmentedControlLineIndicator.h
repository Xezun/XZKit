//
//  XZSegmentedControlLineIndicator.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZSegmentedControl.h>
#import <XZKit/XZSegmentedControlIndicator.h>
#else
#import "XZSegmentedControl.h"
#import "XZSegmentedControlIndicator.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZSegmentedControlLineIndicator : XZSegmentedControlIndicator
@end

@interface XZSegmentedControlMarkLineIndicator : XZSegmentedControlLineIndicator
@end

@interface XZSegmentedControlNoteLineIndicator : XZSegmentedControlLineIndicator
@end

NS_ASSUME_NONNULL_END
