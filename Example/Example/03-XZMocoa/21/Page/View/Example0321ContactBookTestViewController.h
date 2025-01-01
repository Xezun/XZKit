//
//  Example0321ContactBookTestViewController.h
//  Example
//
//  Created by Xezun on 2021/7/12.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Example0321ContactBookTestViewController;
@protocol Example0321ContactBookTestViewControllerDelegate <NSObject>
- (void)testVC:(Example0321ContactBookTestViewController *)textVC didSelectTestActionAtIndex:(NSUInteger)index;
@end

@interface Example0321ContactBookTestViewController : UITableViewController

@property (nonatomic, weak) id<Example0321ContactBookTestViewControllerDelegate> delegate;

- (instancetype)initWithTestActions:(NSArray<NSString *> *)testActions;

@end

NS_ASSUME_NONNULL_END
