//
//  Example0311ViewModel.h
//  Example
//
//  Created by Xezun on 2023/7/23.
//

@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@class Example0311ViewModel;

@interface Example0311ViewModel : XZMocoaViewModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *photo;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSAttributedString *content;

@end

NS_ASSUME_NONNULL_END
