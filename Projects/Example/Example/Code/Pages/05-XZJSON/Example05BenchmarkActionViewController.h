//
//  Example05BenchmarkActionViewController.h
//  Example
//
//  Created by Xezun on 2026/2/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Example05BenchmarkAction) {
    Example05BenchmarkActionMark,
    Example05BenchmarkActionTimeXZDecoding,
    Example05BenchmarkActionTimeXZEncoding,
    Example05BenchmarkActionTimeYYDecoding,
    Example05BenchmarkActionTimeYYEncoding
};

@interface Example05BenchmarkActionViewController : UITableViewController
@property (nonatomic) Example05BenchmarkAction action;
@property (nonatomic, nullable) NSString *name;
@end

NS_ASSUME_NONNULL_END
