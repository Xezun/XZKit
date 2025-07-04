//
//  Example0322TextModel.h
//  Example
//
//  Created by Xezun on 2023/8/9.
//

@import XZMocoaCore;

NS_ASSUME_NONNULL_BEGIN

@interface Example0322TextModel : NSObject <XZMocoaCollectionViewCellModel>
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;

@property (nonatomic, copy) NSString *phone;

+ (Example0322TextModel *)contactWithFirstName:(NSString *)firstName lastName:(NSString *)lastName phone:(NSString *)phone;
+ (Example0322TextModel *)contactForIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
