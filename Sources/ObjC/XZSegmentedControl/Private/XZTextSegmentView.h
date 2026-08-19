//
//  XZTextSegmentView.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZSegmentedControl.h>
#else
#import "XZSegmentedControl.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZTextSegmentView : XZSegmentView
@property (nonatomic, weak) XZSegmentedControl *segmentedControl;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic) NSDirectionalEdgeInsets edgeInsets;
@end

@interface XZTextSegmentLabel : UILabel
@end

@interface XZTextSegmentItem : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic) CGSize size;
@property (nonatomic) NSDirectionalEdgeInsets edgeInsets;
@property (nonatomic) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
