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

- (NSInteger)numberOfSections {
    return _dataArray.count;
}

- (NSInteger)numberOfCellsInSection:(NSInteger)section {
    return _dataArray[section].items.count;
}

- (id)modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    return _dataArray[indexPath.section].items[indexPath.item];
}

- (NSInteger)numberOfSupplementsOfKind:(XZMocoaKind)kind inSection:(NSInteger)section {
    return kind == XZMocoaKindHeader ? 1 : 0;
}

- (id)modelForSupplementOfKind:(XZMocoaKind)kind atIndexPath:(NSIndexPath *)indexPath {
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
