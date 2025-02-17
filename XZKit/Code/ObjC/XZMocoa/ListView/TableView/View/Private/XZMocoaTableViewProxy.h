//
//  XZMocoaTableViewProxy.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

#import <Foundation/Foundation.h>
#import "XZMocoaTableView.h"

NS_ASSUME_NONNULL_BEGIN

/// UITableView 在调用 delegate 和 dataSource 方法时，使用的是方法 imp 缓存，不会方法转发流程。
/// 因此 delegate 和 dataSource 必须有方法的实现，否则无法接收事件。
@interface XZMocoaTableViewProxy : NSProxy <XZMocoaTableView>
+ (id)alloc NS_UNAVAILABLE;
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
