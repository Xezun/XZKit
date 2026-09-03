//
//  ExampleMainHomeModel.m
//  Example
//
//  Created by Xezun on 2026/2/2.
//

#import "ExampleMainHomeModel.h"
#import "ExampleMainHomeCellModel.h"

@interface ExampleMainHomeSectionModel : NSObject <XZJSONCoding>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *items;
@end

@implementation ExampleMainHomeModel {
    NSArray<ExampleMainHomeSectionModel *> *_dataArray;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL *url = [NSBundle.mainBundle URLForResource:@"ExampleMainHome" withExtension:@"json"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        _dataArray = [XZJSON decode:data options:kNilOptions class:[ExampleMainHomeSectionModel class]];
    }
    return self;
}

- (NSInteger)numberOfSectionsInMocoa:(void *)context {
    return _dataArray.count;
}

- (NSInteger)mocoa:(void *)context numberOfCellsInSection:(NSInteger)section {
    return _dataArray[section].items.count;
}

- (id)mocoa:(void *)context modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    return _dataArray[indexPath.section].items[indexPath.item];
}

- (NSInteger)mocoa:(void *)context kind:(XZMocoaKind)kind numberOfSupplementsInSection:(NSInteger)section {
    return kind == XZMocoaKindHeader ? 1 : 0;
}

- (id)mocoa:(void *)context kind:(XZMocoaKind)kind modelForSupplementAtIndexPath:(NSIndexPath *)indexPath {
    return kind == XZMocoaKindHeader ? _dataArray[indexPath.section].name : nil;
}

@end

@implementation ExampleMainHomeSectionModel

+ (NSDictionary<NSString *,id> *)mappingJSONCodingClasses {
    return @{
        @"items": [ExampleMainHomeCellModel class]
    };
}

@end
