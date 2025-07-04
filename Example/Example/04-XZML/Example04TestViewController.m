//
//  Example04TestViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example04TestViewController.h"
#import "Example04SettingsViewController.h"
@import XZML;
@import XZExtensionsCore;

@interface Example04TestViewController () <UITextViewDelegate> {
    NSMutableDictionary<NSAttributedStringKey, id> *_attributes;
}

@property (weak, nonatomic) IBOutlet UILabel *rawLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *consoleLabel;

@property (weak, nonatomic) IBOutlet UISwitch *securityModeSwitch;

@end

@implementation Example04TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = rgb(0xf1f2f3);
    
    self.title = self.data[@"title"];
    
    _attributes = [NSMutableDictionary dictionaryWithDictionary:@{
//        NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:20.0],
        NSForegroundColorAttributeName: UIColor.blackColor,
        XZMLFontAttributeName: [UIFont fontWithName:@"ChalkboardSE-Regular" size:14.0],
        XZMLSecurityModeAttributeName: @(self.securityModeSwitch.isOn),
        XZMLForegroundColorAttributeName: UIColor.orangeColor,
        XZMLLinkAttributeName: [NSURL URLWithString:@"https://www.baidu.com/s?wd=XZML&ua=app#home"]
    }];

    self.rawLabel.text = self.data[@"xzml"];
    
    self.textView.font = [UIFont systemFontOfSize:20.0];
    self.textView.linkTextAttributes = @{ };
    self.textView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    NSString *xzml = self.data[@"xzml"];

    [self.textView setXZMLText:xzml attributes:_attributes];
    self.textLabel.text = [[NSString alloc] initWithXZMLString:xzml attributes:_attributes];
    
    self.consoleLabel.text = self.textView.attributedText.description;
}

- (IBAction)securitySwitchAction:(UISwitch *)sender {
    _attributes[XZMLSecurityModeAttributeName] = @(self.securityModeSwitch.isOn);
    [self reloadData];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    NSString *message = [NSString stringWithFormat:@"%@", URL];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"链接点击" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    Example04SettingsViewController *settingsVC = segue.destinationViewController;
    if ([settingsVC isKindOfClass:[Example04SettingsViewController class]]) {
        settingsVC.attributes = _attributes;
    }
}

@end
