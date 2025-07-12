//
//  ExampleSettingsViewController.m
//  Example
//
//  Created by 徐臻 on 2025/7/4.
//

#import "ExampleSettingsViewController.h"
@import XZKit;

@interface ExampleSettingsViewController ()

@end

@implementation ExampleSettingsViewController

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
