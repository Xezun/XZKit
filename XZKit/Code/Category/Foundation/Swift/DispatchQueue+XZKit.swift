//
//  DispatchQueue.swift
//  XZKit
//
//  Created by mlibai on 2018/7/6.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import Foundation


/**
 “编程路漫漫兮，吾将上下而求索”，敬 GCD 的设计者们。
 
 了解的越多，越发现自己的无知。平时以为很简单的 GCD 远不是想象中的那么简单，不论设计者当初的意图是什么，
 企图用一个简单的方法来一劳永逸的安全的使用 GCD 的愿望算是破灭了。也就是说线程安全，还是需要开发者在创建队列和使用队列时去注意，
 适用所有情况的方法怕是没那么简单就能写出来的。
 
 1. 如何判断当前队列？
 答：先设置队列标识符 setSpecific(key:value:)，然后使用静态方法 getSpecific(key:) 获取当前队列的标识符，通过比较标识符来判断是否为同一队列。
 
 2. 线程死锁相关。
 答：根据 GCD 层级结构，不同队列可能使用的是同一线程。这么设计大概是为了最大限度的利用资源，所有自定义队列，都由是内置队列的子队列，而这些子
 队列则按照规则使用线程池。线程在执行任务时，如果要与其它线程交互，就有可能造成等待的情况，而一旦出现互相等待的情况，死锁就发生了。死锁不仅可
 以发生在同队列，也可能发生在两个不同的队列，甚至是并发队列或者两个几乎没有业务逻辑的队列上，因为从 GCD 源代码和层级结构上，所有自定义队列默
 认都是全局队列的子队列。
 
 3. GCD 层级结构(https://www.objc.io/issues/2-concurrency/concurrency-apis-and-pitfalls/)。
 答：GCD 默认创建了五个根队列，主队列和四个优先级不同的全局队列，而所有自定义队列，都是或间接是根队列的子队列，所有任务都将归纳到根队列上执行。
 根队列（全局队列）上执行栅栏任务无效，可以理解为根队列的任务由线程池调用，而子队列任务由根队列安排的。
 
 */

extension DispatchQueue {
    
    /// 在列队中，异步延迟执行操作。
    ///
    /// - Parameters:
    ///   - timeInterval: 延迟时间，单位：秒。
    ///   - operation: 待执行的操作。
    public func asyncAfter(_ duration: TimeInterval, execute operation: @escaping () -> Void) {
        self.asyncAfter(deadline: .now() + duration, execute: operation)
    }
    
    /// 相对于现在延迟一段时间执行。
    ///
    /// - Parameters:
    ///   - duration: 延时的时长。
    ///   - operation: 操作。
    ///   - flags: 默认 0 。
    ///   - qos: 默认 default 。
    public func asyncAfter(_ duration: TimeInterval, execute operation: @escaping () -> Void, flags: DispatchWorkItemFlags = .init(rawValue: 0), qos: DispatchQoS = DispatchQoS.default) {
        self.asyncAfter(deadline: .now() + duration, qos: qos, flags: flags, execute: operation)
    }
    
}
