//
//  SQLiteRecordset.m
//  SQLiteDB
//
//  Created by mlibai on 15/8/15.
//  Copyright (c) 2015年 mlibai. All rights reserved.
//

#import <sqlite3.h>

#import "SQLiteData.h"

#import "SQLiteConnection.h"

#import "SQLiteField.h"

#import "SQLiteRecordset.h"

#import "SQLiteExtension.h"

/**
 *  记录集模式
 */
typedef enum SqliteRecordsetUpdateMode {
    SqliteRecordsetCursorReadOnly,
    SqliteRecordsetCursorModify,
    SqliteRecordsetCursorAddNew,
    SqliteRecordsetCursorDelete
}SqliteRecordsetUpdateMode;

#pragma mark SQLiteRecordset 延展
@interface SQLiteRecordset ()
{
    NSMutableString *_table;                // 当前查询的表名，只有是基本表时才会有值
    NSMutableString *_database;             // 数据库名，只有是基本表时才会有值
    NSMutableArray *_primaryKeys;           // 主键，对于基本表，这个属性会返回当前表的所有主键
    NSMutableDictionary *_keyedFields;      // 根据名字排序的
    NSMutableArray *_sqliteFields;          // 实际查询到的所有字段。如果主键不包含在当前查询内，allFields不包含主键，但是下面这个数组包含。
    NSDateFormatter *_dateFormatter;        // 格式化日期
    NSMutableSet *_sqliteFieldQueue;        // SQLiteField 重用池
    NSMutableString *_sqlForInternalUse;    // 内部使用的 sql 语句
    NSMutableString *_updateSqlMainPart;    // 用于更新的 SQL 语句的主要部分
    NSMutableString *_deleteSqlMainPart;    // 删除不需要  stmt
    NSMutableString *_insertSqlMainPart;    // 用于添加的 SQL 语句的主要部分
    sqlite3_stmt *_stmt;                    //
//    sqlite3_stmt *_stmtForUpdate;           //
//    sqlite3_stmt *_stmtForInsert;           //
    BOOL _cursorMode;                       //
    NSMutableArray *_fieldsForUpdate;       // 更新数据的 field 列队，同一个 SQL 语句共用同一个列队，关闭时清空
    NSMutableArray *_fieldsForInsert;       // 插入数据的 field 列队，每次都要重新生成
}

/**
 *  记录集指针模式
 */
@property (nonatomic, assign, readonly) SqliteRecordsetUpdateMode recordsetUpdateMode;


- (SQLiteField *)dequeueReusableField;
- (void)sendFieldToQueue:(SQLiteField *)sqliteField;
- (void)sendFieldsToQueue:(NSArray *)sqliteFields;
/**
 *  调用此方法，让记录集做好准备工作
 */
- (void)recordsetDidReady;

/**
 *  当记录集指针 moveNext 时，调用次方法填充字段 value 属性
 */
- (void)fetchValueFromCurrentRecord;

/**
 *  返回当前记录中主键组成的SQL语句
 *
 *  @return 形如：`id` = '12' AND `name` = 'Jim'。
 */
- (NSString *)filterPartOfSqlForUpdate;

// 返回用于删除记录的 SQL 语句
- (NSString *)sqlForDelete;

// 返回用于更新的 SQL 语句
- (NSString *)sqlForUpdate;

// 返回用于更新的 stmt ，对于同一个查询，这个是复用的
- (sqlite3_stmt *)stmtForUpdate;

// 返回用于插入数据的 SQL 语句的 字段 和 值 占位部分
- (NSString *)sqlFieldPartForInsert;

// 返回用于更新数据的 SQL 语句的 字段 和 值 占位部分
- (NSString *)sqlFieldPartForUpdate;

// 返回用于插入数据的 stmt
- (sqlite3_stmt *)stmtForInsert;

// 用于更新的字段，对于同一个 查询来说，这个数组是公用的。
- (void)fieldsForUpdateDidReady;

// 用于添加数据的字段，调用此方法返回的总是将 _fieldForInsert 数组清空。
- (void)fieldsForInsertDidReady;

// 将数据绑定到等待更新的伴随指针上
- (void)bindFields:(NSArray *)fields toSqliteStmt:(sqlite3_stmt *)stmt;

@end

#pragma mark SQLiteRecordset的实现
@implementation SQLiteRecordset

- (void)setConnection:(SQLiteConnection *)sqliteConnection {
    if (!_status) {
        _connection = sqliteConnection;
    }
}

- (void)setPage:(NSUInteger)page {
    if (!_status) {
        _page = page;
    }
}

@synthesize writable = _writable;

// 数据没有打开时，设置该属性会同时设置 _cursorMode 的值。
- (void)setWritable:(BOOL)writable {
    _writable = writable;
    if (!_status) {
        _cursorMode = writable;
    }
}

// 当数据打开时，返回的是实际状态。关闭时，返回的是设置的状态。
- (BOOL)writable {
    if (_status) {
        return _cursorMode;
    }
    return _writable;
}

- (void)setPageSize:(NSUInteger)pageSize {
    if (!_status) {
        _pageSize = pageSize;
    }
}

@synthesize eof = _eof;

- (BOOL)eof {
    if (_status) {
        return _eof;
    }
    return YES;
}

@synthesize bof = _bof;

- (BOOL)bof {
    if (_status) {
        return _bof;
    }
    return YES;
}

@synthesize count = _count;

- (NSUInteger)count {
    if (_status && _count == 0 && _connection.status) {
        sqlite3_stmt *stmt = NULL;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM (%@)", _sql];
        NSInteger result_code = sqlite3_prepare_v2(_connection.conn, sqlString.UTF8String, -1, &stmt, NULL);
#ifdef SQLiteDB_SQL_Result_Description_Print
        NSLog(@"{\n\tSource: SQLiteRecordset, \n\tAction: (count), \n\tSQL: %@, \n\tCode: %ld, \n\tDescription: %@\n}", sqlString, result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
        if (result_code == SQLITE_OK) {
            result_code = sqlite3_step(stmt);
            if (result_code == SQLITE_ROW) {
                _count = sqlite3_column_int(stmt, 0);
            }
            sqlite3_finalize(stmt);
        }
        stmt = NULL;
    }
    return _count;
}

/**
 *  基于 c 的 SQLiteField 数组，解决 NSArray 取出的对象默认都是 id 类型的问题。
 */
@synthesize fields = _fields;
- (SQLiteField *const __unsafe_unretained *)fields {
    if (_fields != NULL) {
        return _fields;
    }
    NSInteger count = self.allFields.count;
    __unsafe_unretained SQLiteField **tmpCField = (__unsafe_unretained SQLiteField **)calloc(count, sizeof(SQLiteField *));
    for (NSInteger i = 0; i < count; i ++) {
        SQLiteField *field = _allFields[i];
        tmpCField[i] = _keyedFields[field.name];
    }
    _fields = tmpCField;
    return _fields;
}

/**
 *  字段对象的重用机制
 */
- (NSMutableSet *)sqliteFieldQueue {
    if (_sqliteFieldQueue != nil) {
        return _sqliteFieldQueue;
    }
    _sqliteFieldQueue = [[NSMutableSet alloc] init];
    return _sqliteFieldQueue;
}

- (SQLiteField *)dequeueReusableField {
    if ([self sqliteFieldQueue].count > 0) {
        SQLiteField *sqliteField = [_sqliteFieldQueue anyObject];
        [_sqliteFieldQueue removeObject:sqliteField];
        return sqliteField;
    }
    SQLiteField *sqliteField = [[SQLiteField alloc] init];
    return sqliteField;
}

- (void)sendFieldToQueue:(SQLiteField *)sqliteField {
    [[self sqliteFieldQueue] addObject:sqliteField];
}

- (void)sendFieldsToQueue:(NSArray *)sqliteFields {
    [[self sqliteFieldQueue] addObjectsFromArray:sqliteFields];
}

/**
 *  便利构造器、初始化方法、指定初始化方法
 *
 *  @param connection 数据库连接对象，必须是打开状态，否则对象不会创建成功
 *
 *  @return SQLiteRecordset 记录集对象
 */
+ (instancetype)recordSetWithConnection:(SQLiteConnection *)connection {
    return [[SQLiteRecordset alloc] initWithConnection:connection];
}

+ (instancetype)recordSetWithConnection:(SQLiteConnection *)connection pageSize:(NSUInteger)pageSize page:(NSUInteger)page {
    return [[SQLiteRecordset alloc] initWithConnection:connection pageSize:pageSize page:page];
}

- (instancetype)initWithConnection:(SQLiteConnection *)connection {
    if (self = [super init]) {
        _connection = connection;
    }
    return self;
}

- (instancetype)initWithConnection:(SQLiteConnection *)connection pageSize:(NSUInteger)pageSize page:(NSUInteger)page {
    if (self = [super init]) {
        _connection = connection;
        _pageSize = page;
        _page = page;
        
    }
    return self;
}

/**
 *  根据指定的SQL语句打开记录集
 *
 *  @param sqlString SQL语句
 *
 *  @return 记录集是否成功打开
 */
// int sqlite3_prepare_v2(sqlite3 *db, const char *zSql, int nByte, sqlite3_stmt **ppStmt, const char **pzTail);
// 参数说明：
// 第一个参数，是数据库连接；
// 第二个参数，是 utf8 格式的 char 字符串；
// 第三个参数，读取 sql 语句的长度，负数读取到结尾字符（'\0'），正数读取到指定字符，0 不读取；
// 第四个参数，伴随指针。
// 第五个参数，返回当前SQL语句中没有执行的部分，也就是这个函数可以执行多个由分号连接的SQL语句，每次执行一个
- (BOOL)openWithSqlString:(NSString *)sqlString {
    if (_connection.status && !_status) {
        NSString *string = sqlString;
        if (_pageSize > 0) {
            string = [string stringByAppendingFormat:@" LIMIT %ld OFFSET %ld", _pageSize, _page];
        }
        NSInteger result_code = sqlite3_prepare_v2(_connection.conn, string.UTF8String, -1, &_stmt, NULL);
#ifdef SQLiteDB_SQL_Result_Description_Print
        NSLog(@"{\n\tSource: SQLiteRecordset, \n\tAction: (openWithSqlString), \n\tSQL: %@, \n\tCode: %ld, \n\tDescription: %@\n}", string, result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
        if (result_code == SQLITE_OK) {
            _sql = sqlString;
            _status = YES;
            _bof = YES;
            // 对象已经准备好
            [self recordsetDidReady];
            // 写模式的特殊处理
            if (_cursorMode) {
                sqlite3_stmt *stmt = NULL;
                string = [self sqlForInternalUse];
                result_code = sqlite3_prepare_v2(_connection.conn, string.UTF8String, -1, &stmt, NULL);
#ifdef SQLiteDB_SQL_Result_Description_Print
                NSLog(@"{\n\tSource: SQLiteRecordset, \n\tAction: (openWithSqlString), \n\tSQL: %@, \n\tCode: %ld, \n\tDescription: %@\n}", string, result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
                if (result_code == SQLITE_OK) {
                    // 重新打开的记录是 查询字段 是原查询的所有字段 + 主键字段（如果主键字段不在原查询字段中）
                    _recordsetUpdateMode = SqliteRecordsetCursorModify;
                    sqlite3_finalize(_stmt);
                    _stmt = stmt;
                }
                stmt = NULL;
            }
            // 记录集指针移动到第一行
            [self moveFirst];
        }
    }
    return _status;
}

- (BOOL)openWithSqlString:(NSString *)sqlString writable:(BOOL)writable {
    _cursorMode = writable;
    return [self openWithSqlString:sqlString];
}

- (BOOL)openWithSqlFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2) {
    va_list arg_p;
    va_start(arg_p, format);
    NSString *sqlString = [[NSString alloc] initWithFormat:format arguments:arg_p];
    va_end(arg_p);
    return [self openWithSqlString:sqlString];
}

- (BOOL)openWithWritable:(BOOL)writable sqlFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3) {
    _cursorMode = writable;
    va_list arg_p;
    va_start(arg_p, format);
    NSString *sqlString = [[NSString alloc] initWithFormat:format arguments:arg_p];
    va_end(arg_p);
    return [self openWithSqlString:sqlString];
}

/**
 *  一些准备工作，获取当前查询的所有字段_allFields；如果是写模式，判断当前查询的表是否可写 _writable，并在可写时，获取表名 _table，数据库名 _database，新的查询语句 _sqlForUpdateMode。
 *
 *  包含所有主键的数组
 *  sqlite3_table_column_metadata(sqlite3 *, const char *, const char *, const char *, char const **, char const **, int *, int *, int *);
 *  函数说明：SQLITE_OK 表示执行成功
 *  参数1：数据库连接
 *  参数2：数据库名
 *  参数3：表名（如果是视图的话，直接返回错误代码）
 *  参数4：列名（如果指定的列不存在，函数返回 SQLITE_ERROR；如果列名为NULL，则只检测表是否存在）
 *  参数5：输出，声明的数据类型
 *  参数6：输出，排序规则
 *  参数7：输出，是否允许NULL
 *  参数8：输出，是否是主键
 *  参数9：输出，是否自增
 */
- (void)recordsetDidReady {
    // 实际查询的字段（包含了主键）
    if (_sqliteFields == nil) {
        _sqliteFields = [NSMutableArray array];
    }
    // 这个字典是为了方便使用的
    if (_keyedFields == nil) {
        _keyedFields = [NSMutableDictionary dictionary];
    }
    
    // 字段数
    int colCount = sqlite3_column_count(_stmt);
    
    // table_name、database_name用于比较的表名、数据库名；一般是第一列。这内存是动态开辟的，需要释放。
    char *table_name = NULL, *database_name = NULL;
    
    // tb_name、db_name 遍历时获取到的每一列所属的表名、数据库名。
    const char *tb_name = NULL, *db_name = NULL, *col_name = NULL, *col_org_name = NULL;
    
    // 字段
    SQLiteField *tmpField;
    
    // 字段名
    NSString *tmpFieldName, *tmpFieldOriginName;
    
    // 数据类型描述
    SQLiteDataTypeDescription tmpFieldDataTypeDesciption;
    
    for (int i = 0; i < colCount; i ++) {
        // 从重用池获取 字段对象
        tmpField = [self dequeueReusableField];
        tmpField.index = i;
        tmpField.isAutoIncrement = NO;
        tmpField.isPrimaryKey = NO;
        tmpField.isNotNull = NO;
        
        // 字段名，查询字段名，即如果使用as重命名字段，返回重命名后的字段名
        col_name = sqlite3_column_name(_stmt, i);
        // 原始名字
        col_org_name = sqlite3_column_origin_name(_stmt, i);
        if (col_org_name != NULL && col_name != NULL) {
            if (strcmp(col_name, col_org_name) == 0) {
                tmpFieldName = [NSString stringWithUTF8String:col_name];
                tmpFieldOriginName = tmpFieldName;
            }else{
                tmpFieldName = [NSString stringWithUTF8String:col_name];
                tmpFieldOriginName = [NSString stringWithUTF8String:col_org_name];
            }
        }else if (col_org_name != NULL) {
            tmpFieldOriginName = [NSString stringWithUTF8String:col_org_name];
            tmpFieldName = [NSString stringWithFormat:@"(%d)", i];
        }else if (col_name != NULL) {
            tmpFieldName = [NSString stringWithUTF8String:col_name];
            tmpFieldOriginName = [NSString stringWithFormat:@"(%d)", i];
        }else{
            tmpFieldName = [NSString stringWithFormat:@"(%d)", i];
            tmpFieldOriginName = tmpFieldName;
        }
        tmpField.name = tmpFieldName;
        tmpField.originName = tmpFieldOriginName;
        
        // 创建表时声明的数据类型
        tmpFieldDataTypeDesciption = [SQLiteData sqliteDataTypeDescriptionForDataTypeCName:sqlite3_column_decltype(_stmt, i)];
        tmpField.dataType = tmpFieldDataTypeDesciption.type;
        tmpField.storageType = tmpFieldDataTypeDesciption.storageType;
        tmpField.dataSize = tmpFieldDataTypeDesciption.size;
        
        // 表名
        tb_name = sqlite3_column_table_name(_stmt, i);
        if (tb_name) {
            tmpField.table = [NSString stringWithUTF8String:tb_name];
        }else{
            tmpField.table = @"(null)";
        }
        
        // 数据库名
        db_name = sqlite3_column_database_name(_stmt, i);
        if (db_name) {
            tmpField.database = [NSString stringWithUTF8String:db_name];
        }else{
            tmpField.database = @"(null)";
        }
        
        // 判断当前查询的列是否属于同一个表或同一个数据库
        if (_cursorMode) {
            if (table_name == NULL) {
                if (tb_name && db_name) {
                    table_name = malloc(sizeof(char) * (strlen(tb_name) + 1));
                    database_name = malloc(sizeof(char) * (strlen(db_name) + 1));
                    strcpy(table_name, tb_name);
                    strcpy(database_name, db_name);
                }else{
                    _cursorMode = NO;
                }
            }else{
                if (strcmp(table_name, tb_name) != 0 || strcmp(database_name, db_name) != 0) {
                    _cursorMode = NO;
                }
            }
        }
        
        // 添加到数组
        [_sqliteFields addObject:tmpField];
        _keyedFields[tmpFieldName] = tmpField;
    }
    
    // 释放内存
    if (table_name != NULL) {
        free(table_name);
        free(database_name);
        table_name = NULL;
        database_name = NULL;
    }
    
    // 当前查询的字段，不包含值，可能不包含主键
    _allFields = [[NSArray alloc] initWithArray:_sqliteFields copyItems:YES];
    
    // 写模式的主键查询，根据当前表名数据库名，遍历表的每一列，检测列（原始名）是否是主键
    if (_cursorMode) {
        if (_table == nil) {
            _table = [[NSMutableString alloc] initWithUTF8String:tb_name];
        }else{
            [_table setString:[NSString stringWithUTF8String:tb_name]];
        }
        if (_database == nil) {
            _database = [[NSMutableString alloc] initWithUTF8String:db_name];
        }else{
            [_database setString:[NSString stringWithUTF8String:db_name]];
        }
        // 可变数组，保存主键
        if (_primaryKeys == nil) {
            _primaryKeys = [[NSMutableArray alloc] init];
        }
        
        // 这个block，把主键放入 primaryKeys 数组，如果主键不在 fields 里，添加到其末尾。这个block的前三个参数不能 NULL 。
        BOOL (^check_table_column_metadata)(const char *, const char *, const char *, NSMutableArray *, NSMutableArray *) = ^(const char *db_name, const char *tb_name, const char *col_name, NSMutableArray *fields, NSMutableArray *primaryKeys){
            const char *col_decltype;  // 字段声明的数据类型
            int isPrimaryKey = NO, isAutoIncrement, isNotNull, result_code;
            result_code = sqlite3_table_column_metadata(_connection.conn, db_name, tb_name, col_name, &col_decltype, NULL, &isNotNull, &isPrimaryKey, &isAutoIncrement);
            if (result_code == SQLITE_OK) {
                if (isPrimaryKey) {
                    NSString *fieldName = [NSString stringWithUTF8String:col_name];
                    SQLiteField *field = _keyedFields[fieldName];
                    if (field == nil) {
                        // 主键字段不在查询字段之中
                        field = [self dequeueReusableField];
                        field.index = (unsigned int)fields.count;
                        field.name = fieldName;
                        field.value = nil;
                        SQLiteDataTypeDescription dataTypeDescription = [SQLiteData sqliteDataTypeDescriptionForDataTypeCName:col_decltype];
                        field.dataType = dataTypeDescription.type;
                        field.storageType = dataTypeDescription.storageType;
                        [fields addObject:field];
                        _keyedFields[fieldName] = field;
                    }
                    field.isNotNull = isNotNull;
                    field.isPrimaryKey = isPrimaryKey;
                    field.isAutoIncrement = isAutoIncrement;
                    [primaryKeys addObject:field];
                    // 自增主键只能有一个，不用再查了
                    if (isAutoIncrement) {
                        return YES;
                    }
                }
            }
            return NO;
        };
        sqlite3_stmt *stmt = NULL;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM `%@` LIMIT 1", _table];
        NSInteger result_code = sqlite3_prepare_v2(_connection.conn, sqlString.UTF8String, -1, &stmt, NULL);
#ifdef SQLiteDB_SQL_Result_Description_Print
        NSLog(@"{\n\tSource: SQLiteRecordset, \n\tAction: (recordsetDidReady), \n\tSQL: %@, \n\tCode: %ld, \n\tDescription: %@\n}", sqlString, result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
        if (result_code == SQLITE_OK) {
            int col_count = sqlite3_column_count(stmt);
            const char *col_name;
            for (int i = 0; i < col_count; i ++) {
                col_name = sqlite3_column_name(stmt, i);
                if (col_name) {
                    if (check_table_column_metadata(db_name, tb_name, col_name, _sqliteFields, _primaryKeys)) {
                        break;
                    }
                }
            }
            if (_primaryKeys.count == 0 && !_keyedFields[@"rowid"]) {
                check_table_column_metadata(db_name, tb_name, "rowid", _sqliteFields, _primaryKeys);
                if (_primaryKeys.count == 0 && !_keyedFields[@"oid"]){
                    check_table_column_metadata(db_name, tb_name, "oid", _sqliteFields, _primaryKeys);
                    if (_primaryKeys.count == 0 && !_keyedFields[@"_rowid_"]) {
                        check_table_column_metadata(db_name, tb_name, "_rowid_", _sqliteFields, _primaryKeys);
                        if (_primaryKeys.count == 0) {
                            _cursorMode = NO;
#ifdef SQLiteDB_SQL_Result_Description_Print
                            NSLog(@"没有找到当前查询的主键");
#endif
                        }
                    }
                }

            }
            sqlite3_finalize(stmt);
            stmt = NULL;
        }else{
            _cursorMode = NO;
        }
    }
}

- (NSMutableString *)sqlForInternalUse {
    if (_sqlForInternalUse == nil) {
        _sqlForInternalUse = [[NSMutableString alloc] init];
    }else if (_sqlForInternalUse.length > 0) {
        return _sqlForInternalUse;
    }
    __block const char *sqlCString = [_sql lowercaseString].UTF8String;
    __block NSInteger sqlCStringLength = strlen(sqlCString);
    __block NSInteger i = 0;
    __block char *tmpCString = malloc(sizeof(char) * (sqlCStringLength + 1));
    
    // 从位置 i 处开始截取字符串，直到遇到结束符位置，截取的字符串包括起始位置和终止位置
    // 截取结束，i 指向的是所截取的字符串后面第一个字符。
    __block __weak void (^split_string_duplicate)(char, NSInteger);
    void (^split_string)(char, NSInteger) = ^(char endChar, NSInteger start){
        NSInteger j = start;
        BOOL meetEnd = NO;
        switch (endChar) {
            case ',':
                // 对于逗号，单独列出来
                tmpCString[j++] = sqlCString[i++];
                tmpCString[j] = '\0';
                break;
            case ')':
                // 以右括号结尾，要屏蔽单引号和反单引号里的字符串
                while (i < sqlCStringLength) {
                    // 因为字符数组的长度比字符数组元素的个数少1，这里不用担心越界的问题
                    tmpCString[j++] = tolower(sqlCString[i++]);
                    if (meetEnd) {
                        tmpCString[j] = '\0';
                        break;
                    }
                    switch (sqlCString[i]) {
                        case '\'':
                            split_string_duplicate('\'', j);
                            j = strlen(tmpCString);
                            if (sqlCString[i] == ')') {
                                meetEnd = YES;
                            }
                            break;
                        case '`':
                            split_string_duplicate('`', j);
                            j = strlen(tmpCString);
                            if (sqlCString[i] == ')') {
                                meetEnd = YES;
                            }
                            break;
                        case ')':
                            meetEnd = YES;
                            break;
                        default:
                            break;
                    }
                }
                break;
            case '\'':
                // 单引号，要屏蔽两个连续的单引号
                while (i < sqlCStringLength) {
                    // 单引号的内容字符不转小写
                    tmpCString[j++] = sqlCString[i++];
                    if (meetEnd) {                      // 上一个字符是单引号
                        if (sqlCString[i] == '\'') {    // 又是单引号
                            meetEnd = NO;               // 继续
                        }else{                          // 不是单引号，说明字符结束了
                            tmpCString[j] = '\0';
                            break;
                        }
                    }else{
                        if (sqlCString[i] == '\'') {    // 下一个是单引号
                            meetEnd = YES;
                        }
                    }
                }
                break;
            case '`':
                // 反单引号 取所有内容
                while (i < sqlCStringLength) {
                    tmpCString[j++] = tolower(sqlCString[i++]);
                    if (meetEnd) {
                        tmpCString[j] = '\0';
                        break;
                    }else{
                        if (sqlCString[i] == '`') {
                            meetEnd = YES;
                        }
                    }
                }
                break;
            default:
                // 其它字符，遇到空格或逗号结束, 遇到左小括号就直到右小括号结束
                while (i < sqlCStringLength) {
                    tmpCString[j++] = tolower(sqlCString[i++]);
                    if (sqlCString[i] == '('){
                        split_string_duplicate(')', j);
                        j = strlen(tmpCString);
                    }
                    if (sqlCString[i] == ' ' || sqlCString[i] == ',') {
                        tmpCString[j] = '\0';
                        break;
                    }
                }
                break;
        }
    };
    // 复制上面这个block，使其可在其内部调用
    split_string_duplicate = split_string;
    
    // 遍历 找到 from
    while (i < sqlCStringLength) {
        switch (sqlCString[i]) {
            case '(':
                split_string(')', 0);
                break;
            case '\'':
                split_string('\'', 0);
                break;
            case '`':
                split_string('`', 0);
                break;
            case ' ':
                while (i++ < sqlCStringLength) {
                    if (sqlCString[i] != ' ') {
                        break;
                    }
                }
                break;
            default:
                split_string(sqlCString[i], 0);
                break;
        }
        if (strcmp(tmpCString, "from") == 0) {
            break;
        }
    }
    
    for (NSInteger i = 0; i < _sqliteFields.count; i ++) {
        SQLiteField *field = _sqliteFields[i];
        if (_sqlForInternalUse.length > 0) {
            [_sqlForInternalUse appendFormat:@", `%@`", field.name];
        }else{
            [_sqlForInternalUse appendFormat:@"`%@`", field.name];
        }
    }
    [_sqlForInternalUse insertString:@"select " atIndex:0];
    [_sqlForInternalUse appendFormat:@" from%@ LIMIT %ld", [_sql substringFromIndex:i], self.count];
    return _sqlForInternalUse;
}

/**
 *  移动记录集指针的方法
 *  对于 SQLITE 数据库来说，这只是一个虚拟的概念，并不存在这样的指针
 *  记录集指向的记录，可以用 valueForField 取出，或通过 setValue:forField: 更新值，或通过 remove 方法删除该记录
 *  另外 movePrevious、moveLast 方法是通过前面两个方法实现的
 *
 *  sqlite3_reset() 方法，如果 sqlite3_reset 之前调用过 sqlite3_step ，如果发生错误，则返回 sqlite3_step 的错误码；其它情况， sqlite3_reset 返回 SQLITE_OK 。
 */
- (void)moveNext {
    if (_status) {
        if (!_eof) {
            if (sqlite3_step(_stmt) == SQLITE_ROW) {
                _cursorLocation ++;
                [self fetchValueFromCurrentRecord];
            }else{
                _eof = YES;
                _cursorLocation = NSNotFound;
            }
        }
    }
}

- (void)moveFirst {
    if (_status) {
        if (_bof) {
            [self moveNext];
            if (!_eof) {
                _bof = NO;
            }
        }else{
            if (_cursorLocation > 1) {
                if (sqlite3_reset(_stmt) == SQLITE_OK) {
                    [self moveNext];
                }else{
                    _bof = YES;
                    _eof = YES;
                    _cursorLocation = NSNotFound;
                }
            }
        }
    }
}

- (void)movePrevious {
    if (_status) {
        if (!_bof) {
            NSInteger cursorTargetLocation = _cursorLocation - 1;
            if (sqlite3_reset(_stmt) == SQLITE_OK) {
                _bof = YES;
                _cursorLocation = 0;
                if (cursorTargetLocation > 0) {
                    while (_cursorLocation < cursorTargetLocation) {
                        if (sqlite3_step(_stmt) != SQLITE_ROW) {
                            _cursorLocation = NSNotFound;
                            _eof = YES;
                            break;
                        }
                        _cursorLocation ++;
                    }
                    if (_cursorLocation > 0) {
                        _bof = NO;
                    }
                }
            }else{
                _bof = YES;
                _eof = YES;
                _cursorLocation = NSNotFound;
            }
        }
    }
    [self fetchValueFromCurrentRecord];
}

- (void)moveLast {
    if (_status) {
        NSInteger cursorTargetLocation = self.count;
        if (_count > 0) {
            if (_eof) {
                if (sqlite3_reset(_stmt) != SQLITE_OK) {
                    _bof = YES;
                    _cursorLocation = NSNotFound;
                    return;
                }
                _cursorLocation = 0;
            }
            if (_cursorLocation < cursorTargetLocation) {
                while (_cursorLocation < cursorTargetLocation) {
                    if (sqlite3_step(_stmt) != SQLITE_ROW) {
                        _cursorLocation = NSNotFound;
                        _eof = YES;
                        break;
                    }
                    _cursorLocation ++;
                }
                if (_cursorLocation > 0) {
                    _bof = NO;
                }
            }
        }
    }
    [self fetchValueFromCurrentRecord];
}

/**
 *  格式化日期，这个是同一个记录集共用的，close方法不将此清空
 */
- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter != nil) {
        return _dateFormatter;
    }
    _dateFormatter = [[NSDateFormatter alloc] init];
    return _dateFormatter;
}

// const void *             sqlite3_column_blob(sqlite3_stmt*, int iCol);    // 返回二进制
// int                      sqlite3_column_bytes(sqlite3_stmt*, int iCol);   // 返回 字符串或二进制数据 的字节数（非字符数），utf-8
// int                      sqlite3_column_bytes16(sqlite3_stmt*, int iCol); // 字节大小 utf-16
// double                   sqlite3_column_double(sqlite3_stmt*, int iCol);  // 双精度
// int                      sqlite3_column_int(sqlite3_stmt*, int iCol);     // 整形
// sqlite3_int64            sqlite3_column_int64(sqlite3_stmt*, int iCol);   // 整形 utf-16
// const unsigned char *    sqlite3_column_text(sqlite3_stmt*, int iCol);    // 无符号字符数组
// const void *             sqlite3_column_text16(sqlite3_stmt*, int iCol);  // utf-16 字符
// int                      sqlite3_column_type(sqlite3_stmt*, int iCol);    // 返回初始的数据类型
// sqlite3_value *          sqlite3_column_value(sqlite3_stmt*, int iCol);   // 结构体

- (void)fetchValueFromCurrentRecord {
    if (_status) {
        id value;
        NSUInteger bytes;
        NSArray *fields = [_keyedFields allValues];
        NSInteger realStorageType;        // 实际存储类型，取值需要根据这个来取
        int index;
        NSInteger declaredStorageType;    // 创建表时声明的数据类型
        
        for (SQLiteField *field in fields) {
            value = nil;
            index = field.index;
            realStorageType = sqlite3_column_type(_stmt, index);
            declaredStorageType = field.storageType;
            bytes = 0;
            switch (realStorageType) {
                case SQLITE_INTEGER:
                    switch (declaredStorageType) {
                        case SQLiteInt8:
                        case SQLiteBigInt:
                        case SQLiteUnsignedBigInt:
                            value = [NSNumber numberWithLongLong:sqlite3_column_int64(_stmt, index)];
                            break;
                        default:
                            value = [NSNumber numberWithInteger:sqlite3_column_int(_stmt, index)];
                            break;
                    }
                    break;
                case SQLITE_FLOAT:
                    value = [NSNumber numberWithDouble:sqlite3_column_double(_stmt, index)];
                    break;
                case SQLITE_TEXT:
                    value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(_stmt, index)];
                    bytes = sqlite3_column_bytes(_stmt, index);
                    break;
                case SQLITE_BLOB:
                    bytes = sqlite3_column_bytes(_stmt, index);
                    value = [NSData dataWithBytes:sqlite3_column_blob(_stmt, index) length:bytes];
                    break;
                case SQLITE_NULL:
                    break;
                default:
                    break;
            }
            // 日期类型转化
            switch (field.dataType) {
                case SQLiteDateTime:
                case SQLiteDate:
                    if ([value isKindOfClass:[NSNumber class]]) {
                        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
                        if (date != nil) {
                            value = date;
                        }
                    }else if ([value isKindOfClass:[NSString class]]) {
                        switch (field.dataType) {
                            case SQLiteDateTime:
                                self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                                break;
                            case SQLiteDate:
                                self.dateFormatter.dateFormat = @"yyyy-MM-dd";
                                break;
                            default:
                                break;
                        }
                        NSDate *date = [_dateFormatter dateFromString:value];
                        if (date != nil) {
                            value = date;
                        }
                    }
                    break;
                default:
                    break;
            }
            field.bytes = bytes;
            field.originValue = value;
            field.value = value;
        }
    }
}

/**
 *  获取字段内容
 *
 *  @param field 字段名，不分大小写
 *
 *  @return 返回的是一个对象 NSNumber NSString NSData NSDate nil
 */
- (id)valueForField:(NSString *)field {
    return ((SQLiteField *)(_keyedFields[field])).originValue;
}

- (id)valueForKey:(NSString *)key {
    return [self valueForField:key];
}

- (id)objectForKey:(NSString *)aKey {
    return [self valueForField:aKey];
}

- (id)objectForKeyedSubscript:(NSString *)aKey {
    return [self valueForField:aKey];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index NS_AVAILABLE(10_8, 6_0) {
    return ((SQLiteField *)_sqliteFields[index]).originValue;
}

// 更新依赖的是数据库主键
- (void)addNew {
    if (_status && _cursorMode) {
        _recordsetUpdateMode = SqliteRecordsetCursorAddNew;
        // 插入数据，清空 value
        for (SQLiteField *field in _sqliteFields) {
            field.value = nil;
        }
    }
}

- (void)setValue:(id)value forField:(NSString *)field {
    ((SQLiteField *)(_keyedFields[field])).value = value;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [self setValue:value forField:key];
}

- (void)setObject:(id)anObject forKey:(NSString *)aKey {
    [self setValue:anObject forField:aKey];
}

- (void)setObject:(id)anObject forKeyedSubscript:(NSString *)aKey {
    [self setValue:anObject forField:aKey];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index {
    ((SQLiteField *)_sqliteFields[index]).value = obj;
}

- (void)delete {
    if (_status && _cursorMode) {
        _recordsetUpdateMode = SqliteRecordsetCursorDelete;
    }
}

/**
 *  应用更新：
 *  对于插入数据，会跳过值为nil的字段
 *  对于修改，nil值的字段绑定NULL，如果约定了非NULL就不会更新成功。
 *  @return YES、NO
 */
- (BOOL)update {
    int result_code;
    sqlite3_stmt *stmt = NULL;
    switch (_recordsetUpdateMode) {
        case SqliteRecordsetCursorAddNew:
            stmt = [self stmtForInsert];
            if (stmt) {
                [self bindFields:_fieldsForInsert toSqliteStmt:stmt];
                result_code = sqlite3_step(stmt);
                sqlite3_finalize(stmt);
                stmt = NULL;
                if (result_code == SQLITE_DONE) {
                    return YES;
                }
#ifdef SQLiteDB_SQL_Result_Description_Print
                NSLog(@"{\n\tSource: SQLiteRecordset, \n\tAction: (update), \n\tCode: %d, \n\tDescription: %@\n}", result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
            }
            break;
        case SqliteRecordsetCursorModify:
            stmt = [self stmtForUpdate];
            if (stmt) {
                [self bindFields:_fieldsForUpdate toSqliteStmt:stmt];
                result_code = sqlite3_step(stmt);
                sqlite3_finalize(stmt);
                stmt = NULL;
                if (result_code == SQLITE_DONE) {
                    return YES;
                }
#ifdef SQLiteDB_SQL_Result_Description_Print
                NSLog(@"{\n\tSource: SQLiteRecordset, \n\tAction: (update), \n\tCode: %d, \n\tDescription: %@\n}", result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
            }
            break;
        case SqliteRecordsetCursorDelete:
            result_code = sqlite3_exec(_connection.conn, [self sqlForDelete].UTF8String, NULL, NULL, NULL);
            if (result_code == SQLITE_OK) {
                return YES;
            }
#ifdef SQLiteDB_SQL_Result_Description_Print
            NSLog(@"{\n\tSource: SQLiteRecordset, \n\tAction: (update), \n\tCode: %d, \n\tDescription: %@\n}", result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
            break;
        default:
            break;
    }
    return NO;
}

// 更新记录的筛选条件，也就是当前主键的值
- (NSString *)filterPartOfSqlForUpdate {
    NSMutableString *string = [NSMutableString string];
    for (SQLiteField *field in _primaryKeys) {
        if (string.length == 0) {
            [string appendFormat:@"`%@` = '%@'", field.name, field.originValue];
        }else{
            [string appendFormat:@" AND `%@` = '%@'", field.name, field.originValue];
        }
    }
    return string;
}

// 返回用于删除记录的 SQL 语句
- (NSString *)sqlForDelete {
    if (_deleteSqlMainPart == nil) {
        _deleteSqlMainPart = [[NSMutableString alloc] init];
    }else if (_deleteSqlMainPart.length > 0) {
        return [_deleteSqlMainPart stringByAppendingString:[self filterPartOfSqlForUpdate]];
    }
    [_deleteSqlMainPart appendFormat:@"DELETE FROM `%@` WHERE ", _table];
    return [_deleteSqlMainPart stringByAppendingString:[self filterPartOfSqlForUpdate]];
}

// 准备用于储存需要更新字段的数组
- (void)fieldsForUpdateDidReady {
    if (_fieldsForUpdate != nil) {
        [_fieldsForUpdate removeAllObjects];
        return;
    }
    _fieldsForUpdate = [[NSMutableArray alloc] init];
}

// 返回用于更新的 SQL 语句
- (NSString *)sqlForUpdate {
    [self fieldsForUpdateDidReady];
    if (_updateSqlMainPart == nil) {
        _updateSqlMainPart = [[NSMutableString alloc] initWithFormat:@"UPDATE `%@` SET", _table];
    }else if (_updateSqlMainPart.length == 0) {
        [_updateSqlMainPart appendFormat:@"UPDATE `%@` SET", _table];;
    }
    return [_updateSqlMainPart stringByAppendingFormat:@" %@ WHERE %@", [self sqlFieldPartForUpdate], [self filterPartOfSqlForUpdate]];
}

- (NSString *)sqlFieldPartForUpdate {
    NSMutableString *string = [NSMutableString string];
    NSInteger count = _allFields.count;
    for (NSInteger i = 0; i < count; i ++) {
        SQLiteField *field = _sqliteFields[i];
        if (field.value != field.originValue) {
            [_fieldsForUpdate addObject:_sqliteFields[i]];
            if (string.length > 0) {
                [string appendFormat:@", `%@` = ?", field.name];
            }else{
                [string appendFormat:@"`%@` = ?", field.name];
            }
        }
    }
    return string;
}

// 返回用于更新的 stmt
- (sqlite3_stmt *)stmtForUpdate {
    NSString *sqlString = [self sqlForUpdate];
    sqlite3_stmt *stmt = NULL;
    NSInteger result_code = sqlite3_prepare_v2(_connection.conn, sqlString.UTF8String, -1, &stmt, NULL);
#ifdef SQLiteDB_SQL_Result_Description_Print
    NSLog(@"{\n\tSource: SQLiteRecordset, \n\tAction: (stmtForUpdate), \n\tSQL: %@, \n\tCode: %ld, \n\tDescription: %@\n}", sqlString, result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
    if (result_code != SQLITE_OK) {
        stmt = NULL;
    }
    return stmt;
}

// 调用此方法，总是返回一个空的数组
- (void)fieldsForInsertDidReady {
    if (_fieldsForInsert != nil) {
        [_fieldsForInsert removeAllObjects];
        return;
    }
    _fieldsForInsert = [[NSMutableArray alloc] init];
}

// 返回用于插入数据的 SQL 语句
- (NSString *)sqlForInsert {
    [self fieldsForInsertDidReady];  // 这个数组每次都会重置
    if (_insertSqlMainPart == nil) {
        _insertSqlMainPart = [[NSMutableString alloc] initWithFormat:@"INSERT INTO `%@` ", _table];
    }else if (_insertSqlMainPart.length == 0) {
        [_insertSqlMainPart appendFormat:@"INSERT INTO `%@` ", _table];
    }
    return [_insertSqlMainPart stringByAppendingString:[self sqlFieldPartForInsert]];
}

// 返回用于插入数据的 SQL 语句的 字段 和 值 占位部分
- (NSString *)sqlFieldPartForInsert {
    NSMutableString *string1 = [NSMutableString string];
    NSMutableString *string2 = [NSMutableString string];
    for (NSInteger i = 0; i < _sqliteFields.count; i ++) {
        SQLiteField *field = _sqliteFields[i];
        if (field.value != nil) {
            [_fieldsForInsert addObject:field];
            if (string1.length > 0) {
                [string1 appendFormat:@", `%@`", field.name];
                [string2 appendString:@", ?"];
            }else{
                [string1 appendFormat:@"(`%@`", field.name];
                [string2 appendString:@"(?"];
            }
        }
    }
    return [string1 stringByAppendingFormat:@") VALUES %@)", string2];
}

// 返回用于插入数据的 stmt
- (sqlite3_stmt *)stmtForInsert {
    NSString *sqlString = [self sqlForInsert];
    sqlite3_stmt *stmt = NULL;
    NSInteger result_code = sqlite3_prepare_v2(_connection.conn, sqlString.UTF8String, -1, &stmt, NULL);
#ifdef SQLiteDB_SQL_Result_Description_Print
    NSLog(@"{\n\tSource: SQLiteRecordset, \n\tAction: (stmtForUpdate), \n\tSQL: %@, \n\tCode: %ld, \n\tDescription: %@\n}", sqlString, result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
    if (result_code != SQLITE_OK) {
        stmt = NULL;
    }
    return stmt;
}

/*
 *  int sqlite3_bind_blob(sqlite3_stmt*, int, const void*, int n, void(*)(void*));
 *  int sqlite3_bind_blob64(sqlite3_stmt*, int, const void*, sqlite3_uint64, void(*)(void*));
 *  int sqlite3_bind_double(sqlite3_stmt*, int, double);
 *  int sqlite3_bind_int(sqlite3_stmt*, int, int);
 *  int sqlite3_bind_int64(sqlite3_stmt*, int, sqlite3_int64);
 *  int sqlite3_bind_null(sqlite3_stmt*, int);
 *  int sqlite3_bind_text(sqlite3_stmt*,int,const char*,int,void(*)(void*));
 *  int sqlite3_bind_text16(sqlite3_stmt*, int, const void*, int, void(*)(void*));
 *  int sqlite3_bind_text64(sqlite3_stmt*, int, const char*, sqlite3_uint64, void(*)(void*), unsigned char encoding);
 *  int sqlite3_bind_value(sqlite3_stmt*, int, const sqlite3_value*);
 *  int sqlite3_bind_zeroblob(sqlite3_stmt*, int, int n);
 *  int sqlite3_bind_zeroblob64(sqlite3_stmt*, int, sqlite3_uint64);
 *  未绑定的参数会被设置为NULL
 *
 *  给指定的伴随指针绑定数据，需要更新的字段保存在 _fieldsForUpdate 数组中，
 *
 *
 */
- (void)bindFields:(NSArray *)fields toSqliteStmt:(sqlite3_stmt *)stmt  {
    NSInteger count = fields.count;
    SQLiteField *field;
    id value;
    int index;
    for (int i = 0; i < count; i ++) {
        field = fields[i];
        value = field.value;
        index = i + 1;
        if (value == nil) {
            goto switch_to_bind_null_branch;
        }
        switch (field.dataType) {
            case SQLiteNull:    // NULL
            switch_to_bind_null_branch:
                sqlite3_bind_null((stmt), index);
                break;
            case SQLiteInteger: // 整形 最大 8 字节
            case SQLiteBigInt:
            case SQLiteUnsignedBigInt:
            case SQLiteInt8:
            case SQLiteNumeric:
            case SQLiteDecimal:
                if ([value respondsToSelector:@selector(longLongValue)]) {
                    sqlite3_bind_int64(stmt, index, [value longLongValue]);
                }else{
                    sqlite3_bind_int(stmt, index, 0);
                }
                break;
            case SQLiteInt2:
            case SQLiteInt:
            case SQLiteTinyInt:
            case SQLiteSmallint:
            case SQLiteMediumint:
            case SQLiteBoolean:
                if ([value respondsToSelector:@selector(integerValue)]) {
                    sqlite3_bind_int(stmt, index, [value intValue]);
                }else{
                    sqlite3_bind_int(stmt, index, 0);
                }
                break;
            // 浮点数
            case SQLiteFloat:
            case SQLiteDouble:
            case SQLiteReal:
            case SQLiteDoublePrecision:
                if ([value respondsToSelector:@selector(doubleValue)]) {
                    sqlite3_bind_double((stmt), index, [value doubleValue]);
                }else{
                    sqlite3_bind_double((stmt), index, 0);
                }
                break;
            // 字符
            case SQLiteDate:                       // 日期，YYYY-mm-DD
            case SQLiteDateTime:                   // 日期时间，YYYY-mm-DD HH:MM:SS
                if (![value isKindOfClass:[NSString class]]) {
                    if (field.dataType == SQLiteDateTime) {
                        self.dateFormatter.dateFormat = @"yyy-MM-dd HH:mm:ss";
                    }else{
                        self.dateFormatter.dateFormat = @"yyy-MM-dd";
                    }
                    if ([value isKindOfClass:[NSDate class]]) {
                        value = [_dateFormatter stringFromDate:(NSDate *)value];
                    }else if([value isKindOfClass:[NSNumber class]]){
                        value = [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[value doubleValue]]];
                    }
                }
                goto switch_bind_text_branch;
                break;
            case SQLiteVarChar:                    // 字符，255
            case SQLiteText:                       // 文本
            case SQLiteCharacter:          // 22
            case SQLiteVaryingCharacter:   // 255
            case SQLiteNChar:              // 55
            case SQLiteNativeCharacter:    // 70
            case SQLiteNVarChar:           // 100
            case SQLiteClob:               // 超大数据
            switch_bind_text_branch:
                // SQLITE_STATIC 说明参数是静态的，SQLITE 不用复制； SQLITE_TRANSIENT 复制后使用
                if ([value respondsToSelector:@selector(UTF8String)]) {
                    sqlite3_bind_text((stmt), index, [value UTF8String], -1, SQLITE_STATIC);
                }else{
                    sqlite3_bind_null((stmt), index);
                }
                break;
            // 二进制
            case SQLiteBlob:
            case SQLiteNoDatatypeSpecified:
            case SQLiteVariant:
            case SQLiteNotSupported:
                if ([value isKindOfClass:[NSData class]]) {
                    sqlite3_bind_blob((stmt), index, [(NSData *)value bytes], (int)[value length], SQLITE_STATIC);
                }else{
                    if ([value respondsToSelector:@selector(encodeWithCoder:)]) {
                        value = [NSKeyedArchiver archivedDataWithRootObject:value];
                        sqlite3_bind_blob((stmt), index, [(NSData *)value bytes], (int)[value length], SQLITE_STATIC);
                    }else{
                        goto switch_to_bind_null_branch;
                    }
                }
                break;
            default:
                break;
        }
    }
}

/**
 *  关闭记录集
 *
 *  @return 是否成功关闭
 */
- (BOOL)close {
    
    // 当前字段加入重用池，以备重用
    [self sendFieldsToQueue:_sqliteFields];
    
    // 重用的实例变量
    [_primaryKeys removeAllObjects];        // 主键，对于基本表，这个属性会返回当前表的所有主键
    [_keyedFields removeAllObjects];        // 根据名字索引的所有字段
    [_sqliteFields removeAllObjects];       // 实际查询到的所有字段。如果主键不包含在当前查询内，allFields不包含主键，但是下面这个数组包含。
    [_fieldsForUpdate removeAllObjects];    // 用于更新的 fields 列队
    [_fieldsForInsert removeAllObjects];    // 用于更新的 fields 列队
    
    [_table setString:@""];                 // 当前查询的表名，只有是基本表时才会有值
    [_database setString:@""];              // 数据库名，只有是基本表时才会有值
    [_sqlForInternalUse setString:@""];     // 内部使用的 sql 语句
    [_updateSqlMainPart setString:@""];     //
    [_deleteSqlMainPart setString:@""];     //
    [_insertSqlMainPart setString:@""];     //
    
    // 重置状态
    _count = 0;
    _recordsetUpdateMode = SqliteRecordsetCursorReadOnly;
    _sql = nil;
    //_page = 0;
    //_pageSize = 0;
    _cursorMode = _writable;
    _cursorLocation = 0;
    _eof = NO;
    _bof = NO;
    
    // 释放动态开辟的内存
    free((__unsafe_unretained SQLiteField **)_fields);
    _fields = NULL;
    
    // 销毁伴随指针
    _status = NO;
    if (sqlite3_finalize(_stmt) == SQLITE_OK) {
        _stmt = NULL;
        return YES;
    }else{
        _stmt = NULL;
        return NO;
    }
}

- (void)dealloc {
    if (_fields != NULL) {
        free((__unsafe_unretained SQLiteField **)_fields);
        _fields = NULL;
    }
    if (_stmt != NULL) {
        sqlite3_finalize(_stmt);
    }
}

@end
