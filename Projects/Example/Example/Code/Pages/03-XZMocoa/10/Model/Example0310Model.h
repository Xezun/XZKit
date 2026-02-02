//
//  Example0310Model.h
//  Example
//
//  Created by Xezun on 2023/7/25.
//

#import <Foundation/Foundation.h>
#import "Example0310Contact.h"

NS_ASSUME_NONNULL_BEGIN

@class Example0310ContentModel;

@interface Example0310Model : NSObject
@property (nonatomic, strong) Example0310Contact *contact;
@property (nonatomic, strong) Example0310ContentModel *content;
@end

@interface Example0310ContentModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@end

NS_ASSUME_NONNULL_END
