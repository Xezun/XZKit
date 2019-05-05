//
//  SQLiteExtension.h
//  SQLiteDB
//
//  Created by mlibai on 15/8/20.
//  Copyright (c) 2015年 mlibai. All rights reserved.
//
/**
 *  SQLiteConnection 类、 SQLiteField 类 的私有属性和方法头文件
 *  因为这些私有属性不能公开，而 SQLiteRecordset 需要使用这些私有属性
 *  所以写在头文件让其引用
 */


#ifndef SQLiteDB_SQLiteExtension_h
#define SQLiteDB_SQLiteExtension_h

#import "SQLiteField.h"

#pragma mark 延展
@interface SQLiteField ()

/**
 *  索引
 */
@property (nonatomic, assign) unsigned int index;

/**
 *  字段名
 */
@property (nonatomic, copy) NSString *name;

/**
 *  字段原始名
 */
@property (nonatomic, copy) NSString *originName;

/**
 *  当前值，可以被更改
 */
//@property (nonatomic, strong) id value;

/**
 *  原始值
 */
@property (nonatomic, strong) id originValue;

/**
 *  字节数，仅对 NSString NSData 类型有效
 */
@property (nonatomic, assign) NSUInteger bytes;

/**
 *  声明的数据类型
 */
@property (nonatomic, assign) SQLiteDataType dataType;

/**
 *  存储类型
 */
@property (nonatomic, assign) NSInteger storageType;

/**
 *  所声明的字段值范围或精度
 */
@property (nonatomic, assign) SQLiteDataSize dataSize;

/**
 *  是否是主键
 */
@property (nonatomic, assign) BOOL isPrimaryKey;

/**
 *  是否允许 NULL 值
 */
@property (nonatomic, assign) BOOL isNotNull;

/**
 *  是否自增
 */
@property (nonatomic, assign) BOOL isAutoIncrement;

/**
 *  是否唯一
 */
@property (nonatomic, assign) BOOL isUnique;

/**
 *  字段默认值
 */
@property (nonatomic, copy) NSString *defaultValue;

/**
 *  字段所属表名
 */
@property (nonatomic, copy) NSString *table;

/**
 *  字段所属数据库名（不是数据库文件名）
 */
@property (nonatomic, copy) NSString *database;

@end

typedef struct sqlite3 sqlite3;

#import "SQLiteConnection.h"


#pragma mark SQLiteConnection 延展
@interface SQLiteConnection ()

/**
 *  数据库指针
 */
@property (nonatomic, assign, readonly) sqlite3 *conn;

/**
 *  调用 open 方法的次数 - 调用 close 方法的次数
 */
@property (nonatomic, assign) NSUInteger connectedCount;

@end

#endif
