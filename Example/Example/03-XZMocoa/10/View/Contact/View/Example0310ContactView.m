//
//  Example0310ContactView.m
//  Example
//
//  Created by Xezun on 2023/7/23.
//

#import "Example0310ContactView.h"
#import "Example0310ContactViewModel.h"
@import SDWebImage;

@implementation Example0310ContactView

+ (Example0310ContactView *)contactView {
    UINib *nib = [UINib nibWithNibName:@"Example0310ContactView" bundle:nil];
    return [nib instantiateWithOwner:nil options:nil].firstObject;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.wrapperView.layer.cornerRadius = 10;
    self.wrapperView.clipsToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)viewModelDidChange:(nullable XZMocoaViewModel *)oldValue {
    [super viewModelDidChange:oldValue];
    
    Example0310ContactViewModel *viewModel = self.viewModel;
    
    self.nameLabel.text = viewModel.name;
    [self.photoImageView sd_setImageWithURL:viewModel.photo];
    self.phoneLabel.text = viewModel.phone;
    self.addressLabel.text = viewModel.address;
    
    [self invalidateIntrinsicContentSize];
}

@end
