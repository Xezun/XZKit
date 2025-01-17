//
//  Example0321ContactEditor.m
//  Example
//
//  Created by Xezun on 2021/4/28.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "Example0321ContactEditor.h"
#import "Example0321ContactEditorInputView.h"
#import "Example0321ContactEditorViewModel.h"


@interface Example0321ContactEditor () <XZMocoaView>
@property (weak, nonatomic) IBOutlet UIView *formView;
@property (weak, nonatomic) IBOutlet Example0321ContactEditorInputView *firstNameView;
@property (weak, nonatomic) IBOutlet Example0321ContactEditorInputView *lastNameView;
@property (weak, nonatomic) IBOutlet Example0321ContactEditorInputView *phoneNumberView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@end

@implementation Example0321ContactEditor

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/21/editor").viewNibClass = self;
}

@dynamic viewModel;

- (void)dealloc {
    [self.viewModel removeFromSuperViewModel];
}

- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options nibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    self = [super initWithMocoaOptions:options nibName:nibName bundle:bundle];
    if (self) {
        self.viewModel = [[Example0321ContactEditorViewModel alloc] initWithModel:options[@"model"]];
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor     = UIColor.clearColor;
    self.view.layer.shadowColor   = UIColor.blackColor.CGColor;
    self.view.layer.shadowOffset  = CGSizeMake(0, 2.0);
    self.view.layer.shadowRadius  = 5.0;
    self.view.layer.shadowOpacity = 0.5;

    self.formView.layer.cornerRadius  = 6.0;
    self.formView.layer.masksToBounds = YES;
    
    Example0321ContactEditorViewModel *viewModel = self.viewModel;
    [viewModel ready];
    self.firstNameView.textField.text   = viewModel.firstName;
    self.lastNameView.textField.text    = viewModel.lastName;
    self.phoneNumberView.textField.text = viewModel.phone;
}

- (IBAction)confirmButtonAction:(UIButton *)sender {
    NSString *firstName = self.firstNameView.textField.text;
    NSString *lastName  = self.lastNameView.textField.text;
    NSString *phone     = self.phoneNumberView.textField.text;
    [self.viewModel setFirstName:firstName lastName:lastName phone:phone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
