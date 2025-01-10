//
//  Example16CollectonViewCellModel.h
//  Example
//
//  Created by 徐臻 on 2024/6/1.
//

#import <Foundation/Foundation.h>
@import XZCollectionViewFlowLayout;

NS_ASSUME_NONNULL_BEGIN

@interface Example16CollectonViewCellModel : NSObject

@property (nonatomic) CGSize size;
@property (nonatomic) UIColor *color;
@property (nonatomic, setter=setCustomized:) BOOL isCustomized;
@property (nonatomic) XZCollectionViewInteritemAlignment interitemAlignment;
- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection;

@end

NS_ASSUME_NONNULL_END
