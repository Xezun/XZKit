//
//  Example0320Group102CellModel.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example0320Group102CellModel.h"

@implementation Example0320Group102CellModel

+ (NSDictionary<NSString *,id> *)mappingJSONCodingClasses {
    return @{
        @"items": [Example0320Group102CellModelItem class]
    };
}

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/20/table/102/").modelClass = self;
}

- (XZMocoaName)mocoaName {
    return @"102";
}

- (BOOL)isEqual:(Example0320Group102CellModel *)object {
    if (object == self) return YES;
    if (![object isKindOfClass:[Example0320Group102CellModel class]]) return NO;
    return [self.gid isEqualToString:object.gid];
}

- (NSUInteger)hash {
    return self.gid.hash;
}

- (NSString *)mocoaIdentifier {
    return self.gid;
}

@end

@implementation Example0320Group102CellModelItem

@end
