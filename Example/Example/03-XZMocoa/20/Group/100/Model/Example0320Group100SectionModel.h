//
//  Example0320Group100SectionModel.h
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import <Foundation/Foundation.h>
@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@interface Example0320Group100SectionModel : NSObject <XZMocoaTableViewSectionModel, XZJSONCoding>
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, copy) NSString *gid;
@end

NS_ASSUME_NONNULL_END
