//
//  Example20ViewController.m
//  Example
//
//  Created by 徐臻 on 2025/1/15.
//

#import "Example20ViewController.h"
@import XZKeychain;

@interface Example20ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *identifierLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@end

@implementation Example20ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"设备唯一标识符：%@", [XZKeychain UDID]);
    
    NSString *identifier = self.identifierLabel.text;
    
    // 保存密码
    if ([XZKeychain setPassword:@"XZKeychain" forAccount:@"XZKit" identifier:identifier]) {
        NSLog(@"密码保存成功");
    }
    
    // 读取密码
    NSString *password = [XZKeychain passwordForAccount:@"XZKit" identifier:identifier];
    if (password != nil) {
        NSLog(@"获取成功，密码为：%@", password);
    }
    
    // 删除密码
    if ([XZKeychain setPassword:nil forAccount:@"XZKit" identifier:identifier]) {
        NSLog(@"删除成功");
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)read:(id)sender {
    XZKeychainGenericPasswordItem *item = [[XZKeychainGenericPasswordItem alloc] init];
    item.userInfo = [self.identifierLabel.text dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    XZKeychain *keychain = [XZKeychain keychainForItem:item];
    if ([keychain search:&error]) {
        self.messageLabel.text = @"读取成功";
        self.accountTextField.text = item.account;
        
        NSData *data = keychain.data;
        NSString *password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.passwordTextField.text = password;
    } else {
        self.messageLabel.text = error.localizedDescription;
        self.accountTextField.text = nil;
        self.passwordTextField.text = nil;
    }
}

- (IBAction)write:(id)sender {
    if (self.accountTextField.text.length == 0 || self.passwordTextField.text.length == 0) {
        self.messageLabel.text = @"帐号或密码为空";
        return;
    }
    XZKeychainGenericPasswordItem *item = [[XZKeychainGenericPasswordItem alloc] init];
    item.userInfo = [self.identifierLabel.text dataUsingEncoding:NSUTF8StringEncoding];
    item.account = self.accountTextField.text;
    
    XZKeychain *keychain = [XZKeychain keychainForItem:item];
    
    NSData *data = [self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    keychain.data = data;
    NSError *error = nil;
    if ([keychain insert:&error]) {
        self.messageLabel.text = @"写入成功";
    } else {
        self.messageLabel.text = error.localizedDescription;
    }
}

- (IBAction)remove:(id)sender {
    XZKeychainGenericPasswordItem *item = [[XZKeychainGenericPasswordItem alloc] init];
    item.userInfo = [self.identifierLabel.text dataUsingEncoding:NSUTF8StringEncoding];
    item.account = self.accountTextField.text;
    
    XZKeychain *keychain = [XZKeychain keychainForItem:item];
    NSError *error = nil;
    if ([keychain remove:&error]) {
        self.messageLabel.text = @"删除成功";
    } else {
        self.messageLabel.text = error.localizedDescription;
    }
}

- (IBAction)update:(UIButton *)sender {
    XZKeychainGenericPasswordItem *item = [[XZKeychainGenericPasswordItem alloc] init];
    item.userInfo = [self.identifierLabel.text dataUsingEncoding:NSUTF8StringEncoding];
    item.account  = self.accountTextField.text;
    
    XZKeychain *keychain = [XZKeychain keychainForItem:item];
    if ([keychain search:NULL]) {
        keychain.data = [self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        if ([keychain update:&error]) {
            self.messageLabel.text = @"修改成功";
        } else {
            self.messageLabel.text = error.localizedDescription;
        }
    } else {
        NSLog(@"没有找到钥匙串");
    }
}

@end
