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

@interface Example20ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *identifierLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@end

@implementation Example20ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XZLog(@"设备唯一标识符：%@", XZKeychain.UDID);
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
    NSString *account = asNonEmpty(self.accountTextField.text, (NSString *)nil);
    NSString *server  = asNonEmpty(self.identifierLabel.text, (NSString *)nil);
    XZKeychain<XZKeychainInternetPasswordItem *> *keychain = [XZKeychain keychainWithAccount:account password:nil server:server];
    [self xz_showToast:XZToast.loading(@"处理中") duration:0 offset:CGPointZero completion:nil];
    
    NSError *error = nil;
    if ([keychain search:YES error:&error]) {
        [self xz_showToast:XZToast.message(@"读取成功") duration:3.0 offset:CGPointZero completion:nil];
        self.accountTextField.text = keychain.item.account;
        self.passwordTextField.text = keychain.item.password;
    } else {
        [self xz_showToast:XZToast.message(@"读取失败") duration:3.0 offset:CGPointZero completion:nil];
        self.messageLabel.text = error.localizedDescription;
    }
}

- (IBAction)insertButtonAction:(id)sender {
    self.messageLabel.text = nil;
    NSString *account = asNonEmpty(self.accountTextField.text, (NSString *)nil);
    NSString *server  = asNonEmpty(self.identifierLabel.text, (NSString *)nil);
    if (account == 0 || server == 0) {
        [self xz_showToast:XZToast.message(@"帐号或密码不能为空") duration:3.0 offset:CGPointZero completion:nil];
        return;
    }
    XZKeychain<XZKeychainInternetPasswordItem *> *keychain = [XZKeychain keychainWithAccount:account password:nil server:server];
    keychain.item.password = self.passwordTextField.text;
    [self xz_showToast:XZToast.loading(@"处理中") duration:0 offset:CGPointZero completion:nil];
    
    NSError *error = nil;
    if ([keychain insert:&error]) {
        [self xz_showToast:XZToast.message(@"保存成功") duration:3.0 offset:CGPointZero completion:nil];
    } else {
        [self xz_showToast:XZToast.message(@"保存失败") duration:3.0 offset:CGPointZero completion:nil];
        self.messageLabel.text = error.localizedDescription;
    }
}

- (IBAction)deleteButtonAction:(id)sender {
    self.messageLabel.text = nil;
    NSString *account = asNonEmpty(self.accountTextField.text, (NSString *)nil);
    NSString *server  = asNonEmpty(self.identifierLabel.text, (NSString *)nil);
    XZKeychain<XZKeychainInternetPasswordItem *> *keychain = [XZKeychain keychainWithAccount:account password:nil server:server];
    [self xz_showToast:XZToast.loading(@"处理中") duration:0 offset:CGPointZero completion:nil];
    
    NSError *error = nil;
    if ([keychain delete:&error]) {
        [self xz_showToast:XZToast.message(@"删除成功") duration:3.0 offset:CGPointZero completion:nil];
        
    } else {
        [self xz_showToast:XZToast.message(@"删除失败") duration:3.0 offset:CGPointZero completion:nil];
        self.messageLabel.text = error.localizedDescription;
    }
}

- (IBAction)updateButtonAction:(UIButton *)sender {
    self.messageLabel.text = nil;
    NSString *account = asNonEmpty(self.accountTextField.text, (NSString *)nil);
    NSString *server  = asNonEmpty(self.identifierLabel.text, (NSString *)nil);
    XZKeychain<XZKeychainInternetPasswordItem *> *keychain = [XZKeychain keychainWithAccount:account password:nil server:server];
    [self xz_showToast:XZToast.loading(@"处理中") duration:0 offset:CGPointZero completion:nil];
    
    NSError *error = nil;
    if ([keychain search:NO error:&error]) {
        keychain.item.password = self.passwordTextField.text;
        if ([keychain update:&error]) {
            [self xz_showToast:XZToast.message(@"修改成功") duration:3.0 offset:CGPointZero completion:nil];
        } else {
            [self xz_showToast:XZToast.message(@"修改失败") duration:3.0 offset:CGPointZero completion:nil];
            self.messageLabel.text = error.localizedDescription;
        }
    } else {
        [self xz_showToast:XZToast.message(@"没有找到钥匙串") duration:3.0 offset:CGPointZero completion:nil];
        self.messageLabel.text = error.localizedDescription;
    }
}

@end
