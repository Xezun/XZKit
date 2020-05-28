//
//  APIManager.swift
//  XZKit
//
//  Created by Xezun on 2018/7/3.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import Foundation

public let NetworkingQueue = DispatchQueue(label: "com.xezun.XZKit.Networking", attributes: .concurrent)

public protocol APINetworking: AnyObject {
    
    /// 根据接口请求对象，创建并执行网络请求。
    /// - Note: 返回值为已经启动的 URLSessionDataTask 对象。
    /// - Note: 默认情况下，APIManager 不在主线程执行此方法。
    /// - Note: 回调需要在异步执行。
    /// - Parameters:
    ///   - request: 接口请求。
    ///   - progress: 请求进度回调。
    ///   - bytes: 已传送的数据量（字节）。
    ///   - totalBytes: 总共需传送的数据量（自己）。
    ///   - completion: 请求完成回调。
    ///   - data: 请求成功所获得的应答数据。
    ///   - error: 请求失败所产生的错误信息。
    /// - Returns: 执行网络请求的 Task 。
    /// - Throws: 创建网络请求时可能发生的错误。
    func dataTask(for request: APIRequest, progress: @escaping (_ bytes: Int64, _ totalBytes: Int64) -> Void, completion: @escaping (_ data: Any?, _ error: Error?) -> Void) throws -> URLSessionDataTask?
    
}

/// APIManager 是用于管理 APIRequest 的发送和收据接收。
/// - Note: 默认情况下，大部分操作都是在子线程上执行，将根据需要是否提供自定义队列的功能。
public protocol APIManager: APINetworking {
    
    /// 接口请求。
    associatedtype Request: APIRequest
    
    /// 接口响应。
    associatedtype Response: APIResponse where Response.Request == Request
    
    /// 发送接口请求。该操作是一个异步操作。
    /// - Parameter request: 接口请求对象。
    /// - Returns: 本次请求的标识符。
    @discardableResult func send(_ request: Request) -> APITask
    
    /// 当接口请求进度更新时，此方法会被调用，一般才此方法中转发代理事件。
    /// - Note: 默认情况下，该方法在子线程上执行。
    /// - Parameters:
    ///   - request: 接口请求对象。
    ///   - progress: 接口请求当前进度。
    func request(_ request: Request, didProcess progress: (bytes: Int64, totalBytes: Int64))
    
    /// 当接口请求收到服务器返回数据时，此方法会被调用，此方法一般用于验证数据基本结构，生成 APIResponse 对象。
    /// - Note: 默认情况下，该方法在子线程上执行。
    /// - Parameters:
    ///   - request: 接口请求对象。
    ///   - responseObject: 接口请求的原始数据。
    /// - Returns: 处理后的接口响应对象。
    /// - Throws: 处理接口数据的过程中可能产生的错误，此处产生的错误不会触发自动重试。
    func request(_ request: Request, didCollect responseObject: Any?) throws -> Response
    
    /// 当前接口已获得响应对象时，此方法会被调用。
    /// - Note: 该方法在主线程上执行。
    /// - Note: 只有当本方法执行完毕，等待的任务才会进入调度列队，所以，如果在此方法中执行一个新的请求，等待执行的任务可能继续处于等待中。
    /// - Parameters:
    ///   - request: 接口请求对象。
    ///   - response: 接口响应对象。
    func request(_ request: Request, didReceive response: Response)
    
    /// 当接口请求发生错误时，此方法会被调用。
    /// - Note: 自动重试的任务，可能不会触发此方法（除非主动停止）。
    /// - Note: 该方法在主线程上执行。
    /// - Parameters:
    ///   - request: 接口请求对象。
    ///   - error: 接口请求过程中的错误对象。
    func request(_ request: Request, didFailWithError error: Error)
    
    /// 当请求的 retryIfFailed 属性为 true 时，如果请求失败（包括被取消、因策略被忽略、网络错误、数据解析错误），APIManager 将通过此方法
    /// 来获取下次重试的时间间隔。如果此方法返回了 nil ，那么自动重试将停止，并触发错误回调。因此方法用于控制失败重试的频率，从而提高性能。
    /// - Note: 默认情况下，该方法在子线程上执行。
    /// - Parameters:
    ///   - request: APIRequest 对象。
    ///   - retriedTimes: 已重试的次数。
    ///   - error: 当前请求失败的 Error 对象。
    /// - Returns: 当前时间到下次重试的时间间隔，具体的重试时间同时受并发策略影响。
    func request(_ request: Request, timeIntervalForRetrying retriedTimes: Int, forFailingError error: Error) -> TimeInterval?
    
    
    var queue: DispatchQueue { get }
}


// MARK: - 功能部分

extension APIManager {
    
    /// 是否有正在进行、或等待中、或延迟执行的任务。
    public var isRunning: Bool {
        return self.apiTaskManager.isRunning
    }
    
    @discardableResult
    public func send(_ request: Request) -> APITask {
        return self.apiTaskManager.send(request)
    }
    
    /// 取消所有正在执行的接口请求，异步操作。
    /// - Note: 取消任务，将会收到 APIError.canceled 错误。
    /// - Note: 在 APIManager 销毁后，会自动取消所有正在进行的请求。
    public func cancelAllTasks() {
        NetworkingQueue.async(execute: {
            self.apiTaskManager.cancelAllUnsafe()
        })
    }
    
    /// APITaskManager 通过 APITask 管理了所有请求。因为是值绑定的关系，APITaskManager 生命周期比 APIManager 略长。
    /// 但是当 APIManager 销毁后，APITaskManager 也一定会销毁，并自动取消正在执行的任务。
    fileprivate var apiTaskManager: _APITaskManager<Self> {
        if let wrapper = objc_getAssociatedObject(self, &AssociationKey.apiTaskManager) as? _APITaskManager<Self> {
            return wrapper
        }
        // 如果当前操作是在主线程中执行，那么同步操作会导致主线程进入等待状态；
        // 如果使用串行或者栅栏并发队列，那么如果这个时候，队列中正在执行的任务正好要在主线程中同步执行，
        // 那么就会导致并发队列进入等待状态；从而导致主线程与线程互相等待，即死锁。
        // 所以下面的操作要使用线程锁，而非串行队列。
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if let wrapper = objc_getAssociatedObject(self, &AssociationKey.apiTaskManager) as? _APITaskManager<Self> {
            return wrapper
        }
        let wrapper = _APITaskManager.init(for: self)
        objc_setAssociatedObject(self, &AssociationKey.apiTaskManager, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return wrapper
    }
    
}



// MARK: - 支持

/// 管理了 APIManger 的请求任务和多线程处理。
/// - Note: APITaskManager 实际上就是 APIManager ，管理了 APITask 。
/// - Note: APIManger 默认功能都是由 APITaskManager 处理的，一般情况下，你不需要用到它，除非默认提供的功能不能满足你的需求。
/// - Note: 所有异步操作都使用 weak 以避免 APITaskManager 生命周期的延长。
fileprivate class _APITaskManager<Manager: APIManager> {
    
    typealias Request = Manager.Response.Request

    deinit {
        // 当 APITaskManager 释放时，说明 APIManager 已经释放了。
        // 这里取消事件，不会触发 APIManager 的回调。
        cancelAllUnsafe()
    }

    func send(_ request: Request) -> APITask {
        let apiTask = _APITask.init(request: request, delegate: self)
        tasksLock.lock()
        // 并发列队不能保证执行顺序，所以使用串行列队。
        NetworkingQueue.async(execute: { [weak self] in
            self?.dispatchUnsafe(apiTask)
        })
        tasksLock.unlock()
        return apiTask
    }
    
    /// 调度新的任务（自动重试的任务也被认为是新任务）：根据请求的并发规则，进行调度。非线程安全函数，需要在串行队列中执行。
    /// - Note: 在处理完并发规则后，如果接口任务需要立即执行，会立即执行。
    /// - Note: 如果接口请求需要被延迟发送，则接口任务会被保存到相应的队列中。
    /// - Parameters:
    ///   - newTask: 待调度的新任务，如果为 nil ，则表示调度等待列队中的任务。
    private func dispatchUnsafe(_ apiTask: _APITask<Manager>) {
        if apiTask.isCancelled {
            // 如果任务已取消，则结束网络请求。
            return apiTaskUnsafe(apiTask, didCollect: nil, error: APIError.cancelled)
        }
        switch apiTask.request.concurrencyPolicy {
        case .ignoreCurrent:
            if runningTasks.isEmpty {
                return performUnsafe(apiTask)
            }
            return apiTaskUnsafe(apiTask, didCollect: nil, error: APIError.ignored)
            
        case .default:
            return performUnsafe(apiTask)
            
        case .cancelOthers:
            cancelAllUnsafe()
            return performUnsafe(apiTask)
            
        case .wait(let priority):
            if runningTasks.isEmpty {
                return performUnsafe(apiTask)
            }
            // 优先级列队优先出列最后面的，所以将 apiTask 插入到相同优先级的前面。
            for index in 0 ..< waitingTasks.count {
                // 数组越到后面优先级越高，所以找到第一个优先级相同的或者优先级比当前高的。
                guard priority <= waitingTasks[index].request.concurrencyPolicy.priority else {
                    continue
                }
                return waitingTasks.insert(apiTask, at: index)
            }
            // 优先级大于已有的所有正在等待任务或目前没有等待的任务。
            return waitingTasks.append(apiTask)
        }
    }
    
    /// 执行任务。非线程安全，待执行的接口任务必须不在队列中。
    /// - Note: 本方法直接由调度任务的方法调用，其它方法不应该被调用。
    /// - Note: 只有此方法会将任务加入到正在执行的任务队列。
    /// - Note: 待执行的任务必须是独立的任务。
    /// - Parameter apiTask: 待执行的接口请求任务。
    private func performUnsafe(_ apiTask: _APITask<Manager>) {
        guard let manager = self.manager else { return }
        do {
            let request = apiTask.request
            let identifier = apiTask.identifier
            
            // 创建网络请求
            apiTask.dataTask = try manager.dataTask(for: apiTask.request, progress: { [weak self] (bytes, totalBytes) in
                self?.manager?.request(request, didProcess: (bytes, totalBytes))
            }, completion: { [weak self] (data, error) in
                // 同步：在网络请求回调执行完，那么 APIManger 的整个业务逻辑也结束了。
                // 异步：网络请求的回调执行，可以提前结束，不必等待数据解析完成，可提前释放资源。
                NetworkingQueue.async(execute: { () -> Void in
                    guard let this = self else { return }
                    // 取消超时。
                    apiTask.setDeadlineInterval(nil)
                    // 检查接口任务是否有效，cancelAll或已超时的任务已提前清除了。
                    guard let apiTask = this.runningTasks.removeValue(forKey: identifier) else {
                        return
                    }
                    return this.apiTaskUnsafe(apiTask, didCollect: data, error: error)
                })
            })
            // 设置超时。
            apiTask.setDeadlineInterval(request.deadlineInterval)
            
            runningTasks[identifier] = apiTask
        } catch {
            // 只有在 apiTaskUnsafe 方法中，等待或延时的中的任务才能自动执行。
            apiTaskUnsafe(apiTask, didCollect: nil, error: error)
        }
    }
    
    /// 所有接口请求完成事件都在此方法中调用。非线程安全的方法。apiTask 的状态应该在调用此方法前判定，并生成相应的 error 。
    private func apiTaskUnsafe(_ apiTask: _APITask<Manager>, didCollect data: Any?, error networkError: Error?) {
        /// 接口请求失败或者解析数据失败，尝试自动重试。
        func retryIfNeeded(for manager: Manager, apiTask: _APITask<Manager>, error: Error) {
            // 判断是否需要自动重试。
            if apiTask.request.retryIfFailed, let delay = manager.request(apiTask.request, timeIntervalForRetrying: apiTask.retriedTimes, forFailingError: error) {
                // 重置任务状态。
                apiTask.dataTask     = nil
                apiTask.retriedTimes += 1
                
                let identifier = apiTask.identifier
                
                delayedTasks[identifier] = apiTask
                
                // 由于引用的关系，自动重试的任务，在完成前，不会从内存中销毁。
                NetworkingQueue.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
                    guard let this = self else { return }
                    // 延时指定时间后取出并重新调度该接口任务。
                    guard let delayedTask = this.delayedTasks.removeValue(forKey: identifier) else { return }
                    this.dispatchUnsafe(delayedTask)
                })
            } else {
                // 发送错误事件。
                apiTaskMainThreadSync(apiTask, didFailWithError: error)
            }
        }
        
        guard let manager = self.manager else { return }
        if let error = networkError {
            // 如果网络请求发生错误，判断是否需要自动重试。
            retryIfNeeded(for: manager, apiTask: apiTask, error: error)
        } else {
            do {
                // 没有错误，解析数据，生成 Response ，并回调。
                let response = try manager.request(apiTask.request, didCollect: data)
                apiTaskMainThreadSync(apiTask, didReceive: response)
            } catch {
                // 与 4.0 版本之前不同，解析数据失败，也会触发自动重试。
                retryIfNeeded(for: manager, apiTask: apiTask, error: error)
            }
        }
        
        // 等待的任务出列执行。
        // 如果当前没有正在执行任务，才从等待列队中取出任务。
        guard runningTasks.isEmpty else {
            return
        }
        // 等待执行的列队不为空。
        guard waitingTasks.isEmpty == false else {
            return
        }
        // 任务出列并调度。
        dispatchUnsafe(waitingTasks.removeLast())
    }
    
    /// APITask 代理事件。删除已超时的任务，并转发事件。
    func apiTaskWasOvertimeUnsafe(_ apiTask: _APITask<Manager>) {
        // 先移除已经超时的网络请求。
        guard let removedTask = runningTasks.removeValue(forKey: apiTask.identifier) else { return }
        // 取消网络请求。
        removedTask.dataTask?.cancel()
        // 超时的任务，可以进行重试。
        apiTaskUnsafe(removedTask, didCollect: nil, error: APIError.overtime)
    }
    
    var isRunning: Bool {
        return (runningTasks.isEmpty == false) || (waitingTasks.isEmpty == false) || (delayedTasks.isEmpty == false)
    }
    
    /// 取消所有任务：先从列队中删除，然后发送事件。
    /// 因为是在串行列队中执行，可以保证取消时不会与其他事件重叠。
    func cancelAllUnsafe() -> Void {
        // 取消正在执行的任务。
        if !runningTasks.isEmpty {
            runningTasks.removeAll()
            for item in runningTasks {
                item.value.dataTask?.cancel()
                apiTaskMainThreadSync(item.value, didFailWithError: APIError.cancelled)
            }
        }
        
        // 取消等待中的任务。
        if !waitingTasks.isEmpty {
            waitingTasks.removeAll()
            for apiTask in waitingTasks {
                apiTask.dataTask?.cancel()
                apiTaskMainThreadSync(apiTask, didFailWithError: APIError.cancelled)
            }
        }
        
        // 取消延迟执行的任务。
        if !delayedTasks.isEmpty {
            delayedTasks.removeAll()
            for item in delayedTasks {
                item.value.dataTask?.cancel()
                apiTaskMainThreadSync(item.value, didFailWithError: APIError.cancelled)
            }
        }
    }
    
    /// 因为 APIManager 与 APITaskManager 是值绑定的关系，所以生命周期也较长。
    /// 也因为 APITaskManager 包含了网络请求或异步的的操作，其生命周期也有可能比 APIManager 长。
    /// 所以这里使用 weak 。
    private weak var manager: Manager?
    /// 正在执行的任务。
    private var runningTasks = [String: _APITask<Manager>]()
    /// 排队等待执行的任务，按任务按并发优先级从低到高在数组中排列。
    private var waitingTasks = [_APITask<Manager>]()
    /// 延时自动重试的任务。
    private var delayedTasks = [String: _APITask<Manager>]()
    /// 读写 ~Tasks 的锁。
    private let tasksLock = NSLock()
    
    fileprivate init(for manager: Manager) {
        self.manager = manager
    }
    
    /// 在主线程中同步回调结果事件。
    private func apiTaskMainThreadSync(_ apiTask: _APITask<Manager>, didReceive response: Manager.Response) {
        guard let manager = self.manager else { return }
        if Thread.isMainThread {
            manager.request(apiTask.request, didReceive: response)
        } else {
            DispatchQueue.main.sync(execute: {
                manager.request(apiTask.request, didReceive: response)
            })
        }
    }
    
    /// 在主线程同步回调错误事件。
    private func apiTaskMainThreadSync(_ apiTask: _APITask<Manager>, didFailWithError error: Error) {
        guard let manager = self.manager else { return }
        if Thread.isMainThread {
            manager.request(apiTask.request, didFailWithError: error)
        } else {
            DispatchQueue.main.sync(execute: {
                manager.request(apiTask.request, didFailWithError: error)
            })
        }
    }
    
}

/// 每一个 APIRequest 在执行时，都会生成一个 APITaskk 对象，通过该对象可以获取一些任务信息或者取消对应的 APIRequest 。
public protocol APITask: AnyObject {
    /// 任务的唯一标识符。
    var identifier: String  { get }
    /// 已重试的次数。
    var retriedTimes: Int { get }
    /// 执行任务的 URLSessionDataTask 对象。
    var dataTask: URLSessionDataTask? { get }
    /// 是否已取消。
    var isCancelled: Bool { get }
    /// 取消当前任务。
    func cancel() -> Void
    /// 任务限时时长。
    var deadlineInterval: TimeInterval? { get }
}


/// 接口请求任务。
private final class _APITask<Manager: APIManager>: APITask {
    
    public typealias Request = Manager.Request
    
    /// 任务的唯一标识符。
    public let identifier: String = UUID().uuidString
    /// 请求。
    public let request: Request
    /// 已重试的次数。
    public fileprivate(set) var retriedTimes: Int = 0
    /// 执行任务的 URLSessionDataTask 对象。
    public fileprivate(set) weak var dataTask: URLSessionDataTask?
    /// 是否已取消。
    public private(set) var isCancelled: Bool = false
    /// 任务限时时长。
    public private(set) var deadlineInterval: TimeInterval?
    /// 取消当前任务。
    public func cancel() {
        if isCancelled {
            return
        }
        isCancelled = true
        isDeadlineTimerSuspended = true
        // 等待中的任务被取消，那么任务在调度的时候，触发错误回调。
        // 正在发送中的任务，取消会收到错误回调。
        // 已完成的任务取消无效。
        dataTask?.cancel()
    }
    
    /// 设置并启动任务的终止的倒计时。
    public func setDeadlineInterval(_ deadlineInterval: TimeInterval?) {
        self.deadlineInterval = deadlineInterval
        guard let deadlineInterval = deadlineInterval, deadlineInterval > 0 else {
            isDeadlineTimerSuspended = true
            deadlineTimer?.schedule(deadline: .distantFuture, repeating: .never)
            deadlineTimer?.setEventHandler(handler: nil)
            deadlineTimer?.suspend()
            return
        }
        // 启动倒计时。
        isDeadlineTimerSuspended = false
        if deadlineTimer == nil {
            deadlineTimer = DispatchSource.makeTimerSource(queue: .global())
        }
        deadlineTimer!.schedule(deadline: .now() + deadlineInterval, repeating: .never)
        deadlineTimer!.setEventHandler(handler: { [weak self] in
            NetworkingQueue.async(execute: {
                guard let this = self else { return }
                this.delegate?.apiTaskWasOvertimeUnsafe(this)
            })
        })
        deadlineTimer!.resume()
    }
    
    fileprivate init(request: Request, delegate: _APITaskManager<Manager>) {
        self.request  = request
        self.delegate = delegate
    }
    
    deinit {
        if isDeadlineTimerSuspended {
            deadlineTimer?.setEventHandler(handler: nil)
            deadlineTimer?.resume()
        }
        deadlineTimer?.cancel()
    }
    
    /// APITask 自身没有会延长生命周期的异步操作，可以用 unowned 修饰。
    /// 但是 APITask 可能会被第三方持有，所以用 weak 。
    private weak var delegate: _APITaskManager<Manager>?
    /// 任务时长的倒计时是否已暂停。
    private var isDeadlineTimerSuspended = true
    /// 执行时间的倒计时，请使用 isDeadlineTimerSuspended 控制。
    private var deadlineTimer: DispatchSourceTimer?
    
}



private struct AssociationKey {
    static var apiTaskManager: Int = 0
}

