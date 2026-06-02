//
//  ExampleMainHomeSectionModel.m
//  Example
//
//  Created by Xezun on 2026/2/2.
//

#import "ExampleMainHomeSectionModel.h"
#import "ExampleMainHomeCellModel.h"

@implementation ExampleMainHomeSectionModel

+ (NSDictionary<NSString *,id> *)mappingJSONCodingClasses {
    return @{
        @"items": [ExampleMainHomeCellModel class]
    };
}

- (id)headerModel {
    return self.name;
}

- (NSInteger)numberOfCellModels {
    return self.items.count;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return self.items[index];
}

@end
