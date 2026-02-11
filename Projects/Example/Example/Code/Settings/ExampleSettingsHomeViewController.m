//
//  ExampleSettingsHomeViewController.m
//  Example
//
//  Created by 徐臻 on 2025/7/4.
//

#import "ExampleSettingsHomeViewController.h"
@import XZKit;

@interface ExampleSettingsHomeViewController ()

@end

@implementation ExampleSettingsHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)defaultLogSwitchAction:(UISwitch *)sender {
    XZLogSystem.defaultLogSystem.isEnabled = sender.isOn;
}

- (IBAction)libraryLogSwitchAction:(UISwitch *)sender {
    XZLogSystem.XZKitLogSystem.isEnabled = sender.isOn;
}

@end
