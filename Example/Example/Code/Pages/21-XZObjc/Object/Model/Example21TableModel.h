//
//  Example21TableModel.h
//  Example
//
//  Created by Xezun on 2025/1/31.
//

@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@interface Example21TableModel : NSObject <XZMocoaTableModel>
- (instancetype)initWithSectionModels:(NSArray *)sectionModels;
@end

@interface Example21TableSectionModel : NSObject
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSArray *descriptors;
+ (instancetype)modelWithName:(NSString *)name descriptors:(NSArray *)descriptors;
@end

NS_ASSUME_NONNULL_END
