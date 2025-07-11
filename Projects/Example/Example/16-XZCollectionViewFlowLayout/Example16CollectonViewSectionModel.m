//
//  Example16CollectonViewSectionModel.m
//  Example
//
//  Created by Xezun on 2024/6/1.
//

#import "Example16CollectonViewSectionModel.h"

@implementation Example16CollectonViewSectionModel

- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    self = [super init];
    if (self) {
        if (scrollDirection == UICollectionViewScrollDirectionVertical) {
            _headerSize = CGSizeMake(320, 44);
            _footerSize = CGSizeMake(320, 44);
        } else {
            _headerSize = CGSizeMake(44, 320);
            _footerSize = CGSizeMake(44, 320);
        }
        
        _lineSpacing      = arc4random_uniform(8) + 2;
        _interitemSpacing = arc4random_uniform(8) + 2;
        
        _edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _lineAlignmentStyle = ExampleSectionModelLineAlignmentStyleJustified;
        _interitemAlignment = XZCollectionViewInteritemAlignmentMedian;
        
        NSInteger count = 10 + arc4random_uniform(20);
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger item = 0; item < count; item++) {
            Example16CollectonViewCellModel *cell = [[Example16CollectonViewCellModel alloc] initWithScrollDirection:scrollDirection];
            [items addObject:cell];
        }
        _cells = items.copy;
    }
    return self;
}

- (XZCollectionViewLineAlignment)lineAlignmentForItemsInLine:(NSInteger)line {
    switch (_lineAlignmentStyle) {
        case ExampleSectionModelLineAlignmentStyleLeading:
            return XZCollectionViewLineAlignmentLeading;
        
        case ExampleSectionModelLineAlignmentStyleCenter:
            return XZCollectionViewLineAlignmentCenter;
            
        case ExampleSectionModelLineAlignmentStyleTraling:
            return XZCollectionViewLineAlignmentTrailing;
            
        case ExampleSectionModelLineAlignmentStyleJustified:
            return XZCollectionViewLineAlignmentJustified;
          
        case ExampleSectionModelLineAlignmentStyleJustifiedLeading:
            return XZCollectionViewLineAlignmentJustifiedLeading;
            
        case ExampleSectionModelLineAlignmentStyleJustifiedCenter:
            return XZCollectionViewLineAlignmentJustifiedCenter;
            
        case ExampleSectionModelLineAlignmentStyleJustifiedTrailing:
            return XZCollectionViewLineAlignmentJustifiedTrailing;
            
        case ExampleSectionModelLineAlignmentStyle6:
            switch (line % 6) {
                case 0:
                    return XZCollectionViewLineAlignmentLeading;
                case 1:
                    return XZCollectionViewLineAlignmentCenter;
                case 2:
                    return XZCollectionViewLineAlignmentTrailing;
                default:
                    return XZCollectionViewLineAlignmentJustifiedTrailing;
            }
            break;
    }
    
}

@end
