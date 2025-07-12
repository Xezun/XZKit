//
//  XZSegmentedControlTextSegment.h
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

@interface XZSegmentedControlTextSegment : XZSegmentedControlSegment
@property (nonatomic, weak) XZSegmentedControl *segmentedControl;
@property (nonatomic, copy, nullable) NSString *text;
@end

@interface XZSegmentedControlTextLabel : UILabel
@end

@interface XZSegmentedControlTextModel : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic) CGSize size;
@property (nonatomic) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
