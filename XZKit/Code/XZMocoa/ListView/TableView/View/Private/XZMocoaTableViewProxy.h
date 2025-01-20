//
//  XZMocoaTableViewProxy.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

#import <Foundation/Foundation.h>
#import "XZMocoaTableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaTableViewProxy : NSProxy <XZMocoaTableView>
@property (nonatomic, unsafe_unretained, readonly) id<XZMocoaTableView> tableView;
@property (nonatomic, strong, nullable) XZMocoaTableViewModel *viewModel;
@property (nonatomic, weak) id<UITableViewDelegate> delegate;
@property (nonatomic, weak) id<UITableViewDataSource> dataSource;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTableView:(id<XZMocoaTableView>)tableView;
@end

/// 协议 UITableViewDataSource 中已实现方法列表。
@interface XZMocoaTableViewProxy (UITableViewDataSource) <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (__kindof UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

/// 协议 UITableViewDelegate 中已实现方法列表。
@interface XZMocoaTableViewProxy (UITableViewDelegate) <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

/// 已实现了 XZMocoaTableViewModelDelegate 的全部方法
@interface XZMocoaTableViewProxy (XZMocoaTableViewModelDelegate) <XZMocoaTableViewModelDelegate>
@end

NS_ASSUME_NONNULL_END
