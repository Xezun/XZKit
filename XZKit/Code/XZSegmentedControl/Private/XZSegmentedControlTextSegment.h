//
//  XZSegmentedControlTextSegment.h
//  XZSegmentedControl
//
//  Created by 徐臻 on 2024/6/25.
//

#import <UIKit/UIKit.h>
#import "XZSegmentedControl.h"

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
