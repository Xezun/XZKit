//
//  Example21TableViewSectionModel.h
//  Example
//
//  Created by Xezun on 2025/1/31.
//

@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@interface Example21TableViewSectionModel : NSObject <XZMocoaTableSectionModel>
+ (instancetype)modelWithName:(NSString *)name descriptors:(NSArray *)descriptors;
@end

NS_ASSUME_NONNULL_END
