//
//  ExampleSettingsHomeViewController.m
//  Example
//
//  Created by 徐臻 on 2025/7/4.
//

#import "ExampleSettingsHomeViewController.h"
@import XZKit;

@interface ExampleSettingsHomeViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *styleSwitch;

@end

@implementation ExampleSettingsHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.styleSwitch.on = [NSUserDefaults.standardUserDefaults boolForKey:@"modalPresentationStyle"];
}

- (IBAction)defaultLogSwitchAction:(UISwitch *)sender {
    XZLogSystem.defaultLogSystem.isEnabled = sender.isOn;
}

- (IBAction)libraryLogSwitchAction:(UISwitch *)sender {
    XZLogSystem.XZKitLogSystem.isEnabled = sender.isOn;
}

- (IBAction)modalStyleSwitchAction:(UISwitch *)sender {
    [NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:@"modalPresentationStyle"];
}

@end
