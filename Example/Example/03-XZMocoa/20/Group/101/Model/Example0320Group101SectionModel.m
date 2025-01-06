//
//  Example0320Group101SectionModel.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example0320Group101SectionModel.h"
#import "Example0320Group101CellModel.h"

@implementation Example0320Group101SectionModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/20/table/101/").modelClass = self;
}

- (BOOL)isEqual:(Example0320Group101SectionModel *)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[Example0320Group101SectionModel class]]) return NO;
    return [self.gid isEqual:object.gid];
}

+ (NSDictionary<NSString *,id> *)mappingJSONCodingClasses {
    return @{
        @"items": [Example0320Group101CellModel class]
    };
}

- (XZMocoaName)mocoaName {
    return @"101";
}

- (NSInteger)numberOfCellModels {
    return self.items.count;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return [self.items objectAtIndex:index];
}

@end
