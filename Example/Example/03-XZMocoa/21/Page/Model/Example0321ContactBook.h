//
//  Example0321ContactBook.h
//  Example
//
//  Created by Xezun on 2021/4/26.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <XZMocoa/XZMocoa.h>
#import "Example0321Contact.h"

NS_ASSUME_NONNULL_BEGIN

@class Example0321ContactBook;

@interface Example0321ContactBook : NSObject <XZMocoaModel, XZMocoaTableModel, XZMocoaTableViewSectionModel>

@property (nonatomic, copy) NSArray *contacts;

@end

NS_ASSUME_NONNULL_END
