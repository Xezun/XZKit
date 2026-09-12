//
//  Example0312Cell.m
//  Example
//
//  Created by Xezun on 2023/8/21.
//

#import "Example0312Cell.h"
#import "Example0312CellViewModel.h"

@implementation Example0312Cell

+ (void)load {
    XZMocoaModule *module = XZMocoa(@"https://mocoa.xezun.com/examples/03/12/table");
    module.header.viewClass = UITableViewHeaderFooterView.class;
    module.cell.viewNibClass = self;
    module.footer.viewClass = UITableViewHeaderFooterView.class;
}

- (void)prepareForViewModel {
    [super prepareForViewModel];
    
    Example0312CellViewModel *viewModel = self.viewModel;
    
    self.nameLabel.text = viewModel.name;
}

@end
