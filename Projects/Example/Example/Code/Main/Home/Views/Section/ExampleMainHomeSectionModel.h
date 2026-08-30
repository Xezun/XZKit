//
//  ExampleMainHomeSectionModel.h
//  Example
//
//  Created by Xezun on 2026/2/2.
//

#import <Foundation/Foundation.h>
@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@interface ExampleMainHomeSectionModel : NSObject <XZJSONCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *items;

@end

NS_ASSUME_NONNULL_END
