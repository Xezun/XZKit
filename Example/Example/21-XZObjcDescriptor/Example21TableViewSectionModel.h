//
//  Example21TableViewSectionModel.h
//  Example
//
//  Created by 徐臻 on 2025/1/31.
//

#import <XZMocoa/XZMocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface Example21TableViewSectionModel : XZMocoaTableViewSectionModel
+ (instancetype)modelWithName:(NSString *)name descriptors:(NSArray *)descriptors;
@end

NS_ASSUME_NONNULL_END
