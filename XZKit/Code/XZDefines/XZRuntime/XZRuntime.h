//
//  XZRuntime.h
//  XZKit
//
//  Created by Xezun on 2021/5/7.
//

#import <Foundation/Foundation.h>
@import ObjectiveC;

// 命名规则：
// 所有函数默认作用于实例方法、属性、变量。

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 基础方法

/// 获取类自身的指定实例方法，不计算从父类继承的方法。
///
/// - Note: 为提高性能，使用本方法前可先检测类 aClass 是否能响应 target 方法。
/// 
/// ```objc
/// if ([aClass instancesRespondToSelector:target]) {
///     Method method = xz_objc_class_getMethod(aClass, target);
///     if (method == nil) {
///         NSLog(@"方法 %s 从父类继承而来", target);
///     }
/// }
/// ```
///
/// - Parameters:
///   - aClass: 待获取方法的类
///   - selector: 待获取方法
/// - Returns: 方法的 Method 对象
FOUNDATION_EXPORT Method _Nullable xz_objc_class_getMethod(Class const aClass, SEL const selector);

/// 遍历类的实例方法，不包括父类的方法。
///
/// - Parameters:
///   - aClass: 类
///   - enumerator: 遍历所用的 block 块，返回 NO 遍历终止
FOUNDATION_EXPORT void xz_objc_class_enumerateMethods(Class aClass, BOOL (^enumerator)(Method method, NSInteger index));

/// 遍历类的实例变量，不包括父类。
///
/// - Parameters:
///   - aClass: 类
///   - enumerator: 遍历所用的 block 块，返回 NO 遍历终止
FOUNDATION_EXPORT void xz_objc_class_enumerateVariables(Class aClass, BOOL (^enumerator)(Ivar ivar));

/// 获取类的实例变量名。
///
/// - Parameters:
///   - aClass: 类
FOUNDATION_EXPORT NSArray<NSString *> * _Nullable xz_objc_class_getVariableNames(Class aClass);

/// 交换类的实例方法的实现，方法可能是父类的方法。
///
/// - Parameters:
///   - aClass: 类
///   - selector1: 交换实现的实例方法1
///   - selector2: 交换实现的实例方法2
FOUNDATION_EXPORT void xz_objc_class_exchangeMethods(Class aClass, SEL selector1, SEL selector2);

/// 给 aClass 添加 selector 方法。
///
/// > `super` 是编译器指令，编译器直接使用“方法所在类”的类名来获取超类，不具动态性，把带 `super` 的方法复制给其它类，方法`super`仍然指向编译时的类。
///
/// 在运行时，给类`aClass`动态添加方法时，如果需要向超类发送消息，可以向下面这样。
///
/// ```objc
/// struct objc_super super = {
///     .receiver = self,
///     .super_class = class_getSuperclass(aClass)
/// };
/// ((void (*)(struct objc_super *, SEL, BOOL))objc_msgSendSuper)(&super, @selector(viewWillAppear:), animated);
/// ```
///
/// - Parameters:
///   - aClass: 待添加方法的类。
///   - selector: 待添加方法的名称。
///   - source: 提供方法 IMP 的类，如果为 nil 值，则使用自身，且不能与 creation 同时为 nil 值。
///   - creation: 如果待添加的方法为新方法时，将选择此方法的 IMP 为新方法的 IMP 使用，如果为空，则使用与待添加方法相同名称的方法。
///   - override: 如果待添加的方法已由父类实现，将选择此方法的 IMP 为新方法的 IMP 使用。
///   - exchange: 如果待添加的方法已由自身实现，那么想将此方法复制到 aClass 上，然后再交换 IMP 使用；如果 aClass 已有 exchange 方法，则添加方法失败。
/// - Returns: 返回 YES 表示添加成功
FOUNDATION_EXPORT BOOL xz_objc_class_addMethod(Class aClass, SEL selector, Class _Nullable source, SEL _Nullable creation, SEL _Nullable override, SEL _Nullable exchange);

/// 获取 aClass 实例方法的 type-encoding 字符串。
///
/// - Parameters:
///   - aClass: 获取的对象的类。
///   - selector: 获取的方法名。
/// - Returns: 方法的编码
FOUNDATION_EXPORT const char * _Nullable xz_objc_class_getMethodTypeEncoding(Class aClass, SEL selector);

/// 以块函数为方法的实现，给对象添加方法。
///
/// 添加方法的示例代码。
///
/// ```objc
/// // 以给 FooBar 添加 -sayHello: 方法为例。
/// - (NSString *)sayHello:(NSString *)name {
///     return [NSString stringWithFormat:@"Hello %@!", name];
/// }
///
/// // 1、获取方法签名。可以先在任意类上定义一个待添加的方法，用于获取 type-encoding ，当然如果熟悉编码规则，也可以手写。
/// const char * const encoding = xz_objc_class_getMethodTypeEncoding([Foobar class], @selector(sayHello:));
///
/// // 2、调用当前函数。
/// Class const aClass = [Foobar class];
/// xz_objc_class_addMethodWithBlock(aClass, @selector(sayHello:), encoding, ^NSString *(Foobar *self, NSString *name) {
///     return [NSString stringWithFormat:@"Hello %@!", name];
/// }, ^NSString *(Foobar *self, NSString *name) {
///     struct objc_super super = {
///         .receiver = self,
///         .super_class = class_getSuperclass(aClass) // 使用 aClass 而不能是 self.class
///     };
///     // 调用父类方法，相当于 [super sayHello:name]
///     NSString *word = ((NSString *(*)(struct objc_super *, SEL, NSString *))objc_msgSendSuper)(&super, @selector(sayHello:), name);
///     return [NSString stringWithFormat:@"override %@", word];
/// }, ^id _Nonnull(SEL _Nonnull selector) {
///     return ^NSString *(Foobar *self, NSString *name) {
///         // 调用原始方法，相当于 [self exchange_sayHello:name]
///         NSString *word = ((NSString *(*)(Foobar *, SEL, NSString *))objc_msgSend)(self, selector, name);
///         return [NSString stringWithFormat:@"exchange %@", word];
///     };
/// });
/// ```
///
/// 本函数使用 `imp_implementationWithBlock(block)` 函数将块函数转化为方法实现。
///
/// ```obj
/// // 准备添加的方法。
/// - (id)foo:(id)foo bar:(int)bar {
///     return foo;
/// }
///
/// // 那么块函数的形式如下。
/// id (^block)(FooBar *, id, int) = ^id(FooBar *self, id foo, int bar) {
///     return foo;
/// }
/// ```
///
/// 在 Swift 中，必须使用 `@convention(block)` 将闭包转换为 `block` 才能作为方法的 IMP 使用。
///
/// 但是由于 Swift 不支持 `objc_msgSend` 和 `objc_msgSendSuper` 函数，我们需要将调用父类和调用原始方法的逻辑使用 OC 实现。
///
/// ```objc
/// NSString *xz_msgSendSuper_sayHello(Foo *receiver, NSString *name) NS_SWIFT_NAME(xz_msgSendSuper(_:sayHello:)) {
///     struct objc_super super = {
///         .receiver = receiver,
///         .super_class = class_getSuperclass([Foobar class])
///     };
///     return ((NSString *(*)(struct objc_super *, SEL, NSString *))objc_msgSendSuper)(&super, @selector(sayHello:), name);
/// }
///
/// NSString *xz_msgSend_sayHello(Foo *receiver, SEL selector, NSString *name) NS_SWIFT_NAME(xz_msgSend(_:_:sayHello:))  {
///     return ((NSString *(*)(Foo *, SEL, NSString *))objc_msgSend)(receiver, @selector(sayHello:), name);
/// }
/// ```
///
/// ```swift
/// // 定一个类型，方便书写代码
/// typealias MethodBlock = @convention(block) (Foo, String) -> String
/// // 在 Bar 上定义了一个我们要添加的方法，以便获取方法的 type-encoding
/// let selector = #selector(Bar.sayHello(_:))
/// let encoding = xz_objc_class_getMethodTypeEncoding(Bar.self, selector)
/// // 在 block 中，使用 self 作为实例对象的参数名，可以屏蔽外部的 self
/// let creation: MethodBlock = { `self`, name in
///     return "Hello \(name)";
/// }
/// // 重写方法
/// let override: MethodBlock = { `self`, name in
///     let word = xz_msgSendSuper(self, sayHello: name);
///     return "override \(word)";
/// }
/// // 交换方法：参数 selector 为动态添加的方法的方法名
/// let exchange = { (_ selector: Selector) in
///     let exchange: MethodBlock = { `self`, name in
///         let word = xz_msgSend(self, selector, sayHello: name)
///         return "exchange \(word)"
///     }
///     return exchange;
/// }
/// xz_objc_class_addMethodWithBlock(Foo.self, selector, encoding, creation, override, exchange)
/// ```
///
/// - Parameters:
///   - aClass: 要添加方法的类
///   - selector: 要添加的方法名
///   - encoding: 待添加方法的 type-encoding 编码，如果是已存在的方法，可以为 NULL 值
///   - creation: 如果待添加的方法未创建，则使用此块函数作为 IMP 新建方法，同时参数 encoding 必须提供
///   - override: 如果待添加的方法已由超类实现，则使用此块函数作为 IMP 重写方法
///   - exchange: 如果待添加的方法已由自身实现，则使用此块函数**返回的块函数**为 IMP 构造方法，并与原方法进行交换；新构造的方法，作为此参数块函数的参数
/// - Returns: 是否添加成功
FOUNDATION_EXPORT BOOL xz_objc_class_addMethodWithBlock(Class aClass, SEL selector, const char * _Nullable encoding, id _Nullable creation, id _Nullable override, id (^ _Nullable exchange)(SEL selector));

#pragma mark - 创建类

/// 构造 Class 的块函数。
/// - Parameters:
///   - newClass: 构造过程中的 Class 对象，只可用来添加变量、方法，不可直接实例化
typedef void (^XZRuntimeCreateClassBlock)(Class newClass);

/// 派生子类或创建新类，如果已存在，则返回 Nil 。
///
/// - Parameters:
///   - superClass: 新类的超类，如果为 Nil 则表示创建基类
///   - name: 新类的类名
///   - block: 给新类添加实例变量的操作必须在此block中执行
FOUNDATION_EXPORT Class _Nullable xz_objc_createClassWithName(Class _Nullable superClass, NSString *name, NS_NOESCAPE XZRuntimeCreateClassBlock _Nullable block);

/// 创建类，不指定名字。
///
/// - Note: 子类命名格式为 `XZKit.SuperClassName.<number>` 即每次调用此函数，都会生成一个新的类。
///
/// - Parameters:
///   - superClass: 新类的超类
///   - block: 给新类添加实例变量的操作必须在此block中执行
FOUNDATION_EXPORT Class xz_objc_createClass(Class superClass, NS_NOESCAPE XZRuntimeCreateClassBlock _Nullable block);



#pragma mark - 添加方法


/// 复制方法：将类 source 的方法 sourceSelector 复制为类 target 的 targetSelector 方法。
///
/// 如果 target 自身已存在 targetSelector 方法，则不复制，返回 NO 值。
///
/// 参数 target 和 targetSelector 不能同时为 nil 值，否则返回 NO 值。
///
/// - Parameters:
///   - source: 被复制方法的类
///   - sourceSelector: 被复制方法的方法名
///   - target: 待添加方法的类，如果为 nil 则表示使用 source
///   - targetSelector: 待添加的方法名，为 nil 则使用 sourceSelector
/// - Returns: 是否复制成功
FOUNDATION_EXPORT BOOL xz_objc_class_copyMethod(Class source, SEL sourceSelector, Class _Nullable target, SEL _Nullable targetSelector);

/// 将 source 自身的所有实例方法都复制到 target 上，不包括 super 的方法。
///
/// - Note: 复制会跳过 target 自身存在的同名方法，同样不包括 super 的方法。
///
/// - Parameters:
///   - source: 被复制方法的类
///   - target: 待添加方法的类
/// - Returns: 被成功复制的方法的数量
FOUNDATION_EXPORT NSInteger xz_objc_class_copyMethods(Class source, Class target);


/// 获取协议中的所有实例方法 SEL 列表，包括协议继承的协议，但不包括 NSObject 协议。
/// - Parameter aProtocol: 协议
FOUNDATION_EXPORT NSHashTable *xz_objc_protocol_getInstanceMethods(Protocol *aProtocol);

/// 获取 aClass 已实现的协议方法的列表，包括父类实现的。
/// - Parameters:
///   - aClass: 类
///   - protocolMethods: 协议方法 SEL 列表
FOUNDATION_EXPORT NSHashTable *xz_objc_class_getImplementedProtocolMethods(Class aClass, NSHashTable *protocolMethods);

#pragma mark - 通用消息发送

// v => void
// o => id/object
// b => BOOL
// i => NSInteger
// rect => CGRect

// 在 xz_objc_msgSendSuper 方法中，除非没有子类，否则参数 receiverClass 不可以通过 receiver.class 动态获取，而应该是确定类型，否则会造成死循环。
// 比如假如像下面这样实现的话
// @implementation Animal
// - (void)foobar {
//     xz_objc_msgSendSuper_void(self, self.class, @selector(foobar)); // 应该使用 [Human class] 而不是 self.class
// }
// @end
// @interface Human : Animal
// @end
// 那么子类在调用 -foobar 方法时，就会造成死循环。
// Human *human = [[Human alloc] init];
// [human foobar];
// 原因是 self.class 返回值始终是 Human 类，因此获取的 superclass 始终是 Animal 类。
// 即在调用方法 [human foobar] 中，调用 xz_objc_msgSendSuper 函数时，传入的 self.class 实际造成 Animal 调用自身。

FOUNDATION_EXPORT void xz_objc_msgSendSuper_void_id(id receiver, Class receiverClass, SEL selector, id _Nullable param1) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:v:o:));
FOUNDATION_EXPORT void xz_objc_msgSend_void_id(id receiver, SEL selector, id _Nullable param1) NS_SWIFT_NAME(xz_objc_msgSend(_:v:o:));

FOUNDATION_EXPORT void xz_objc_msgSendSuper_void_id_bool(id receiver, Class receiverClass, SEL selector, id _Nullable param1, BOOL param2) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:v:o:b:));
FOUNDATION_EXPORT void xz_objc_msgSend_void_id_bool(id receiver, SEL selector, id _Nullable param1, BOOL param2) NS_SWIFT_NAME(xz_objc_msgSend(_:v:o:b:));

FOUNDATION_EXPORT id _Nullable xz_objc_msgSendSuper_id_bool(id receiver, Class receiverClass, SEL selector, BOOL param1) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:o:b:));
FOUNDATION_EXPORT id _Nullable xz_objc_msgSend_id_bool(id receiver, SEL selector, BOOL param1) NS_SWIFT_NAME(xz_objc_msgSend(_:o:b:));

FOUNDATION_EXPORT id _Nullable xz_objc_msgSendSuper_id_id_bool(id receiver, Class receiverClass, SEL selector, id _Nullable param1, BOOL param2) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:o:o:b:));
FOUNDATION_EXPORT id _Nullable xz_objc_msgSend_id_id_bool(id receiver, SEL selector, id _Nullable param1, BOOL param2) NS_SWIFT_NAME(xz_objc_msgSend(_:o:o:b:));

FOUNDATION_EXPORT void xz_objc_msgSendSuper_void_bool(id receiver, Class receiverClass, SEL selector, BOOL param1) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:v:b:));
FOUNDATION_EXPORT void xz_objc_msgSend_void_bool(id receiver, SEL selector, BOOL param1) NS_SWIFT_NAME(xz_objc_msgSend(_:v:b:));

FOUNDATION_EXPORT id _Nullable xz_objc_msgSendSuper_id_id_integer_id_id(id receiver, Class receiverClass, SEL selector, id _Nullable param1, NSInteger param2, id _Nullable param3, id _Nullable param4) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:o:o:i:o:o:));
FOUNDATION_EXPORT id _Nullable xz_objc_msgSend_id_id_integer_id_id(id receiver, SEL selector, id _Nullable param1, NSInteger param2, id _Nullable param3, id _Nullable param4) NS_SWIFT_NAME(xz_objc_msgSend(_:o:o:i:o:o:));

FOUNDATION_EXPORT id _Nullable xz_objc_msgSendSuper_id_id_id(id receiver, Class receiverClass, SEL selector, id _Nullable param1, id _Nullable param2) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:o:o:o:));
FOUNDATION_EXPORT id _Nullable xz_objc_msgSend_id_id_id(id receiver, SEL selector, id _Nullable param1, id _Nullable param2) NS_SWIFT_NAME(xz_objc_msgSend(_:o:o:o:));

FOUNDATION_EXPORT CGRect xz_objc_msgSendSuper_rect(id receiver, Class receiverClass, SEL selector) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:rect:));
FOUNDATION_EXPORT CGRect xz_objc_msgSend_rect(id receiver, SEL selector) NS_SWIFT_NAME(xz_objc_msgSend(_:rect:));

FOUNDATION_EXPORT void xz_objc_msgSendSuper_void_rect(id receiver, Class receiverClass, SEL selector, CGRect param1) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:v:rect:));
FOUNDATION_EXPORT void xz_objc_msgSend_void_rect(id receiver, SEL selector, CGRect param1) NS_SWIFT_NAME(xz_objc_msgSend(_:v:rect:));

FOUNDATION_EXPORT BOOL xz_objc_msgSendSuper_bool(id receiver, Class receiverClass, SEL selector) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:b:));
FOUNDATION_EXPORT BOOL xz_objc_msgSend_bool(id receiver, SEL selector) NS_SWIFT_NAME(xz_objc_msgSend(_:b:));

FOUNDATION_EXPORT void xz_objc_msgSendSuper_void(id receiver, Class receiverClass, SEL selector) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:v:));
FOUNDATION_EXPORT void xz_objc_msgSend_void(id receiver, SEL selector) NS_SWIFT_NAME(xz_objc_msgSend(_:v:));

FOUNDATION_EXPORT void xz_objc_msgSendSuper_void_id_integer(id receiver, Class receiverClass, SEL selector, id _Nullable param1, NSInteger param2) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:v:o:i:));
FOUNDATION_EXPORT void xz_objc_msgSend_void_id_integer(id receiver, SEL selector, id _Nullable param1, NSInteger param2) NS_SWIFT_NAME(xz_objc_msgSend(_:v:o:i:));

FOUNDATION_EXPORT void xz_objc_msgSendSuper_void_id_id(id receiver, Class receiverClass, SEL selector, id _Nullable param1, id _Nullable param2) NS_SWIFT_NAME(xz_objc_msgSendSuper(_:_:v:o:o:));
FOUNDATION_EXPORT void xz_objc_msgSend_void_id_id(id receiver, SEL selector, id _Nullable param1, id _Nullable param2) NS_SWIFT_NAME(xz_objc_msgSend(_:v:o:o:));

NS_ASSUME_NONNULL_END
