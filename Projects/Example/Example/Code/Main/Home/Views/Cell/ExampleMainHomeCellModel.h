//
//  ExampleMainHomeCellModel.h
//  Example
//
//  Created by Xezun on 2026/2/2.
//

#import <Foundation/Foundation.h>
@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@interface ExampleMainHomeCellModel : NSObject <XZMocoaTableCellModel, XZJSONCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *identifier;

@end

NS_ASSUME_NONNULL_END
