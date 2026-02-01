//
//  Example0320Group100SectionModel.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example0320Group100SectionModel.h"
#import "Example0320Group100CellModel.h"

@implementation Example0320Group100SectionModel

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/20/table/100/").modelClass = self;
}

+ (NSDictionary<NSString *,id> *)mappingJSONCodingClasses {
    return @{
        @"items": [Example0320Group100CellModel class]
    };
}

- (XZMocoaName)mocoaName {
    return @"100";
}

- (NSInteger)numberOfCellModels {
    return self.items.count;
}

- (id)modelForCellAtIndex:(NSInteger)index {
    return [self.items objectAtIndex:index];
}

- (BOOL)isEqual:(Example0320Group100SectionModel *)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[Example0320Group100SectionModel class]]) return NO;
    return [self.gid isEqual:object.gid];
}

@end
