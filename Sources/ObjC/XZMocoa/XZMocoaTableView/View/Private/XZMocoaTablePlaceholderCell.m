//
//  XZMocoaTablePlaceholderCell.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaTablePlaceholderCell.h"
#import "XZMocoaTableView.h"
#import "XZMocoaGroupPlaceholderView.h"
#import "XZMocoaTablePlaceholderCellViewModel.h"

#if DEBUG
@implementation XZMocoaTablePlaceholderCell {
    XZMocoaGroupPlaceholderView *_view;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _view = [[XZMocoaGroupPlaceholderView alloc] initWithFrame:self.bounds];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_view];
    }
    return self;
}

- (void)viewModelDidChange {
    [super viewModelDidChange];
    
    _view.viewModel = [[XZMocoaGroupPlaceholderViewModel alloc] initWithModel:self.viewModel];;
}

@end
#endif
