//
//  XZMocoaCollectionViewController.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

#import <UIKit/UIKit.h>
#import "XZMocoaCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionViewController : UICollectionViewController <XZMocoaCollectionView>
@property (nonatomic, strong) XZMocoaCollectionViewProxy *proxy;
@end

NS_ASSUME_NONNULL_END
