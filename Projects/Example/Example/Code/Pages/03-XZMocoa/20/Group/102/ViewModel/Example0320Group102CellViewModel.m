//
//  Example0320Group102CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example0320Group102CellViewModel.h"
#import "Example0320Group102CellModel.h"
@import XZKit;

@implementation Example0320Group102CellViewModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/20/table/102/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    self.height = 156.0;
    
    Example0320Group102CellModel *model = self.model;
    
    NSMutableArray *array = [NSMutableArray array];
    for (Example0320Group102CellModelItem *obj in model.items) {
        [array addObject:obj.image];
    }
    self.images = array;
}

- (void)tableViewCell:(UITableViewCell *)cell wasSelectedAtIndexPath:(NSIndexPath *)indexPath {
    Example0320Group102CellModel *model = self.model;
    Example0320Group102CellModelItem *item = model.items[self.currentIndex];
    NSURL *url = [NSURL URLWithString:@"https://mocoa.xezun.com/examples/20/content/"];
    [self.navigationController pushMocoaURL:url options:@{ @"url": item.url }];
}

@end
