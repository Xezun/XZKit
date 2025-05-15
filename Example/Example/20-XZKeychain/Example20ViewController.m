//
//  Example20ViewController.m
//  Example
//
//  Created by Xezun on 2025/1/15.
//

#import "Example20ViewController.h"
@import XZKeychain;
@import XZDefines;
@import XZToast;

@interface Example20ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *identifierLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@end

@implementation Example20ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * const UDID = XZKeychain.UDID;
    XZLog(@"设备唯一标识符：%@", UDID);
    self.messageLabel.text = [NSString stringWithFormat:@"设备标识符\n%@", UDID];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)searchButtonAction:(id)sender {
    self.messageLabel.text = nil;
    NSString * const domain  = asNonEmpty(self.identifierLabel.text, @"XZKeychain.xezun.com");
    NSString * const account = asNonEmpty(self.accountTextField.text, (NSString *)nil);
    XZKeychain<XZKeychainInternetPasswordItem *> *keychain = [XZKeychain keychainWithAccount:account domain:domain];
    [self xz_showToast:[XZToast sharedToast:(XZToastStyleLoading) text:@"处理中"] duration:0 completion:nil];
    
    NSError *error = nil;
    if ([keychain search:YES error:&error]) {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleSuccess) text:@"读取成功"]];
        self.accountTextField.text = keychain.item.account;
        self.passwordTextField.text = keychain.item.password;
    } else {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleFailure) text:@"读取失败"]];
        self.messageLabel.text = error.localizedDescription;
    }
}

- (IBAction)insertButtonAction:(id)sender {
    NSString * const domain  = asNonEmpty(self.identifierLabel.text, @"XZKeychain.xezun.com");
    
    self.messageLabel.text = nil;
    
    NSString * const account = asNonEmpty(self.accountTextField.text, (NSString *)nil);
    if (account == nil) {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleWarning) text:@"帐号不能为空"]];
        return;
    }
    
    NSString * const password  = asNonEmpty(self.identifierLabel.text, (NSString *)nil);
    if (password == nil) {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleWarning) text:@"密码不能为空"]];
        return;
    }
    
    XZKeychain<XZKeychainInternetPasswordItem *> *keychain = [XZKeychain keychainWithAccount:account domain:domain];
    keychain.item.password = self.passwordTextField.text;
    [self xz_showToast:[XZToast sharedToast:(XZToastStyleLoading) text:@"处理中"] duration:0 completion:nil];
    
    NSError *error = nil;
    if ([keychain insert:&error]) {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleSuccess) text:@"添加成功"]];
    } else {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleFailure) text:@"添加失败"]];
        self.messageLabel.text = error.localizedDescription;
    }
}

- (IBAction)deleteButtonAction:(id)sender {
    NSString * const domain  = asNonEmpty(self.identifierLabel.text, @"XZKeychain.xezun.com");
    
    self.messageLabel.text = nil;
    NSString * const account = asNonEmpty(self.accountTextField.text, (NSString *)nil);
    if (account == nil) {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleWarning) text:@"帐号不能为空"]];
        return;
    }
    
    XZKeychain<XZKeychainInternetPasswordItem *> *keychain = [XZKeychain keychainWithAccount:account domain:domain];
    [self xz_showToast:[XZToast sharedToast:(XZToastStyleLoading) text:@"处理中"] duration:0 completion:nil];
    
    NSError *error = nil;
    if ([keychain delete:&error]) {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleSuccess) text:@"删除成功"]];
    } else {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleFailure) text:@"删除失败"]];
        self.messageLabel.text = error.localizedDescription;
    }
}

- (IBAction)updateButtonAction:(UIButton *)sender {
    NSString * const domain  = asNonEmpty(self.identifierLabel.text, @"XZKeychain.xezun.com");
    
    self.messageLabel.text = nil;
    NSString * const account = asNonEmpty(self.accountTextField.text, (NSString *)nil);
    if (account == nil) {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleWarning) text:@"帐号不能为空"]];
        return;
    }
    
    NSString * const password  = asNonEmpty(self.identifierLabel.text, (NSString *)nil);
    if (password == nil) {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleWarning) text:@"密码不能为空"]];
        return;
    }
    
    XZKeychain<XZKeychainInternetPasswordItem *> *keychain = [XZKeychain keychainWithAccount:account domain:domain];
    [self xz_showToast:[XZToast sharedToast:(XZToastStyleLoading) text:@"处理中"] duration:0 completion:nil];
    
    NSError *error = nil;
    if ([keychain search:NO error:&error]) {
        keychain.item.password = self.passwordTextField.text;
        if ([keychain update:&error]) {
            [self xz_showToast:[XZToast sharedToast:(XZToastStyleSuccess) text:@"修改成功"]];
        } else {
            [self xz_showToast:[XZToast sharedToast:(XZToastStyleFailure) text:@"修改失败"]];
            self.messageLabel.text = error.localizedDescription;
        }
    } else {
        [self xz_showToast:[XZToast sharedToast:(XZToastStyleWarning) text:@"没有找到钥匙串"]];
        self.messageLabel.text = error.localizedDescription;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

@end
