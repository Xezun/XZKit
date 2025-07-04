//
//  Example0320Group101SectionModel.h
//  Example
//
//  Created by Xezun on 2023/7/27.
//


@import XZJSON;
@import XZMocoaCore;

NS_ASSUME_NONNULL_BEGIN

@interface Example0320Group101SectionModel : NSObject <XZMocoaTableViewSectionModel, XZJSONCoding>
@property (nonatomic, copy) NSString *gid;
@property (nonatomic, copy) NSArray *items;
@end

NS_ASSUME_NONNULL_END
