//
//  Example21BasicViewController.m
//  Example
//
//  Created by Xezun on 2026/2/2.
//

#import "Example21BasicViewController.h"
#import "Example05TextViewController.h"
@import XZKit;

@interface Example21BasicViewController () {
    NSArray<XZObjcType *> *_basicTypes;
}

@end

@implementation Example21BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *_basicTypes = [NSMutableArray array];
    for (int i = 0; i < CHAR_MAX; i++) {
        @try {
            XZObjcType *type = [XZObjcType typeForType:(XZStdcType)i];
            [_basicTypes addObject:type];
        } @catch (NSException *exception) {
            NSLog(@"<%c> is not a type", i);
        } @finally {
            
        }
    }
    self->_basicTypes = _basicTypes;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _basicTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    XZObjcType *type = _basicTypes[indexPath.row];
    cell.textLabel.text = type.name;
    cell.detailTextLabel.text = type.encoding;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![segue.identifier isEqualToString:@"showText"]) {
        return;
    }
    Example05TextViewController * const nextVC = segue.destinationViewController;
    if ([sender isKindOfClass:UITableViewCell.class]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            nextVC.text = _basicTypes[indexPath.row].description;
        }
    }
}
@end
