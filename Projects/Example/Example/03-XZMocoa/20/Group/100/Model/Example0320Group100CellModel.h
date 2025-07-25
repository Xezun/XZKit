//
//  Example0320Group100CellModel.h
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import <Foundation/Foundation.h>
@import XZKit;

NS_ASSUME_NONNULL_BEGIN

@interface Example0320Group100CellModel : NSObject <XZMocoaModel>
@property (nonatomic, copy) NSString *nid;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSURL *image;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *comments;
@end

NS_ASSUME_NONNULL_END
