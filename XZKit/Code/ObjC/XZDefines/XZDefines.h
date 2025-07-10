//
//  XZDefines.h
//  XZKit
//
//  Created by Xezun on 2021/2/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMacros.h>
#import <XZKit/XZDefer.h>
#import <XZKit/XZEmpty.h>
#import <XZKit/XZRuntime.h>
#import <XZKit/XZUtils.h>
#else
#import "XZMacros.h"
#import "XZDefer.h"
#import "XZEmpty.h"
#import "XZRuntime.h"
#import "XZUtils.h"
#endif

/**
 编程路漫漫兮，吾将上下而求索。
 
 关于 GCD 的一点笔记。
 1. 如何判断当前队列？
 答：先设置队列标识符 setSpecific(key:value:)，然后使用静态方法 getSpecific(key:) 获取当前队列的标识符，通过比较标识符来判断是否为同一队列。
 
 2. 线程死锁相关。
 答：根据 GCD 层级结构，不同队列可能使用的是同一线程。这么设计大概是为了最大限度的利用资源，所有自定义队列，都由是内置队列的子队列，而这些子
 队列则按照规则使用线程池。线程在执行任务时，如果要与其它线程交互，就有可能造成等待的情况，而一旦出现互相等待的情况，死锁就发生了。死锁不仅可
 以发生在同队列，也可能发生在两个不同的队列，甚至是并发队列或者两个几乎没有业务逻辑的队列上，因为从 GCD 源代码和层级结构上，所有自定义队列默
 认都是全局队列的子队列。
 
 3. GCD 层级结构(https://www.objc.io/issues/2-concurrency/concurrency-apis-and-pitfalls/)。
 答：GCD 默认创建了五个根队列，主队列和四个优先级不同的全局队列，而所有自定义队列，都是或间接是根队列的子队列，所有任务都将归纳到根队列上执行。
 为什么在根队列（全局队列）上执行栅栏任务无效，可以理解为根队列的任务由线程池调用，而子队列任务由根队列安排的。
 
 */
