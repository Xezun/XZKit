//
//  ExampleMainHomeHeaderView.h
//  Example
//
//  Created by Xezun on 2026/2/2.
//

@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@interface ExampleMainHomeHeaderView : XZMocoaTableHeaderView
@property (nonatomic, readonly) UILabel *titleLabel;
- (UILabel *)textLabel NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
