//
//  SQLiteRecordset.h
//  SQLiteDB
//
//  Created by mlibai on 15/8/15.
//  Copyright (c) 2015年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQLiteConnection;
@class SQLiteField;

/**
 *  SQLite 记录集类
 */
@interface SQLiteRecordset : NSObject

/**
 *  记录集使用的数据库连接，只能在记录集关闭的时候设置
 */
@property (nonatomic, strong) SQLiteConnection *connection;

/**
 *  属性为 YES 时，可以在查询数据的同时更新数据库
 *  只有在打开记录集之前设置该属性才会生效，如果记录集已打开，下次打开生效
 *  因为只有在基本表上才能直接更改，对于视图该属性不会生效
 */
@property (nonatomic, assign) BOOL writable;

/**
 *  返回当前记录集中记录的数量，实际是通过 SQL 语句查询的结果
 *  对于只读记录集，该值是首次调用时的结果
 *  对于可写记录集，该值是记录集打开时的结果
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 *  当前查询结果包含的所有字段，每个字段是 SQLiteField 对象
 *  SQLiteField 包含 name、dataType、index 等属性
 */
@property (nonatomic, strong, readonly) NSArray *allFields;

/**
 *  由 SQLiteField 对象组成的 c 数组，使用时需注意不能越界
 *  这是内部指针，提供一种通过列序号取值的方式，如取出第 i 列
 *  的值：rs.fields[i].value
 */
@property (nonatomic, readonly) SQLiteField *const __unsafe_unretained* fields;

/**
 *  YES 表示记录集指针在最后一条记录之后
 */
@property (nonatomic, assign, readonly) BOOL eof;

/**
 *  YES 表示记录集指针在第一条记录之前
 */
@property (nonatomic, assign, readonly) BOOL bof;

/**
 *  YES 表示记录集正处于打开状态
 */
@property (nonatomic, assign, readonly) BOOL status;

/**
 *  当前执行的SQL语句，即用户输入的 SQL 语句
 */
@property (nonatomic, copy, readonly) NSString *sql;

/**
 *  对当前记录集进行分页，限定当前记录集中记录的个数
 *  只有当记录集处于关闭时，对此设置才会生效
 */
@property (nonatomic, assign) NSUInteger pageSize;

/**
 *  对于分页的记录集，指定记录集指向的页数（从 0 开始编号）
 *  只有当记录集处于关闭时，对此设置才会生效
 */
@property (nonatomic, assign) NSUInteger page;

/**
 *  记录集指针在记录集中的位置
 *  0 时，属性 bof = YES；NSNotFound 时，属性 eof = YES
 */
@property (nonatomic, assign, readonly) NSUInteger cursorLocation;

/**
 *  便利构造器、初始化方法、指定初始化方法
 */
+ (instancetype)recordSetWithConnection:(SQLiteConnection *)connection;
+ (instancetype)recordSetWithConnection:(SQLiteConnection *)connection pageSize:(NSUInteger)pageSize page:(NSUInteger)page;
- (instancetype)initWithConnection:(SQLiteConnection *)connection;
- (instancetype)initWithConnection:(SQLiteConnection *)connection pageSize:(NSUInteger)pageSize page:(NSUInteger)page;

/**
 *  根据指定的SQL语句打开记录集，打开记录集之前，请确保数据库连接已经设置并打开
 *  这里的 writable 属性，只在本次查询生效
 */
- (BOOL)openWithSqlString:(NSString *)sqlString;
- (BOOL)openWithSqlFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
- (BOOL)openWithSqlString:(NSString *)sqlString writable:(BOOL)writable;
- (BOOL)openWithWritable:(BOOL)writable sqlFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);

/**
 *  关闭记录集，不再使用记录集一定要调用该方法关闭，释放内存，否则可能会造成内存泄露
 *
 *  @return 是否成功关闭
 */
- (BOOL)close;

/**
 *  移动记录集指针的方法
 *  对于 SQLITE 数据库来说，这只是一个虚拟的概念，并不存在这样的指针
 *  记录集指向的记录，可以用 valueForField 取出，或通过 setValue:forField: 更新值，或通过 remove 方法删除该记录
 *  另外 movePrevious、moveLast 方法是通过前面两个方法实现的，不建议频繁调用
 */
- (void)moveNext;
- (void)moveFirst;
- (void)movePrevious;
- (void)moveLast;
- (void)addNew; // 调用此方法后，记录集指针指向新行，此时field.value=nil，field.originValue是原先行的值
- (void)delete; // delete 是 C++ 关键字（=free）
- (BOOL)update; // 应用对数据库的插入、删除、修改等操作

/**
 *  获取字段内容，通过下面的方法、字典键值取值法、或通过 sqliteFields 属性 或 fields 属性都可以取值
 *  字段区分大小写，与查询语句所列字段名大小写一致，如果是 * 通配符，与创建数据库时的 SQL 语句里的大小写一致
 */
// 指定的取值方法
- (id)valueForField:(NSString *)field;

// 下面三个方法实质是调用上面这个方法，只为方便使用如KVC之类的方法，key字段可以任意，实际没有返回为nil
- (id)valueForKey:(NSString *)key;
- (id)objectForKey:(NSString *)aKey;

// 这个方法提供了类似字典取值的方法，如：id someVar = rs[@"field_name"]，取出记录集指针所在行，列名为 field_name 的值
- (id)objectForKeyedSubscript:(NSString *)aKey;

// 这个方法提供了类似数组取值的方法，如：id someVar = rs[index]，取出记录集指针所在行，第 index 列的值
// 这个方法访问的是内部数组，所以下标值不能越界（超过查询结果的列数）。
- (id)objectAtIndexedSubscript:(NSUInteger)index NS_AVAILABLE(10_8, 6_0);

/**
 *  取值：
 *  所有数值返回的都是NSNumber对象，字符串、字符，返回的都是NSString对象。
 *  对于日期类型，如果储存的是数值，将以按照1970过去的秒数返回NSDate对象，若是字符串，尝试"yyyy-MM-dd HH:mm:ss"或"yyyy-MM-dd"格式转换成NSDate对象，若转换失败，返回从数据库取出的值。
 *  存储类型                声明类型                取出类型                        说明：如果直接打印NSDate对象，输出内容将比实际时间少8小时，需要用NSDateFormatter按照格式转换
    SQLiteInteger       SQLiteDate              NSDate                          把取出的的值作为自1970过去的秒数，返回NSDate
    SQLiteInteger       SQLiteDatetime          NSDate                          同上
    SQLiteText          SQLiteDate              NSDate或NSString                尝试以"yyyy-MM-dd"格式转换成NSDate，转换失败，原样返回。
    SQLiteText          SQLiteDatetime          NSDate或NSString                尝试以"yyyy-MM-dd HH:mm:ss"格式转换成NSDate，转换失败，原样返回。
    SQLiteBlob          SQLiteDate              不处理直接返回
    SQLiteBlob          SQLiteDatetime          不处理直接返回
 *  赋值：
 *  若字段是日期类型，将尝试把数据转换成"yyyy-MM-dd HH:mm:ss"或"yyyy-MM-dd"格式的字符存入数据库。
 *  输入类型        目标类型                存储类型                说明
    NSNumber    SQLiteDate              "yyyy-MM-dd"            NSNumber的值作为自1970过去的秒数计算
    NSNumber    SQLiteDatetime          "yyyy-MM-dd HH:mm:ss"   同上
    NSString    SQLiteDate              原样存入
    NSString    SQLiteDatetime          原样存入
    NSDate      SQLiteDate              "yyyy-MM-dd"            直接转换
    NSDate      SQLiteDatetime          "yyyy-MM-dd HH:mm:ss"   直接转换
 *  @return
 */

/**
 *  当属性 writable = YES 时，调用以下方法将值绑定到字段上
 *  需注意，要将值写入到数据库，需在绑定值后调用 update 方法
 */
// 指定的值绑定方法
- (void)setValue:(id)value forField:(NSString *)field;

// 为方便使用KVC之类的方法
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)setObject:(id)anObject forKey:(NSString *)aKey;

// 下面这个方法提供了类似字典赋值的方法，如：rs[@"field_name"] = someValue，将列名为 field_name 的列绑定值 someValue。
- (void)setObject:(id)anObject forKeyedSubscript:(NSString *)aKey;

// 下面这个方法提供了类似数组赋值的方法，如：rs[index] = someValue，将第 index 列绑定值 someValue。
// 这个方法访问的是内部数组，所以下标值不能越界（超过查询结果的列数）。
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index NS_AVAILABLE(10_8, 6_0);

@end