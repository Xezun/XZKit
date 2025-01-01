//
//  Example0310RootView.h
//  Example
//
//  Created by Xezun on 2023/7/25.
//

#import <UIKit/UIKit.h>
#import "Example0310ContactView.h"
#import "Example0310ContentView.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example0310RootView : UIScrollView
@property (nonatomic, strong) Example0310ContactView *contactView;
@property (nonatomic, strong) Example0310ContentView *contentView;
@end

NS_ASSUME_NONNULL_END
