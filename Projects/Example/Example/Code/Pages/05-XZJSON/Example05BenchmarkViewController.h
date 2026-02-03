//
//  Example05BenchmarkViewController.h
//  Example
//
//  Created by 徐臻 on 2025/2/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Example05BenchmarkAction) {
    Example05BenchmarkActionMark,
    Example05BenchmarkActionTime
};

@interface Example05BenchmarkViewController : UIViewController

@property (nonatomic) Example05BenchmarkAction action;

@end

NS_ASSUME_NONNULL_END
