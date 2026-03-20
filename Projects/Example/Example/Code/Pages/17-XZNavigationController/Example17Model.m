//
//  Example17Model.m
//  Example
//
//  Created by 徐臻 on 2026/3/20.
//

#import "Example17Model.h"
#import "Example17Configuration.h"

@implementation Example17Model

- (instancetype)init {
    return [self initWithConfiguration:[Example17Configuration new]];
}

- (instancetype)initWithConfiguration:(Example17Configuration *)configuration {
    self = [super init];
    if (self) {
        _current = configuration;
        _next = [[Example17Configuration alloc] init];
    }
    return self;
}

@end
