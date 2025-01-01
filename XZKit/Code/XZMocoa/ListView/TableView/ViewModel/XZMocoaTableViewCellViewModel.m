//
//  XZMocoaTableViewCellViewModel.m
//  
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaTableViewCellViewModel.h"

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView willDisplayRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView didEndDisplayingRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, identifier = %@; height = %g>", self.class, self, self.identifier, self.height];
}


@end
