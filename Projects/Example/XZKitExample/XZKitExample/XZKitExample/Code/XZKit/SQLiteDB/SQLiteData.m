//
//  SQLiteData.h
//  SQLiteData
//
//  Created by mlibai on 15/8/7.
//  Copyright (c) 2015年 mlibai. All rights reserved.
//

#import <sqlite3.h>
#import "SQLiteData.h"

// SQLITE_INTEGER=1 SQLITE_FLOAT=2 SQLITE_BLOB=4 SQLITE_NULL=5 SQLITE_TEXT=3 SQLITE3_TEXT=3

// 没有数据范围限制的数据类型的 SQLiteDataSize
const SQLiteDataSize SQLiteDataSizeNone = {0, 0};

// 不支持的数据类型，默认二进制
const SQLiteDataTypeDescription SQLiteNotSupportedDataType = {SQLiteVariant, "BLOB", SQLITE_BLOB, {0, 0}};

#pragma mark SQLiteDB的延展
@interface SQLiteData ()


@end


#pragma mark SQLiteDB的实现
@implementation SQLiteData

// 用户文档路径
+ (NSString *)documentDirectoryRootPath {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

// 用户缓存路径
+ (NSString *)cachesDirectoryRootPath {
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
}

// 所有支持的数据类型
//@synthesize allSupportedDataTypeDescriptions = _allSupportedDataTypeDescriptions;
+ (const SQLiteDataTypeDescription *)allSupportedDataTypeDescriptions {
    // dataTypeDescriptions 在编译阶段初始化，且内容不可以修改，且指针不可修改
    static SQLiteDataTypeDescription const _allSupportedDataTypeDescriptions[SQLiteNotSupported] = {
        {SQLiteNull, "NULL", SQLITE_NULL, {0, 0}},
        
        {SQLiteInteger, "INTEGER", SQLITE_INTEGER, {0, 0}},
        {SQLiteInt, "INT", SQLITE_INTEGER, {0, 0}},
        {SQLiteTinyInt, "TINYINT", SQLITE_INTEGER, {0, 0}},
        {SQLiteSmallint, "SMALLINT", SQLITE_INTEGER, {0, 0}},
        {SQLiteMediumint, "MEDIUMINT", SQLITE_INTEGER, {0, 0}},
        {SQLiteBigInt, "BIGINT", SQLITE_INTEGER, {0, 0}},
        {SQLiteUnsignedBigInt, "UNSIGNED BIG INT", SQLITE_INTEGER, {0, 0}},
        {SQLiteInt2, "INT2", SQLITE_INTEGER, {0, 0}},
        {SQLiteInt8, "INT8", SQLITE_INTEGER, {0, 0}},
        {SQLiteNumeric, "NUMERIC", SQLITE_INTEGER, {0, 0}},
        {SQLiteDecimal,  "DECIMAL", SQLITE_INTEGER, {10, 5}},
        {SQLiteBoolean, "BOOLEAN", SQLITE_INTEGER, {0, 0}},
        
        {SQLiteFloat, "FLOAT", SQLITE_FLOAT, {0, 0}},
        {SQLiteDouble, "DOUBLE", SQLITE_FLOAT, {0, 0}},
        {SQLiteReal, "REAL", SQLITE_FLOAT, {0, 0}},
        {SQLiteDoublePrecision, "DOUBLE PRECISION", SQLITE_FLOAT, {0, 0}},
        
        {SQLiteVarChar, "VARCHAR", SQLITE_TEXT, {255, 0}},
        {SQLiteDate, "DATE", SQLITE_TEXT, {0, 0}},
        {SQLiteDateTime, "DATETIME", SQLITE_TEXT, {0, 0}},
        {SQLiteText, "TEXT", SQLITE_TEXT, {0, 0}},
        {SQLiteCharacter, "CHARACTER", SQLITE_TEXT, {22, 0}},
        {SQLiteVaryingCharacter, "VARYING CHARACTER", SQLITE_TEXT, {255, 0}},
        {SQLiteNChar, "NCHAR", SQLITE_TEXT, {55, 0}},
        {SQLiteNativeCharacter, "NATIVE CHARACTER",  SQLITE_TEXT, {70, 0}},
        {SQLiteNVarChar, "NVARCHAR", SQLITE_TEXT, {100, 0}},
        {SQLiteClob, "CLOB", SQLITE_TEXT, {0, 0}},
        
        {SQLiteBlob, "BLOB", SQLITE_BLOB, {0, 0}},
        {SQLiteNoDatatypeSpecified, "VARIANT", SQLITE_BLOB, {0, 0}},
        
        {SQLiteVariant, "BLOB", SQLITE_BLOB, {0, 0}},
    };
    return _allSupportedDataTypeDescriptions;
}

// 通过类型名找到数据类型
+ (SQLiteDataTypeDescription)sqliteDataTypeDescriptionForDataTypeCName:(const char *)cName {
    SQLiteDataTypeDescription sqliteDataDescription = SQLiteNotSupportedDataType;
    if (cName != NULL) {
        NSUInteger cNameLength = strlen(cName);
        if (cNameLength < 3) {
            return sqliteDataDescription;
        }
        const SQLiteDataTypeDescription *supportedDataDescription = [self allSupportedDataTypeDescriptions];
        char *tmpNameStr = calloc((cNameLength + 1), sizeof(char));
        int m = 0, n = 0, j = 0;
        BOOL isFirstNumber = YES;
        BOOL breakLoop = NO;
        for (NSUInteger i = 0; i < cNameLength; i ++) {
            switch (cName[i]) {
                case ' ': // 当前是空格
                    // 移动到不是空格的位置
                    while (i++ < cNameLength && cName[i] == ' ') {
                    }
                    if (cName[i] == '\0') { // 如果到了末尾
                        breakLoop = YES;
                    }else if (cName[i] == '(') { // 如果是左括号
                        goto meet_data_size_branch;
                    }else{
                        if (j > 0) {
                            tmpNameStr[j++] = ' ';
                        }
                        tmpNameStr[j++] = toupper(cName[i]);
                        tmpNameStr[j] = '\0';
                    }
                    break;
                case '(': // 当前是左括号
                meet_data_size_branch:
                    while (i < cNameLength && !breakLoop) {
                        switch (cName[i + 1]) {
                            case '0':
                            case '1':
                            case '2':
                            case '3':
                            case '4':
                            case '5':
                            case '6':
                            case '7':
                            case '8':
                            case '9':
                                if (isFirstNumber) {
                                    m = m * 10 + cName[i + 1] - 48;
                                }else{
                                    n = n * 10 + cName[i + 1] - 48;
                                }
                                break;
                            case ',':
                                isFirstNumber = NO;
                                break;
                            case ')':
                            case '\0':
                                breakLoop = YES;
                                break;
                            default:
                                break;
                        }
                        i ++;
                    }
                    break;
                case '\0':
                    //tmpNameStr[i] = '\0';
                    breakLoop = YES;
                    break;
                default:
                    tmpNameStr[j ++] = toupper(cName[i]);
                    tmpNameStr[j] = '\0';
                    break;
            }
            if (breakLoop) {
                break;
            }
        }
        for (NSInteger i = 0; i < SQLiteNotSupported; i ++) {
            if (strcmp(tmpNameStr, supportedDataDescription[i].typeName) == 0) {
                sqliteDataDescription = supportedDataDescription[i];
                sqliteDataDescription.size.m = m;
                sqliteDataDescription.size.n = n;
                break;
            }
        }
        free(tmpNameStr);
    }
    return sqliteDataDescription;
}

+ (SQLiteDataTypeDescription)sqliteDataTypeDescriptionForDataTypeName:(NSString *)name {
    return [self sqliteDataTypeDescriptionForDataTypeCName:name.UTF8String];
}

+ (SQLiteDataTypeDescription)sqliteDataTypeDescriptionForDataType:(SQLiteDataType)dataType {
    SQLiteDataTypeDescription dataTypeDescrition = SQLiteNotSupportedDataType;
    if (dataType < SQLiteNotSupported) {
        const SQLiteDataTypeDescription *supportedDataDescription = [self allSupportedDataTypeDescriptions];
        dataTypeDescrition = supportedDataDescription[dataType];
        if (dataTypeDescrition.type == dataType) {
            return dataTypeDescrition;
        }
    }
    return dataTypeDescrition;
}

// 字符串转数据类型
+ (SQLiteDataType)sqliteDataTypeForDataTypeName:(NSString *)string {
    return [self sqliteDataTypeDescriptionForDataTypeName:string].type;
}

// 数据类型转字符串
+ (NSString *)sqliteDataTypeNameForDataType:(SQLiteDataType)dataType withDataSize:(SQLiteDataSize)dataSize {
    const SQLiteDataTypeDescription *supportedDataDescription = [self allSupportedDataTypeDescriptions];
    SQLiteDataTypeDescription sqliteDataDescription = SQLiteNotSupportedDataType;
    for (NSInteger i = 0; i < SQLiteNotSupported; i ++) {
        if (dataType == supportedDataDescription[i].type) {
            sqliteDataDescription = supportedDataDescription[i];
            break;
        }
    }
    
    if (dataSize.m == 0 && dataSize.n == 0) {
        return [NSString stringWithUTF8String:sqliteDataDescription.typeName];
    }else{
        if (dataSize.m > sqliteDataDescription.size.m) {
            dataSize.m = sqliteDataDescription.size.m;
        }
        if (dataSize.n > sqliteDataDescription.size.n) {
            dataSize.n = sqliteDataDescription.size.n;
        }
        return [NSString stringWithFormat:@"%@(%ld,%ld)", [NSString stringWithUTF8String:sqliteDataDescription.typeName], dataSize.m, dataSize.n];
    }
}

// 由数据类型获取存储类型
+ (NSInteger)sqliteDataStorageTypeForDataType:(SQLiteDataType)dataType {
    const SQLiteDataTypeDescription *supportedDataDescription = [self allSupportedDataTypeDescriptions];
    SQLiteDataTypeDescription sqliteDataDescription = SQLiteNotSupportedDataType;
    for (NSInteger i = 0; i < SQLiteNotSupported; i ++) {
        if (dataType == supportedDataDescription[i].type) {
            sqliteDataDescription = supportedDataDescription[i];
            break;
        }
    }
    return sqliteDataDescription.storageType;
}

+ (NSString *)descriptionForResultCode:(NSUInteger)resultCode {
    switch (resultCode) {
        case SQLITE_OK:
            return @"Successful result";
            break;
            
        case SQLITE_ERROR:
            return @"SQL error or missing database";
            break;
            
        case SQLITE_INTERNAL:
            return @"Internal logic error in SQLite";
            break;
            
        case SQLITE_PERM:
            return @"Access permission denied";
            break;
            
        case SQLITE_ABORT:
            return @"Callback routine requested an abort";
            break;
            
        case SQLITE_BUSY:
            return @"The database file is locked";
            break;
            
        case SQLITE_LOCKED:
            return @"A table in the database is locked";
            break;
            
        case SQLITE_NOMEM:
            return @"A malloc() failed";
            break;
            
        case SQLITE_READONLY:
            return @"Attempt to write a readonly database";
            break;
            
        case SQLITE_INTERRUPT:
            return @"Operation terminated by sqlite3_interrupt()";
            break;
            
        case SQLITE_IOERR:
            return @"Some kind of disk I/O error occurred";
            break;
            
        case SQLITE_CORRUPT:
            return @"The database disk image is malformed";
            break;
            
        case SQLITE_NOTFOUND:
            return @"Unknown opcode in sqlite3_file_control()";
            break;
            
        case SQLITE_FULL:
            return @"Insertion failed because database is full";
            break;
            
        case SQLITE_CANTOPEN:
            return @"Unable to open the database file";
            break;
            
        case SQLITE_PROTOCOL:
            return @"Database lock protocol error";
            break;
            
        case SQLITE_EMPTY:
            return @"Database is empty";
            break;
            
        case SQLITE_SCHEMA:
            return @"The database schema changed";
            break;
            
        case SQLITE_TOOBIG:
            return @"String or BLOB exceeds size limit";
            break;
            
        case SQLITE_CONSTRAINT:
            return @"Abort due to constraint violation";
            break;
            
        case SQLITE_MISMATCH:
            return @"Data type mismatch";
            break;
            
        case SQLITE_MISUSE:
            return @"Library used incorrectly";
            break;
            
        case SQLITE_NOLFS:
            return @"Uses OS features not supported on host";
            break;
            
        case SQLITE_AUTH:
            return @"Authorization denied";
            break;
            
        case SQLITE_FORMAT:
            return @"Auxiliary database format error";
            break;
            
        case SQLITE_RANGE:
            return @"2nd parameter to sqlite3_bind out of range";
            break;
            
        case SQLITE_NOTADB:
            return @"File opened that is not a database file";
            break;
            
        case SQLITE_NOTICE:
            return @"Notifications from sqlite3_log()";
            break;
            
        case SQLITE_WARNING:
            return @"Warnings from sqlite3_log()";
            break;
            
        case SQLITE_ROW:
            return @"sqlite3_step() has another row ready";
            break;
            
        case SQLITE_DONE:
            return @"sqlite3_step() has finished executing";
            break;
            
        default:
            return @"Unknown result code";
            break;
    }
}

@end





