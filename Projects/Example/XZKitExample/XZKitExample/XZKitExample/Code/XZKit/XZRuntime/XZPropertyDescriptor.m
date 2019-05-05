//
//  XZPropertyDescriptor.m
//  XZKit
//
//  Created by mlibai on 2016/11/30.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZPropertyDescriptor.h"
#import "XZDataTypeDescriptor.h"

@implementation XZPropertyDescriptor

+ (instancetype)descriptorWithProperty:(objc_property_t)property_t {
    return [[self alloc] initWithProperty:property_t];
}

- (instancetype)initWithProperty:(objc_property_t)property_t {
    self = [super init];
    if (self) {
        unsigned int attribute_count = 0;
        objc_property_attribute_t *attribute_list = property_copyAttributeList(property_t, &attribute_count);
        const char * const property_name = property_getName(property_t);
        _name = [NSString stringWithUTF8String:property_name];
        for (unsigned int j = 0; j < attribute_count; j++) {
            objc_property_attribute_t attribute = attribute_list[j];
            switch (attribute.name[0]) {
                case 'T': // type
                    _dataTypeDescriptor = [[XZDataTypeDescriptor alloc] initWithTypeEncoding:attribute.value];
                    break;
                    
                case 'R': // readonly
                    _isReadonly = (attribute.value != NULL);
                    break;
                    
                case 'C': // copy
                    _isCopy = (attribute.value != NULL);
                    break;
                    
                case '&': // retain
                    _isRetain = (attribute.value != NULL);
                    break;
                    
                case 'N': // nonatomic
                    _isNonatomic = (attribute.value != NULL);
                    break;
                    
                case 'G':  // getter
                    _getter = sel_getUid(attribute.value);
                    break;
                    
                case 'S':  // setter
                    _setter = sel_getUid(attribute.value);
                    break;
                    
                case 'D': // dynamic
                    _isDynamic = (attribute.value != NULL);
                    break;
                    
                case 'W': // weak
                    _isWeak = (attribute.value != NULL);
                    break;
                    
                case 'V': // variable
                    _variableName = [NSString stringWithUTF8String:attribute.value];
                    break;
                    
                default:
                    break;
            }
        }
        
        if (_getter == NULL) {
            _getter = sel_getUid(property_name);
        }
        
        if (_setter == NULL) {
            size_t len = strlen(property_name) + 3 + 1; // set + :
            char *tmp_setter = calloc(len + 1, sizeof(char));
            strcpy(tmp_setter, "set");
            strcat(tmp_setter, property_name);
            tmp_setter[3] = toupper(tmp_setter[3]);
            tmp_setter[len - 1] = ':';
            _setter = sel_getUid(tmp_setter);
            free((void *)tmp_setter);
        }
        
        free(attribute_list);
    }
    return self;
}

- (NSString *)description {
    NSString *dataType = self.dataTypeDescriptor.description;
    dataType = [dataType stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"];
    return [NSString stringWithFormat:@"<%@: %p> {\n\tname: %@, \n\tvariableName: %@, \n\tdataType: \n%@, \n\tisReadonly: %d, \n\tisCopy: %d, \n\tisRetain: %d, \n\tisNonatomic: %d, \n\tisDynamic: %d, \n\tisWeak: %d, \n\tgetter: %s, \n\tsetter: %s\n}", NSStringFromClass([self class]), self, self.name, self.variableName, dataType, self.isReadonly, self.isCopy, self.isRetain, self.isNonatomic, self.isDynamic, self.isWeak, sel_getName(self.getter), sel_getName(self.setter)];
}

@end

static const void * const _property_descriptor_list_key = &_property_descriptor_list_key;

@implementation NSObject (XZPropertyDescriptor)

+ (NSArray<XZPropertyDescriptor *> *)xz_propertyDescriptors {
    Class const aClass = [self class];
    NSMutableArray *descriptorList = objc_getAssociatedObject(aClass, _property_descriptor_list_key);
    if (descriptorList != nil) {
        return descriptorList;
    }
    
    descriptorList = [[NSMutableArray alloc] init];
    xz_class_property_enumerator(aClass, ^(objc_property_t  _Nonnull property_t, NSInteger index, BOOL * _Nonnull stop) {
        [descriptorList addObject:[XZPropertyDescriptor descriptorWithProperty:property_t]];
    });
    objc_setAssociatedObject(aClass, _property_descriptor_list_key, descriptorList.copy, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return descriptorList;
}

@end

