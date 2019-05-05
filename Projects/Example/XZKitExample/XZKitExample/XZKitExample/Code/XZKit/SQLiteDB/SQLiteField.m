//
//  SQLiteField.m
//  SQLiteDB
//
//  Created by mlibai on 15/8/17.
//  Copyright (c) 2015年 mlibai. All rights reserved.
//

#import "SQLiteData.h"
#import "SQLiteField.h"

#import "SQLiteExtension.h"

#pragma mark 实现
@implementation SQLiteField

/**
 *  指定初始化方法
 */
- (instancetype)initWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize isAutoIncrement:(BOOL)isAutoIncrement isPrimaryKey:(BOOL)isPrimaryKey isUnique:(BOOL)isUnique isNotNull:(BOOL)isNotNull defaultValue:(NSString *)defaultValue {
    if (self = [super init]) {
        _name = name;
        _dataType = dataType;
        _dataSize = dataSize;
        _isAutoIncrement = isAutoIncrement;
        _isPrimaryKey = isPrimaryKey;
        _isUnique = isUnique;
        _isNotNull = isNotNull;
        _defaultValue = defaultValue;
    }
    return self;
}

/**
 *  主键
 */
+ (instancetype)fieldWithName:(NSString *)name isAutoIncrement:(BOOL)isAutoIncrement {
    return [[self alloc] initWithName:name dataType:SQLiteInteger dataSize:SQLiteDataSizeNone isAutoIncrement:isAutoIncrement isPrimaryKey:YES isUnique:NO isNotNull:NO defaultValue:nil];
}
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType isPrimaryKey:(BOOL)isPrimaryKey {
    return [[self alloc] initWithName:name dataType:dataType dataSize:SQLiteDataSizeNone isAutoIncrement:NO isPrimaryKey:isPrimaryKey isUnique:NO isNotNull:NO defaultValue:nil];
}
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize isPrimaryKey:(BOOL)isPrimaryKey {
    return [[self alloc] initWithName:name dataType:dataType dataSize:dataSize isAutoIncrement:NO isPrimaryKey:isPrimaryKey isUnique:NO isNotNull:NO defaultValue:nil];
}

/**
 *  字段
 */
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType {
    return [[self alloc] initWithName:name dataType:dataType dataSize:SQLiteDataSizeNone isAutoIncrement:NO isPrimaryKey:NO isUnique:NO isNotNull:NO defaultValue:nil];
}
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize {
    return [[self alloc] initWithName:name dataType:dataType dataSize:dataSize isAutoIncrement:NO isPrimaryKey:NO isUnique:NO isNotNull:NO defaultValue:nil];
}
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType defaultValue:(NSString *)defaultValue {
    return [[self alloc] initWithName:name dataType:dataType dataSize:SQLiteDataSizeNone isAutoIncrement:NO isPrimaryKey:NO isUnique:NO isNotNull:NO defaultValue:defaultValue];
}
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize defaultValue:(NSString *)defaultValue {
    return [[self alloc] initWithName:name dataType:dataType dataSize:dataSize isAutoIncrement:NO isPrimaryKey:NO isUnique:NO isNotNull:NO defaultValue:defaultValue];
}

/**
 *  唯一，不能设置默认值
 */
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType isUnique:(BOOL)isUnique {
    return [[self alloc] initWithName:name dataType:dataType dataSize:SQLiteDataSizeNone isAutoIncrement:NO isPrimaryKey:NO isUnique:isUnique isNotNull:NO defaultValue:nil];
}
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize isUnique:(BOOL)isUnique {
    return [[self alloc] initWithName:name dataType:dataType dataSize:dataSize isAutoIncrement:NO isPrimaryKey:NO isUnique:isUnique isNotNull:NO defaultValue:nil];
}

/**
 *  非空，需要设置默认值
 */
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType isNotNull:(BOOL)isNotNull defaultValue:(NSString *)defaultValue {
    return [[self alloc] initWithName:name dataType:dataType dataSize:SQLiteDataSizeNone isAutoIncrement:NO isPrimaryKey:NO isUnique:NO isNotNull:isNotNull defaultValue:defaultValue];
}
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize isNotNull:(BOOL)isNotNull defaultValue:(NSString *)defaultValue {
    return [[self alloc] initWithName:name dataType:dataType dataSize:dataSize isAutoIncrement:NO isPrimaryKey:NO isUnique:NO isNotNull:isNotNull defaultValue:defaultValue];
}

/**
 *  非空且唯一
 */
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType isUnique:(BOOL)isUnique isNotNull:(BOOL)isNotNull {
    return [[self alloc] initWithName:name dataType:dataType dataSize:SQLiteDataSizeNone isAutoIncrement:NO isPrimaryKey:NO isUnique:YES isNotNull:YES defaultValue:nil];
}
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize isUnique:(BOOL)isUnique isNotNull:(BOOL)isNotNull {
    return [[self alloc] initWithName:name dataType:dataType dataSize:dataSize isAutoIncrement:NO isPrimaryKey:NO isUnique:isUnique isNotNull:isNotNull defaultValue:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name:%@, dataType:%@", self.name, [SQLiteData sqliteDataTypeNameForDataType:self.dataType withDataSize:self.dataSize]];
}

// copy 指定的初始化方法
- (instancetype)initWithName:(NSString *)name originName:(NSString *)originName index:(unsigned int)index dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize table:(NSString *)table database:(NSString *)database {
    if (self = [super init]) {
        _name = name;
        _originName = originName;
        _index = index;
        _dataType = dataType;
        _dataSize = dataSize;
        _table = table;
        _database = database;
    }
    return self;
}

// copy
- (id)copyWithZone:(NSZone *)zone {
    return [[SQLiteField alloc] initWithName:self.name originName:self.originName index:self.index dataType:self.dataType dataSize:self.dataSize table:self.table database:self.table];
}

@end
