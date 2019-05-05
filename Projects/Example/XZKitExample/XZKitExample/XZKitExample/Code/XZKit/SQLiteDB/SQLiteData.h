//
//  SQLiteData.h
//  SQLiteData
//
//  Created by mlibai on 15/8/7.
//  Copyright (c) 2015年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SQLiteDB_SQL_Result_Description_Print
/**
 *  宏：定义该宏打会输出每一个执行的 SQL 语句和 操作状态 描述
 */


/**
 * 数据类型：SQLite数据库实际储存并不存在数据类型。即使字段指定了数据类型
 * 依然可以向其中插入任何类型的数据，而且数据类型的名称也是可以随意设置的，
 * 所以字段数据的大小或精度设置更没有意义了。虽然如此，为了方便维护和管理，
 * 规范的设置数据有很重要的意义。以下枚举值列出了一般数据库都普遍支持的数
 * 据类型，本类库将按照以下数据类型来处理读取或写入的数据。
 */
typedef enum SQLiteDataType {
    // 空
    SQLiteNull = 0,    // NULL
    // 整数
    SQLiteInteger, // 整形 最大 8 字节
    SQLiteBigInt,
    SQLiteUnsignedBigInt,
    SQLiteInt8,
    SQLiteNumeric,
    SQLiteDecimal,          // 十进制，范围(10,5)，即有效位最大10位，小数最多5位
    SQLiteInt2,
    SQLiteInt,
    SQLiteTinyInt,
    SQLiteSmallint,
    SQLiteMediumint,
    SQLiteBoolean,          // 布尔
    // 浮点数
    SQLiteFloat,
    SQLiteDouble,
    SQLiteReal,
    SQLiteDoublePrecision,
    // 字符
    SQLiteVarChar,                    // 字符，255
    SQLiteDate,                       // 日期，YYYY-mm-DD
    SQLiteDateTime,                   // 日期时间，YYYY-mm-DD HH:MM:SS
    SQLiteText,                       // 文本
    SQLiteCharacter,          // 22
    SQLiteVaryingCharacter,   // 255
    SQLiteNChar,              // 55
    SQLiteNativeCharacter,    // 70
    SQLiteNVarChar,           // 100
    SQLiteClob,               // 超大数据
    // 二进制
    SQLiteBlob,               // 二进制
    SQLiteBinary = SQLiteBlob,
    SQLiteNoDatatypeSpecified,
    // 变体，任意类型，未指定类型
    SQLiteVariant,
    // 不支持的类型
    SQLiteNotSupported
}SQLiteDataType;


/**
 *  部分带取值范围的数据类型
 */
typedef struct SQLiteDataSize {
    NSUInteger m;               // 一般表示范围
    NSUInteger n;               // 一般表示精度
}SQLiteDataSize;

/**
 *  内联函数，构造一个数据类型的数据范围
 *
 *  @param m 数据的宽度
 *  @param n 数据的精
 *
 *  @return 表示数据大小的结构体
 */
static inline SQLiteDataSize SQLiteDataSizeMake(NSInteger m, NSInteger n) {
    SQLiteDataSize size; size.m = m; size.n = n; return size;
}

/**
 *  字段数值类型没有size设置的常量
 */
extern const SQLiteDataSize SQLiteDataSizeNone;

/**
 *  数据类型的描述
 */
typedef struct SQLiteDataTypeDescription {
    SQLiteDataType  type;
    char            typeName[18];       // 类型名
    int             storageType;        // 存储方式
    SQLiteDataSize  size;               // 数值范围
}SQLiteDataTypeDescription;

/**
 *  不支持的数据类
 */
extern const SQLiteDataTypeDescription SQLiteNotSupportedDataType;





/*****************************************************
 *  SQLiteDB 类，与数据库数据类型相关的类
 *  正在考虑是否可以通过自动添加维护表，来优化数据库查询
 */
@interface SQLiteData : NSObject

/**
 *  获取用户或程序文档文件夹根路径、缓存文件夹根路径的一些常用方法
 */
+ (NSString *)documentDirectoryRootPath;
+ (NSString *)cachesDirectoryRootPath;

/**
 *  数据库支持的数据类型，返回的是一个c结构体数组，数组长度是 SQLiteNotSupported
 */
+ (const SQLiteDataTypeDescription *)allSupportedDataTypeDescriptions;

/**
 *  返回数据类型描述
 */
+ (SQLiteDataTypeDescription)sqliteDataTypeDescriptionForDataTypeCName:(const char *)dataTypeCName;
+ (SQLiteDataTypeDescription)sqliteDataTypeDescriptionForDataTypeName:(NSString *)dataTypeName;
+ (SQLiteDataTypeDescription)sqliteDataTypeDescriptionForDataType:(SQLiteDataType)dataType;

/**
 *  根据字符串返回数据类型对应的值
 *
 *  @param dataTypeName 一个数据类型的字符串，如integer、 text
 *
 *  @return 数据类型值
 */
+ (SQLiteDataType)sqliteDataTypeForDataTypeName:(NSString *)dataTypeName;

/**
 *  返回数据类型值对应的字符串
 *
 *  @param dataType 数据类型枚举值
 *  @param dataSize 数据类型的大小
 *
 *  @return 数据类型字符串
 */
+ (NSString *)sqliteDataTypeNameForDataType:(SQLiteDataType)dataType withDataSize:(SQLiteDataSize)dataSize;

/**
 *  数据的存储类型
 *
 *  @param dataType 数据类型枚举值
 *
 *  @return 存储类型值，SQLITE_INTEGER=1 SQLITE_FLOAT=2 SQLITE_TEXT=3 SQLITE_BLOB=4 SQLITE_NULL=5
 */
+ (NSInteger)sqliteDataStorageTypeForDataType:(SQLiteDataType)dataType;

// 数据库操作状态描述
+ (NSString *)descriptionForResultCode:(NSUInteger)resultCode;

@end
