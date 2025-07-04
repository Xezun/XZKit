//
//  Example0312CellModel.h
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import <Foundation/Foundation.h>
@import XZMocoaCore;

NS_ASSUME_NONNULL_BEGIN

@interface Example0312CellModel : NSObject <XZMocoaTableViewCellModel>
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *phone;
@end

NS_ASSUME_NONNULL_END
