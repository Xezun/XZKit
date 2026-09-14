//
//  Example0330Model.m
//  Example
//
//  Created by Xezun on 2023/8/20.
//

#import "Example0330Model.h"

@implementation Example0330Model

@end

@implementation Example0330GroupModel

+ (instancetype)modelWithSections:(NSArray<Example0330GroupSectionModel *> *)sections {
    return [[self alloc] initWithSections:sections];
}

- (instancetype)initWithSections:(NSArray<Example0330GroupSectionModel *> *)sections {
    self = [super init];
    if (self) {
        _sections = sections.copy;
    }
    return self;
}

- (NSInteger)mocoa:(id)context numberOfSections:(id)null {
    return _sections.count;
}

- (NSInteger)mocoa:(id)context numberOfCellsInSection:(NSInteger)section {
    return _sections[section].cells.count;
}

- (id)mocoa:(id)context modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    return _sections[indexPath.section].cells[indexPath.item];
}

- (NSInteger)mocoa:(id)context kind:(XZMocoaKind)kind numberOfSupplementsInSection:(NSInteger)section {
    Example0330GroupSectionModel *model = _sections[section];
    if ([kind isEqualToString:XZMocoaKindHeader]) {
        return model.header ? 1 : 0;
    }
    if ([kind isEqualToString:XZMocoaKindFooter]) {
        return model.footer ? 1 : 0;
    }
    return 0;
}

- (id)mocoa:(id)context kind:(XZMocoaKind)kind modelForSupplementAtIndexPath:(NSIndexPath *)indexPath {
    Example0330GroupSectionModel *model = _sections[indexPath.section];
    if ([kind isEqualToString:XZMocoaKindHeader]) {
        return model.header;
    }
    if ([kind isEqualToString:XZMocoaKindFooter]) {
        return model.footer;
    }
    return nil;
}

@end

@implementation Example0330TextModel
@synthesize mocoaName = _mocoaName;

+ (NSDictionary<NSString *,id> *)mappingJSONCodingKeys {
    return @{ @"text": @[@"text", @"rawValue"] };
}

@end

@implementation Example0330GroupSectionModel

@synthesize mocoaName = _mocoaName;

+ (NSDictionary<NSString *,id> *)mappingJSONCodingKeys {
    return @{
        @"mocoaName": @"group",
        @"header": @"title",
        @"cells": @"model",
        @"footer": @"notes"
    };
}

+ (NSDictionary<NSString *,id> *)mappingJSONCodingClasses {
    return @{ @"cells": [Example0330TextModel class] };
}

- (BOOL)decodeFromJSONDictionary:(NSDictionary *)dictionary {
    [XZJSON model:self decodeFromDictionary:dictionary];
    
    NSString *mocoaName = self.mocoaName;
    
    self.header.mocoaName = mocoaName;
    for (Example0330TextModel * const cell in self.cells) {
        cell.mocoaName = mocoaName;
    }
    self.footer.mocoaName = mocoaName;
    
    return YES;
}

@end
