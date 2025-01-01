//
//  Example0330Group109Cell.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Group109Cell.h"
#import "Example0330Group109CellViewModel.h"

@implementation Example0330Group109Cell

+ (void)load {
    XZModule(@"https://mocoa.xezun.com/examples/30/table/109/:/").viewClass = self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.systemTealColor;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)viewModelDidChange {
    Example0330Group109CellViewModel *viewModel = self.viewModel;
    self.textLabel.text = @"Cell视图";
    self.detailTextLabel.text = viewModel.text;
}

@end
