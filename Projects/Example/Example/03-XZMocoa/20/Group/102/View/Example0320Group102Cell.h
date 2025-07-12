//
//  Example0320Group102Cell.h
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import <UIKit/UIKit.h>
@import XZKit;

@class Example0320Group102CellViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface Example0320Group102Cell : UITableViewCell <XZMocoaTableViewCell>
@property (weak, nonatomic) IBOutlet XZPageView *pageView;
@property (weak, nonatomic) IBOutlet XZPageControl *pageControl;
@end

NS_ASSUME_NONNULL_END
