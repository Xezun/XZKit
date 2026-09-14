//
//  ExampleSettingsHomeViewController.m
//  Example
//
//  Created by Xezun on 2025/7/4.
//

#import "ExampleSettingsHomeViewController.h"
@import SDWebImage;
@import XZKit;

@interface ExampleSettingsHomeViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *styleSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *defaultLogSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *XZKitLogSwitch;

@end

@implementation ExampleSettingsHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.defaultLogSwitch.on = XZLogSystem.defaultSystem.isEnabled;
    self.XZKitLogSwitch.on = XZLogSystem.XZKitSystem.isEnabled;
    self.styleSwitch.on = [NSUserDefaults.standardUserDefaults boolForKey:@"modalPresentationStyle"];
}

- (IBAction)defaultLogSwitchAction:(UISwitch *)sender {
    XZLogSystem.defaultSystem.isEnabled = sender.isOn;
    [NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:@"XZLogSystem.defaultSystem.isEnabled"];
}

- (IBAction)libraryLogSwitchAction:(UISwitch *)sender {
    XZLogSystem.XZKitSystem.isEnabled = sender.isOn;
    [NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:@"XZLogSystem.XZKitSystem.isEnabled"];
}

- (IBAction)modalStyleSwitchAction:(UISwitch *)sender {
    [NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:@"modalPresentationStyle"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    break;
                case 1: {
                    [self xz_showToast:[XZToast loadingToast:@"清理中，请稍后"]];
                    [SDWebImageManager.sharedManager.imageCache clearWithCacheType:(SDImageCacheTypeAll) completion:^{
                        [self xz_showToast:[XZToast successToast:@"清理完成"]];
                    }];
                    break;
                }
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

@end
