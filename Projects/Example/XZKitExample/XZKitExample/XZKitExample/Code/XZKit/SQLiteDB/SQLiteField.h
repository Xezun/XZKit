//
//  SQLiteField.h
//  SQLiteDB
//
//  Created by mlibai on 15/8/17.
//  Copyright (c) 2015年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum SQLiteDataType SQLiteDataType;
typedef struct SQLiteDataSize SQLiteDataSize;

@interface SQLiteField : NSObject <NSCopying>

/**
 *  索引
 */
@property (nonatomic, readonly, assign) unsigned int index;

/**
 *  字段名
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 *  字段原始名
 */
@property (nonatomic, readonly, copy) NSString *originName;

/**
 *  当前值
 */
@property (nonatomic, strong) id value;

/**
 *  原始值
 */
@property (nonatomic, readonly, strong) id originValue;

/**
 *  字节数，仅对 NSString NSData 类型有效
 */
@property (nonatomic, readonly, assign) NSUInteger bytes;

/**
 *  声明的数据类型
 */
@property (nonatomic, readonly, assign) SQLiteDataType dataType;

/**
 *  存储类型
 */
@property (nonatomic, readonly, assign) NSInteger storageType;

/**
 *  所声明的字段值范围或精度
 */
@property (nonatomic, readonly, assign) SQLiteDataSize dataSize;

/**
 *  是否是主键
 */
@property (nonatomic, readonly, assign) BOOL isPrimaryKey;

/**
 *  是否允许 NULL 值
 */
@property (nonatomic, readonly, assign) BOOL isNotNull;

/**
 *  是否自增
 */
@property (nonatomic, readonly, assign) BOOL isAutoIncrement;

/**
 *  是否唯一
 */
@property (nonatomic, readonly, assign) BOOL isUnique;

/**
 *  字段默认值
 */
@property (nonatomic, readonly, copy) NSString *defaultValue;

/**
 *  字段所属表名
 */
@property (nonatomic, readonly, copy) NSString *table;

/**
 *  字段所属数据库名（不是数据库文件名）
 */
@property (nonatomic, readonly, copy) NSString *database;


/**
 *  以下是创建数据库字段的一些方法。对于 SQLite 数据库，有以下需要注意的问题：
 *
 *  1，自增类型的只能是 integer primary key autoincrement，所以设置了自增主键，就不能设置其它主键了
 *  2，其它类型的主键，在添加新数据时必须设置数据
 *  3，唯一且非空字段，在其它数据库会自动设置位主键
 *  4，不为空字段需要设置默认值
 */

/**
 *  主键
 */
+ (instancetype)fieldWithName:(NSString *)name isAutoIncrement:(BOOL)isAutoIncrement;
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType isPrimaryKey:(BOOL)isPrimaryKey;
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize isPrimaryKey:(BOOL)isPrimaryKey;

/**
 *  字段
 */
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType;
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize;
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType defaultValue:(NSString *)defaultValue;
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize defaultValue:(NSString *)defaultValue;

/**
 *  唯一，不能设置默认值
 */
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType isUnique:(BOOL)isUnique;
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize isUnique:(BOOL)isUnique;

/**
 *  非空，需要设置默认值
 */
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType isNotNull:(BOOL)isNotNull defaultValue:(NSString *)defaultValue;
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize isNotNull:(BOOL)isNotNull defaultValue:(NSString *)defaultValue;

/**
 *  非空且唯一
 */
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType isUnique:(BOOL)isUnique isNotNull:(BOOL)isNotNull;
+ (instancetype)fieldWithName:(NSString *)name dataType:(SQLiteDataType)dataType dataSize:(SQLiteDataSize)dataSize isUnique:(BOOL)isUnique isNotNull:(BOOL)isNotNull;

@end
