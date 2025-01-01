//
//  Example0322GroupTextSectionViewModel.m
//  Example
//
//  Created by Xezun on 2023/8/10.
//

#import "Example0322GroupTextSectionViewModel.h"

@implementation Example0322GroupTextSectionViewModel
+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/22/").section.viewModelClass = self;
}
- (void)prepare {
    [super prepare];
    
    self.minimumLineSpacing = 10;
    self.minimumInteritemSpacing = 10;
    self.insets = UIEdgeInsetsMake(10, 10, 10, 10);
}
@end
