//
//  Example0330Model.h
//  Example
//
//  Created by Xezun on 2023/8/20.
//

@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@interface Example0330Model : NSObject

@end

@interface Example0330TextModel : NSObject <XZMocoaModel, XZJSONCoding>
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *mocoaName;
@end

@interface Example0330GroupSectionModel : NSObject <XZMocoaModel, XZJSONCoding>
@property (nonatomic, copy, nullable) NSString *mocoaName;
@property (nonatomic, strong, nullable) Example0330TextModel *header;
@property (nonatomic, copy, nullable) NSArray *cells;
@property (nonatomic, strong, nullable) Example0330TextModel *footer;
@end

@interface Example0330GroupModel : NSObject <XZMocoaGroupModel>
@property (nonatomic, copy, nullable) NSArray<Example0330GroupSectionModel *> *sections;
+ (instancetype)modelWithSections:(NSArray<Example0330GroupSectionModel *> *)sections;
@end

NS_ASSUME_NONNULL_END
