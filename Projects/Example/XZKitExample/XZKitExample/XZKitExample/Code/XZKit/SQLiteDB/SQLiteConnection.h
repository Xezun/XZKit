//
//  SQLiteConnection.h
//  SQLiteDB
//
//  Created by mlibai on 15/8/15.
//  Copyright (c) 2015年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SQLiteField;

@interface SQLiteConnection : NSObject

/**
 *  数据库连接的打开状态
 */
@property (nonatomic, assign, readonly) BOOL status;

/**
 *  数据库文件路径
 */
@property (nonatomic, strong) NSString *source;

/**
 * 构造器
 */
+ (instancetype)connectionWithSource:(NSString *)source;

/**
 *  指定初始化方法
 */
- (instancetype)initWithSource:(NSString *)source;

/**
 *  打开数据库连接，打开数据库后，在使用完成后，一定要关闭。
 *
 *  @return YES 表示打开成功，NO 表示打开失败
 */
- (BOOL)open;

/**
 *  关闭数据库连接
 *
 *  @return YES 表示关闭成功，NO 表示关闭失败
 */
- (BOOL)close;

/**
 *  执行SQL语句
 *
 *  @param sqlString SQL语句
 *
 *  @return 返回值（数组）最多包含两个元素：
 *  第一个元素：表示语句执行状态。@(0)，表示执行成功，其它值，执行失败。
 *  第二个元素：当发生错误时，这个元素是错误信息；执行成功时，对于 Select 语句，如果查询结果不为空的话，该值是所有记录组成的数组，每条记录（每行）是一个字典。
 */
- (NSArray *)executeSqlWithString:(NSString *)sqlString;

/**
 *  执行SQL语句，与上一个方法一样，只是提供了一个构造SQL语句的方法。
 */
- (NSArray *)executeSqlWithFormat:(NSString *)formate, ... NS_FORMAT_FUNCTION(1, 2);

/**
 *  创建表，如果表已存在的话，直接返回 YES 。
 */
- (BOOL)createTable:(NSString *)table fields:(SQLiteField *)field, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  删除表，如果表不存在的话，直接返回 YES 。
 */
- (BOOL)dropTable:(NSString *)table;

/**
 *  清空表，如果表不存在，返回 NO 。
 */
- (BOOL)emptyTable:(NSString *)table;

/**
 *  针对当前连接，最后插入的rowid。仅对有 整型 主键的表有效，否则返回 0 。
 */
- (NSInteger)lastInsertRowid;

@end