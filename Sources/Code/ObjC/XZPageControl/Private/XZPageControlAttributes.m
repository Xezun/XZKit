//
//  XZPageControlAttributes.m
//  XZPageControl
//
//  Created by Xezun on 2024/6/10.
//

#import "XZPageControlAttributes.h"

@implementation XZPageControlAttributes

@synthesize strokeColor = _strokeColor;
@synthesize currentStrokeColor = _currentStrokeColor;

@synthesize fillColor = _fillColor;
@synthesize currentFillColor = _currentFillColor;

@synthesize shape = _shape;
@synthesize currentShape = _currentShape;

@synthesize image = _image;
@synthesize currentImage = _currentImage;

- (BOOL)isCurrent {
    @throw [NSException exceptionWithName:NSGenericException reason:@"方法未实现" userInfo:nil];
}

- (void)setCurrent:(BOOL)isCurrent animated:(BOOL)animated {
    @throw [NSException exceptionWithName:NSGenericException reason:@"方法未实现" userInfo:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    XZPageControlAttributes *attributes = [[self.class alloc] init];
    attributes->_strokeColor = _strokeColor;
    attributes->_currentStrokeColor = _currentStrokeColor;
    
    attributes->_fillColor = _fillColor;
    attributes->_currentFillColor = _currentFillColor;
    
    attributes->_shape = _shape;
    attributes->_currentShape = _currentShape;
    
    attributes->_image = _image;
    attributes->_currentImage = _currentImage;
    return attributes;
}

@end

