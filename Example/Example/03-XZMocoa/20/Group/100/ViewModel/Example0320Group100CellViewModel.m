//
//  Example0320Group100CellViewModel.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example0320Group100CellViewModel.h"
#import "Example0320Group100CellModel.h"
@import XZExtensions;

@implementation Example0320Group100CellViewModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/20/table/100/:/").viewModelClass = self;
}

- (void)prepare {
    [super prepare];
    
    self.height = 100;
    
    Example0320Group100CellModel *model = self.model;
    self.title = model.title;
    self.image = model.image;
    if (model.date.length > 0) {
        self.details = [NSString stringWithFormat:@"%@  %@", model.date, model.comments];
    } else {
        self.details = model.comments;
    }
} 

- (void)tableView:(XZMocoaTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 通过 url 参数传值
    Example0320Group100CellModel *model = self.model;
    NSURL *url = [NSURL URLWithString:@"https://mocoa.xezun.com/examples/20/content/"];
    [tableView.xz_navigationController pushMocoaURL:url options:@{ @"url": model.url }];
}

@end
