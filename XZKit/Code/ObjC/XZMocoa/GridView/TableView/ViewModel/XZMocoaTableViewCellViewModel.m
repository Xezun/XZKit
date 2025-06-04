//
//  XZMocoaTableViewCellViewModel.m
//  
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaTableViewCellViewModel.h"
#import "XZMocoaTableView.h"

@implementation XZMocoaTableViewCellViewModel

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

- (void)tableView:(id<XZMocoaTableView>)tableView didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(id<XZMocoaTableView>)tableView didDeselectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(id<XZMocoaTableView>)tableView willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(id<XZMocoaTableView>)tableView didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(id<XZMocoaTableView>)tableView didEditCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forUpdatesKey:(XZMocoaUpdatesKey)key completion:(void (^ _Nullable)(BOOL))completion {
    [self emitUpdatesForKey:key value:[NSArray arrayWithObjects:indexPath, completion, nil]];
}

@end
