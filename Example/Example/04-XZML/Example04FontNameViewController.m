//
//  Example04FontNameViewController.m
//  Example
//
//  Created by 徐臻 on 2024/10/17.
//

#import "Example04FontNameViewController.h"
#import "Example04FontSizeViewController.h"

@interface Example04FontNameViewController () {
    NSMutableArray<NSString *> *_familyNames;
    NSMutableArray<NSMutableArray<NSString *> *> *_fontNames;
}

@end

@implementation Example04FontNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _familyNames = [NSMutableArray array];
    _fontNames = [NSMutableArray array];
    
    for (NSString *familyName in UIFont.familyNames) {
        [_familyNames addObject:familyName];
        NSMutableArray *fontNames = [NSMutableArray array];
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            [fontNames addObject:fontName];
        }
        [_fontNames addObject:fontNames];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _familyNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fontNames[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *fontName = _fontNames[indexPath.section][indexPath.row];
    cell.textLabel.text = fontName;
    cell.detailTextLabel.font = [UIFont fontWithName:fontName size:17.0];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _familyNames[section];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:UITableViewCell.class]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Example04FontSizeViewController *nextVC = segue.destinationViewController;
        nextVC.fontName = _fontNames[indexPath.section][indexPath.row];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
