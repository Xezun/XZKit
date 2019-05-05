//
//  SQLiteConnection.m
//  SQLiteDB
//
//  Created by mlibai on 15/8/15.
//  Copyright (c) 2015年 mlibai. All rights reserved.
//

#import <sqlite3.h>
#import "SQLiteData.h"
#import "SQLiteField.h"
#import "SQLiteConnection.h"

#import "SQLiteExtension.h"

#pragma mark  实现
@implementation SQLiteConnection

- (void)setSource:(NSString *)source {
    if (_connectedCount == 0) {
        _source = source;
    }
}

@synthesize status;

- (BOOL)status {
    return _connectedCount > 0 ? YES : NO;
}

+ (instancetype)connectionWithSource:(NSString *)source {
    return [[SQLiteConnection alloc] initWithSource:source];
}

- (instancetype)initWithSource:(NSString *)source {
    if (self = [super init]) {
        _source = source;
    }
    return self;
}

- (BOOL)open {
    if (_connectedCount > 0) {
        _connectedCount ++;
        return YES;
    }
    NSInteger result = sqlite3_open(_source.UTF8String, &_conn);
    if (result == SQLITE_OK) {
        _connectedCount ++;
        return YES;
    }
#ifdef SQLiteDB_SQL_Result_Description_Print
    NSLog(@"{\t\tSource: SQLiteConnection, \n\tAction: open, \n\tCode: %ld, \n\tDescription: %@\n}", result, [SQLiteData descriptionForResultCode:result]);
#endif
    return NO;
}

- (BOOL)close {
    NSInteger result;
    switch (_connectedCount) {
        case 0:
            return YES;
            break;
        case 1:
            result = sqlite3_close(_conn);
            if (result == SQLITE_OK) {
                _connectedCount = 0;
                return YES;
            }
#ifdef SQLiteDB_SQL_Result_Description_Print
            NSLog(@"{\n\tSource: SQLiteConnection, \n\tAction: close, \n\tCode: %ld, \n\tDescription: %@\n}", result, [SQLiteData descriptionForResultCode:result]);
#endif
            break;
        default:
            _connectedCount --;
            return YES;
            break;
    }
    return NO;
}

- (NSArray *)executeSqlWithFormat:(NSString *)formate, ... {
    va_list arg_p;
    va_start(arg_p, formate);
    NSString *sqlString = [[NSString alloc] initWithFormat:formate arguments:arg_p];
    va_end(arg_p);
    return [self executeSqlWithString:sqlString];
}

int sqlite3_exec_callback(void *execResult, int column_count, char **column_value, char **column_name) {
    NSMutableArray *array = (__bridge NSMutableArray *)(execResult);
    NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < column_count; i ++) {
        NSString *field; id value;
        if (column_name[i]) {
            field = [NSString stringWithUTF8String:column_name[i]];
        }else{
            field = [NSString stringWithFormat:@"(%ld)", i];
        }
        if (column_value[i]) {
            value = [NSString stringWithUTF8String:column_value[i]];
        }else{
            value = [NSNull null];
        }
        tmp[field] = value;
    }
    [array addObject:tmp];
    return 0;
}

- (NSArray *)executeSqlWithString:(NSString *)sqlString {
    NSArray *result;
    if (_connectedCount > 0) {
        char *errmsg;
        NSMutableArray *select_result = [[NSMutableArray alloc] init];
        int result_code = sqlite3_exec(_conn, sqlString.UTF8String, sqlite3_exec_callback, (__bridge void *)select_result, &errmsg);
        if (errmsg) {
            result = [NSArray arrayWithObjects:[NSNumber numberWithInteger:result_code], [NSString stringWithUTF8String:errmsg], nil];
            sqlite3_free(errmsg);
        }else{
            if (select_result == nil) {
                result = [NSArray arrayWithObject:[NSNumber numberWithInteger:result_code]];
            }else{
                result = [NSArray arrayWithObjects:[NSNumber numberWithInteger:result_code], select_result, nil];
            }
        }
#ifdef SQLiteDB_SQL_Result_Description_Print
        NSLog(@"{\n\tSource: SQLiteConnection, \n\tAction: (executeSqlWithString:), \n\tSQL: %@, \n\tCode: %d, \n\tDescription: %@\n}", sqlString, result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
    }else{
        result = [NSArray arrayWithObjects:[NSNumber numberWithInteger:SQLITE_ERROR], [SQLiteData descriptionForResultCode:SQLITE_ERROR], nil];
    }
    return result;
}

- (BOOL)createTable:(NSString *)table fields:(SQLiteField *)field, ... {
    BOOL result = NO;
    if (field != nil) {
        NSMutableString *fieldsPart = [NSMutableString string];
        NSMutableString *primaryKeysPart = [NSMutableString string];
        NSMutableString *tmpfieldPart = [NSMutableString string];
        SQLiteField *arg_v = field;
        va_list arg_p;
        va_start(arg_p, field);
        do {
            if (arg_v.name.length > 0) {
                // 字段名 字段类型
                [tmpfieldPart appendFormat:@"`%@` %@", arg_v.name, [SQLiteData sqliteDataTypeNameForDataType:arg_v.dataType withDataSize:arg_v.dataSize]];
                // 主键
                if(arg_v.isPrimaryKey){
                    // 自增主键只能与字段定义写在一起，如果此时还设置其它主键的话，SQL 语句会执行失败，但是这里不做检查
                    if (arg_v.isAutoIncrement) {
                        [tmpfieldPart appendString:@" PRIMARY KEY AUTOINCREMENT"];
                    }else{
                        if (primaryKeysPart.length == 0) {
                            [primaryKeysPart appendFormat:@"`%@`", arg_v.name];
                        }else{
                            [primaryKeysPart appendFormat:@", `%@`", arg_v.name];
                        }
                    }
                }else{
                    // 非空字段
                    if (arg_v.isNotNull) {
                        [tmpfieldPart appendString:@" NOT NULL"];
                    }
                    // 唯一字段
                    if (arg_v.isUnique) {
                        // 唯一字段，不能设置默认值，这里也不检查
                        [tmpfieldPart appendFormat:@" UNIQUE"];
                    }
                    // 字段默认值
                    if (arg_v.defaultValue != nil) {
                        [tmpfieldPart appendFormat:@" DEFAULT '%@'", arg_v.defaultValue];
                    }
                }
                if (fieldsPart.length > 0) {
                    [fieldsPart appendFormat:@", %@", tmpfieldPart];
                }else{
                    [fieldsPart appendString:tmpfieldPart];
                }
                [tmpfieldPart setString:@""];
            }
        } while ((arg_v = va_arg(arg_p, SQLiteField *)));
        va_end(arg_p);
        NSString *sqlString;
        if (primaryKeysPart.length > 0) {
            sqlString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS `%@` (%@, PRIMARY KEY (%@))", table, fieldsPart, primaryKeysPart];
        }else{
            sqlString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS `%@` (%@)", table, fieldsPart];
        }
        NSInteger result_code = sqlite3_exec(_conn, sqlString.UTF8String, NULL, NULL, NULL);
        if (result_code == SQLITE_OK) {
            result = YES;
        }
#ifdef SQLiteDB_SQL_Result_Description_Print
        NSLog(@"{\n\tSource: SQLiteConnection, \n\tAction: (createTable:fields:), \n\tSQL: %@, \n\tCode: %ld, \n\tDescription: %@\n}", sqlString, result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
    }
#ifdef SQLiteDB_SQL_Result_Description_Print
    else{
        NSLog(@"没有任何字段的表无法创建！");
    }
#endif
    return result;
}

- (BOOL)dropTable:(NSString *)table {
    if (_connectedCount > 0) {
        NSString *sqlString = [NSString stringWithFormat:@"DROP TABLE IF EXISTS `%@`", table];
        NSInteger result_code = sqlite3_exec(_conn, sqlString.UTF8String, NULL, NULL, NULL);
        if (result_code == SQLITE_OK) {
            return YES;
        }
#ifdef SQLiteDB_SQL_Result_Description_Print
        NSLog(@"{\n\tSource: SQLiteConnection, \n\tAction: (dropTable:), \n\tSQL: %@, \n\tCode: %ld, \n\tDescription: %@\n}", sqlString, result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
    }
    return NO;
}

- (BOOL)emptyTable:(NSString *)table {
    if (_connectedCount > 0) {
        NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM `%@`", table];
        NSInteger result_code = sqlite3_exec(_conn, sqlString.UTF8String, NULL, NULL, NULL);
        if (result_code == SQLITE_OK) {
            return YES;
        }
#ifdef SQLiteDB_SQL_Result_Description_Print
        NSLog(@"{\n\tSource: SQLiteConnection, \n\tAction: (emptyTable:), \n\tSQL: %@, \n\tCode: %ld, \n\tDescription: %@\n}", sqlString, result_code, [SQLiteData descriptionForResultCode:result_code]);
#endif
    }
    return NO;
}

- (NSInteger)lastInsertRowid {
    if (_connectedCount > 0) {
        return sqlite3_last_insert_rowid(_conn);
    }
    return 0;
}

@end
