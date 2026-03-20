//
//  Example17Configuration.m
//  Example
//
//  Created by 徐臻 on 2026/3/20.
//

#import "Example17Configuration.h"

@implementation Example17Configuration
- (instancetype)init {
    self = [super init];
    if (self) {
        _isHidden = NO;
        _isTranslucent = YES;
        _prefersLargeTitles = NO;
    }
    return self;
}
@end
