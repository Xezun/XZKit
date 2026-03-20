//
//  Example17Model.h
//  Example
//
//  Created by 徐臻 on 2026/3/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Example17Configuration;
@interface Example17Model : NSObject

@property (nonatomic) Example17Configuration *current;
@property (nonatomic) Example17Configuration *next;

- (instancetype)initWithConfiguration:(Example17Configuration *)configuration NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(_:));

@end

NS_ASSUME_NONNULL_END
