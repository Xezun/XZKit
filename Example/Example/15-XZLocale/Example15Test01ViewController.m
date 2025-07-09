//
//  Example15Test01ViewController.m
//  Example
//
//  Created by Xezun on 2024/9/16.
//

#import "Example15Test01ViewController.h"
@import XZKit;

@interface Example15Test01ViewController ()

@property (nonatomic, copy) NSArray<XZLanguage> *languages;
@property (weak, nonatomic) IBOutlet UISwitch *inAppPreferenceSwitch;

@end

@implementation Example15Test01ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.languages = @[XZLanguageChinese, XZLanguageEnglish];
    self.inAppPreferenceSwitch.on = XZLocalization.isInAppLanguagePreferencesEnabled;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if ([self.languages[indexPath.row] isEqual:XZLocalization.preferredLanguage]) {
            if ([XZLocalization.preferredLanguage isEqualToString:XZLocalization.effectiveLanguage]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.detailTextLabel.text = nil;
            } else if (XZLocalization.isInAppLanguagePreferencesEnabled) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = XZLocalizedString(@"新页面生效");
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = XZLocalizedString(@"重启后生效");
            }
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = nil;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XZLanguage newValue = self.languages[indexPath.row];
    if ([newValue isEqualToString:XZLocalization.preferredLanguage]) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"切换应用语言" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    if (XZLocalization.isInAppLanguagePreferencesEnabled) {
        [alert addAction:[UIAlertAction actionWithTitle:@"重建页面，立即切换" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            XZLocalization.preferredLanguage = newValue;
        }]];
    } else {
        [alert addAction:[UIAlertAction actionWithTitle:@"直接切换，重启生效" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            XZLocalization.preferredLanguage = newValue;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:(UITableViewRowAnimationNone)];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"重建界面，立即生效" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            self.inAppPreferenceSwitch.on = YES;
            XZLocalization.isInAppLanguagePreferencesEnabled = YES;
            XZLocalization.preferredLanguage = newValue;
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Events

- (IBAction)InAppPreferenceSwitchValueChanged:(UISwitch *)sender {
    XZLocalization.isInAppLanguagePreferencesEnabled = sender.isOn;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:(UITableViewRowAnimationNone)];
}

@end
