//
//  Example16CollectonViewSectionHeaderFooterView.h
//  Example
//
//  Created by 徐臻 on 2024/6/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Example16CollectonViewSectionHeaderFooterView;

@protocol Example16CollectonViewSectionHeaderFooterViewDelegate <NSObject>

- (void)didSelectHeaderFooterView:(Example16CollectonViewSectionHeaderFooterView *)headerFooterView;

@end

@interface Example16CollectonViewSectionHeaderFooterView : UICollectionReusableView
@property (nonatomic) NSInteger index;
@property (nonatomic, weak) id<Example16CollectonViewSectionHeaderFooterViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
