//
//  Example21Model.h
//  Example
//
//  Created by 徐臻 on 2025/1/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Example21Model : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSUInteger age;
@property (nonatomic, strong) Example21Model *next;
@property (nonatomic, strong) NSObject<UITableViewDelegate> *delegate;
@property (nonatomic, strong) NSObject<UITableViewDelegate, UITableViewDataSource> *manager;
@property (nonatomic, strong) id<UITableViewDelegate, UITableViewDataSource> dataSource;

- (void)method1:(int)a;
- (void)method2:(NSInteger *)b;
- (void)method3:(Example21Model *)model;
- (Example21Model *)method4;

@end

NS_ASSUME_NONNULL_END
