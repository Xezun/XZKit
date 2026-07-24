//
//  XZMocoaTableCellViewModel.m
//  
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaTableCellViewModel.h"
#import "XZMocoaTableView.h"

@implementation XZMocoaTableCellViewModel

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    if (self.frame.size.height == height) {
        return;
    }
    frame.size.height = height;
    self.frame = frame;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, identifier = %@; height = %g>", self.class, self, self.identifier, self.height];
}

- (void)tableViewCell:(UITableViewCell *)cell wasSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableViewCell:(UITableViewCell *)cell wasDeselectedAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableViewCell:(UITableViewCell *)cell willBeDisplayedAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableViewCell:(UITableViewCell *)cell wasEndedDisplayingAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableViewCell:(UITableViewCell *)cell wasEndedEditingAtIndexPath:(NSIndexPath *)indexPath withEventsName:(XZMocoaEventsName)name completion:(void (^)(BOOL))completion {
    [self sendEventsWithName:name value:[NSArray arrayWithObjects:indexPath, completion, nil]];
}

@end
