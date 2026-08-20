//
//  XZSegmentTextItemView.h
//  XZSegmentedControl
//
//  Created by Xezun on 2024/6/25.
//

#import <UIKit/UIKit.h>
#import "XZSegmentedControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZSegmentTextItemView : XZSegmentItemView
@property (nonatomic, weak) XZSegmentedControl *segmentedControl;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic) NSDirectionalEdgeInsets edgeInsets;
@end

@interface XZSegmentTextLabel : UILabel
@end

@interface XZSegmentTextItem : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic) CGSize size;
@property (nonatomic) NSDirectionalEdgeInsets edgeInsets;
@property (nonatomic) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
