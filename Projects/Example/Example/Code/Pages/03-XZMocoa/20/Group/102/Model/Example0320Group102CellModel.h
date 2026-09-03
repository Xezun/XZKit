//
//  Example0320Group102CellModel.h
//  Example
//
//  Created by Xezun on 2023/7/27.
//

@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@interface Example0320Group102CellModel : NSObject <XZMocoaTableCellModel, XZJSONCoding>
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, copy) NSString *gid;
@end

@interface Example0320Group102CellModelItem : NSObject <XZJSONCoding>
@property (nonatomic, copy) NSString *nid;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSURL *image;
@end

NS_ASSUME_NONNULL_END
