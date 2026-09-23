//
//  Example0310ContactView.m
//  Example
//
//  Created by Xezun on 2023/7/23.
//

#define UsesMocoaBind YES

#import "Example0310ContactView.h"
#ifndef UsesMocoaBind
#import "Example0310ContactViewModel.h"
#endif
@import SDWebImage;

@implementation Example0310ContactView

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/03/10/contactView").viewNibClass = self;
}

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

#ifdef UsesMocoaBind
- (void)prepareForViewModel:(__kindof XZMocoaViewModel *)viewModel {
    [super prepareForViewModel:viewModel];
    [viewModel linkTarget:self.nameLabel action:@selector(setText:) forKey:@"name"];
    [viewModel linkTarget:self.photoImageView action:@selector(sd_setImageWithURL:) forKey:@"photo"];
    [viewModel linkTarget:self.phoneLabel action:@selector(setText:) forKey:@"phone"];
    [viewModel linkTarget:self.addressLabel action:@selector(setText:) forKey:@"address"];
}
#else
- (void)prepareForViewModel:(Example0310ContactViewModel *)viewModel {
    [super prepareForViewModel:viewModel];
    
    self.nameLabel.text = viewModel.name;
    [self.photoImageView sd_setImageWithURL:viewModel.photo];
    self.phoneLabel.text = viewModel.phone;
    self.addressLabel.text = viewModel.address;
}
#endif

@end
