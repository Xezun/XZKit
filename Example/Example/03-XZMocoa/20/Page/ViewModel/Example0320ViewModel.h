//
//  Example0320ViewModel.h
//  Example
//
//  Created by Xezun on 2023/7/23.
//

@import XZMocoa;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Example0320State) {
    Example0320StateDefault,
    Example0320StateRefresh,
    Example0320StateLoading,
};

@interface Example0320ViewModel : XZMocoaViewModel

@property (nonatomic, strong) XZMocoaTableViewModel *tableViewModel;

@property (nonatomic) Example0320State state;
@property (nonatomic, setter=setHeaderRefreshing:) BOOL isHeaderRefreshing;
@property (nonatomic, setter=setFooterRefreshing:) BOOL isFooterRefreshing;

- (void)refreshingHeaderDidBeginAnimating;
- (void)refreshingFooterDidBeginAnimating;

@end

NS_ASSUME_NONNULL_END
