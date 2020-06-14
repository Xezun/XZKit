//
//  APIManager.swift
//  XZKit
//
//  Created by Xezun on 2018/7/3.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import Foundation

/// Networking 模块。
public enum Networking {
    /// 共用的列队。
    public static let queue = DispatchQueue(label: APIError.Domain, attributes: .concurrent)
}

/// 网络协议。
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

/// 接口管理协议，网络请求的接口设计规范。
/// - Note: 默认情况下，所有方法在子线程上执行。
public protocol APIManager: APINetworking {
    
    /// 接口请求。
    associatedtype Request: APIRequest
    /// 接口响应。
    associatedtype Response: APIResponse where Response.Request == Request
    /// 分数表示的进度，value / scale 得到百分比。
    typealias Progress = (value: Int64, scale: Int64)
    
    /// 发送接口请求。每次调用此方法，都会创建一个与接口请求相关联的APITask对象，用于跟踪管理本次请求。
    /// - Parameter request: 接口请求对象。
    /// - Returns: 描述表示本次请求的接口的对象。
    @discardableResult
    func send(_ request: Request) -> APITask
    
    /// 当请求进度更新时，此方法会被调用。
    /// - Parameters:
    ///   - request: 接口请求对象。
    ///   - progress: 接口请求当前进度。
    func request(_ request: Request, didProcess progress: APIManager.Progress)
    
    /// 当请求完成数据传输时，此方法会被调用。
    /// - Note: 此方法一般用于校验数据的基本信息，比如类型、格式等。数据的业务合法性在，可在Response中由具体业务实现。
    /// - Parameters:
    ///   - request: 接口请求对象。
    ///   - data: 接口返回到数据。
    func request(_ request: Request, didCollect data: Any?) throws -> Response
    
    /// 当请求获得返回结果，成功生成结果时，此方法会被调用。
    /// - Note: 只有当本方法执行完毕，等待的任务才会进入调度列队，所以，如果在此方法中执行一个新的请求，等待执行的任务可能继续处于等待中。
    /// - Parameters:
    ///   - request: 接口请求对象。
    ///   - response: 接口响应对象。
    func request(_ request: Request, didReceive response: Response)
    
    /// 当接口请求发生错误时，此方法会被调用。如果请求的retryIfFailed属性为true，那么当请求失败时，
    /// 将通过此方法获取再次重试的时间（当前时间到再次重试之间的时间间隔）；如果此方法返回nil，则终止重试。
    /// 可根据error.numberOfRetries已重试的次数，来控制再次重试的时间，提高程序性能。
    /// - Parameters:
    ///   - request: 接口请求对象。
    ///   - error: 接口请求过程中的错误对象。
    @discardableResult
    func request(_ request: Request, didFailWith error: APIError) -> TimeInterval?
    
}


// MARK: - 功能部分

extension APIManager {
    
    @discardableResult
    public func send(_ request: Request) -> APITask {
        return apiTaskManager.send(request)
    }
    
    /// 是否有正在进行、或等待中、或延迟执行的任务。
    public var isRunning: Bool {
        return apiTaskManager.isRunning
    }
    
    /// 取消所有正在执行的接口请求，异步操作。
    /// - Note: 取消任务，将会收到 APIError.canceled 错误。
    /// - Note: 在 APIManager 销毁后，会自动取消所有正在进行的请求。
    public func cancelAllTasks() {
        apiTaskManager.cancelAllTasks()
    }
    
    private var apiTaskManager: _APITaskManager<Self> {
        if let wrapper = objc_getAssociatedObject(self, &AssociationKey.apiTaskManager) as? _APITaskManager<Self> {
            return wrapper
        }
        objc_sync_enter(self)
        if let wrapper = objc_getAssociatedObject(self, &AssociationKey.apiTaskManager) as? _APITaskManager<Self> {
            objc_sync_exit(self)
            return wrapper
        }
        let wrapper = _APITaskManager.init(for: self)
        objc_setAssociatedObject(self, &AssociationKey.apiTaskManager, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_sync_exit(self)
        return wrapper
    }
    
}



// MARK: - APITaskManager

/// 管理了 APIManger 的请求任务和多线程处理。
/// - Note: APITaskManager 实际上就是 APIManager ，管理了 APITask 。
/// - Note: APIManger 默认功能都是由 APITaskManager 处理的，一般情况下，你不需要用到它，除非默认提供的功能不能满足你的需求。
/// - Note: 所有异步操作都使用 weak 以避免 APITaskManager 生命周期的延长。
fileprivate class _APITaskManager<Manager: APIManager> {
    
    typealias Request = Manager.Request
    typealias Response = Manager.Response
    typealias Task = _APITask<Manager>

    public func send(_ request: Request) -> APITask {
        let apiTask = _APITask(request: request, delegate: self)
        
        pthread_mutex_lock(&lock)
        let identifier = apiTask.identifier
        pendingTasks[identifier] = apiTask
        pthread_mutex_unlock(&lock)
        
        Networking.queue.async(execute: { [weak self] in
            guard let self = self else { return }
            
            pthread_mutex_lock(&self.lock)
            let pendingTask = self.pendingTasks.removeValue(forKey: identifier)
            pthread_mutex_unlock(&self.lock)
            
            guard let apiTask = pendingTask else { return }
            self.dispatch(apiTask)
        })
        
        return apiTask
    }
    
    public func cancelAllTasks() {
        pthread_mutex_lock(&lock)
        let apiTasks = cancelAllTasksUnsafe()
        pthread_mutex_unlock(&lock)
        
        Networking.queue.async(execute: { [weak self] in
            guard let manager = self?.manager else { return }
            for apiTask in apiTasks {
                manager.request(apiTask.request, didFailWith: APIError.cancelled)
            }
        })
    }
    
    private func cancelAllTasksUnsafe() -> [Task] {
        var apiTasks = [Task]()
        
        for (_, apiTask) in pendingTasks {
            apiTasks.append(apiTask)
        }
        
        for (_, apiTask) in runningTasks {
            apiTasks.append(apiTask)
        }
        
        for apiTask in waitingTasks {
            apiTasks.append(apiTask)
        }
        
        for apiTask in delayedTasks {
            apiTasks.append(apiTask)
        }
        
        pendingTasks.removeAll()
        runningTasks.removeAll()
        waitingTasks.removeAll()
        delayedTasks.removeAll()
        
        return apiTasks
    }
    
    /// 将任务按并发策略进行调度：放入执行列队或等待列队。
    private func dispatch(_ apiTask: _APITask<Manager>) {
        do {
            if apiTask.isCancelled {
                throw APIError.cancelled
            }
            if let apiTask = try enqueue(apiTask) {
                perform(apiTask)
            }
        } catch {
            complete(apiTask, data: nil, error: error)
        }
    }
    
    // 将任务按并发策略加入对应的列队，如果任务需立即执行，则返回该任务。
    private func enqueue(_ apiTask: Task) throws -> Task? {
        pthread_mutex_lock(&self.lock)
        defer {
            pthread_mutex_unlock(&self.lock)
        }
        switch apiTask.request.concurrencyPolicy {
        case .ignoreCurrent:
            guard runningTasks.isEmpty else {
                throw APIError.ignored
            }
            runningTasks[apiTask.identifier] = apiTask
            
        case .default:
            runningTasks[apiTask.identifier] = apiTask
            
        case .cancelOthers:
            let apiTasks = cancelAllTasksUnsafe()
            runningTasks[apiTask.identifier] = apiTask
            Networking.queue.async(execute: { [weak self] in
                guard let self = self else { return }
                for apiTask in apiTasks {
                    self.complete(apiTask, data: nil, error: APIError.cancelled)
                }
            })
            
        case .wait(let priority):
            guard runningTasks.isEmpty else {
                if let index = waitingTasks.firstIndex(where: {
                    priority <= $0.request.concurrencyPolicy.priority
                }) {
                    waitingTasks.insert(apiTask, at: index)
                } else {
                    waitingTasks.append(apiTask)
                }
                return nil
            }
            runningTasks[apiTask.identifier] = apiTask
        }
        
        return apiTask
    }
    
    /// 执行接口请求任务。
    /// - Note: 本方法直接发送请求，任何验证操作，请在调用此方法之前执行。
    private func perform(_ apiTask: _APITask<Manager>) {
        guard let manager = self.manager else { return }
        let identifier = apiTask.identifier
        do {
            let request = apiTask.request
            apiTask.setDeadlineInterval(request.deadlineInterval)
            apiTask.dataTask = try manager.dataTask(for: request, progress: { [weak self] in
                self?.manager?.request(request, didProcess: ($0, $1))
            }, completion: { [weak self] (data, error) in
                Networking.queue.async(execute: {
                    guard let self = self else { return }
                    if let apiTask = self.dequeueRunningTask(with: identifier) {
                        apiTask.setDeadlineInterval(nil)
                        self.complete(apiTask, data: data, error: error)
                    }
                })
            })
        } catch {
            if let apiTask = dequeueRunningTask(with: identifier) {
                complete(apiTask, data: nil, error: error)
            }
        }
    }
    
    /// 任务完成，在调用此方法前 apiTask 已从列队移除。
    private func complete(_ apiTask: _APITask<Manager>, data: Any?, error: Error?) {
        guard let manager = self.manager else { return }
        
        do {
            if let error = error {
                throw error
            }
            let response = try manager.request(apiTask.request, didCollect: data)
            manager.request(apiTask.request, didReceive: response)
        } catch { // 发生错误，检查自动重试
            apiTask.retriedTimes += 1
            var apiError = APIError(error)
            apiError.numberOfRetries = apiTask.retriedTimes
            let delay = manager.request(apiTask.request, didFailWith: apiError)
            if apiTask.request.retryIfFailed, let delay = delay {
                scheduleDelayedTasks(apiTask, delay: delay)
            }
        }
        
        if let apiTask = dequeueWaitingTask() {
            dispatch(apiTask)
        }
    }
    
    /// 从等待列队取出任务。
    private func dequeueWaitingTask() -> Task? {
        pthread_mutex_lock(&lock)
        defer {
            pthread_mutex_unlock(&lock)
        }
        guard runningTasks.isEmpty else {
            return nil
        }
        if waitingTasks.isEmpty {
            return nil
        }
        return waitingTasks.removeLast()
    }
    
    private func dequeueRunningTask(with identifier: String) -> Task? {
        pthread_mutex_lock(&lock)
        defer {
            pthread_mutex_unlock(&lock)
        }
        return runningTasks.removeValue(forKey: identifier)
    }
    
    private func scheduleDelayedTasks(_ delayedTask: Task?, delay: TimeInterval) {
        pthread_mutex_lock(&lock)
        
        let now = DispatchTime.now()
        
        if let apiTask = delayedTask {
            apiTask.isCancelled  = false
            apiTask.dataTask     = nil
            apiTask.fireDate     = now + delay
            if let index = delayedTasks.firstIndex(where: { $0.fireDate > apiTask.fireDate }) {
                delayedTasks.insert(apiTask, at: index)
            } else {
                delayedTasks.append(apiTask)
            }
        }
        
        var apiTasks = [Task]() // 延时到期的任务
        
        while !delayedTasks.isEmpty {
            let time1 = delayedTasks[0].fireDate.uptimeNanoseconds
            let time2 = now.uptimeNanoseconds
            if Int64(bitPattern: time1 &- time2) < 1_000_000 {
                apiTasks.append(delayedTasks.removeFirst())
            } else {
                break
            }
        }
        
        if let new = delayedTasks.first?.fireDate {
            if scheduleTime != new {
                if delayedTimer == nil {
                    delayedTimer = DispatchSource.makeTimerSource(queue: Networking.queue)
                    delayedTimer?.schedule(deadline: .distantFuture)
                    delayedTimer!.setEventHandler(handler: { [weak self] in
                        self?.scheduleDelayedTasks(nil, delay: 0)
                    })
                }
                delayedTimer!.schedule(deadline: new)
                if scheduleTime == nil {
                    delayedTimer!.resume()
                }
                scheduleTime = new
            }
        } else if scheduleTime != nil {
            scheduleTime = nil
            delayedTimer?.schedule(deadline: .distantFuture)
            delayedTimer?.suspend()
        }
        
        pthread_mutex_unlock(&lock)
        
        for apiTask in apiTasks {
            dispatch(apiTask)
        }
    }
    
    /// APITask 代理事件。删除已超时的任务，并转发事件。
    fileprivate func apiTaskWasOvertimeUnsafe(_ apiTask: _APITask<Manager>) {
        // 先移除已经超时的网络请求。
        guard let removedTask = dequeueRunningTask(with: apiTask.identifier) else { return }
        // 取消网络请求。
        removedTask.dataTask?.cancel()
        // 超时的任务，可以进行重试。
        complete(removedTask, data: nil, error: APIError.overtime)
    }
    
    var isRunning: Bool {
        pthread_mutex_lock(&lock)
        let isRunning = !pendingTasks.isEmpty || !runningTasks.isEmpty || !waitingTasks.isEmpty || !delayedTasks.isEmpty
        pthread_mutex_unlock(&lock)
        return isRunning
    }
    
    /// 因为 APIManager 与 APITaskManager 是值绑定的关系，所以生命周期也较长。
    /// 也因为 APITaskManager 包含了网络请求或异步的的操作，其生命周期也有可能比 APIManager 长。
    /// 所以这里使用 weak 。
    private weak var manager: Manager?
    /// 正在执行的任务。
    private lazy var runningTasks = [String: _APITask<Manager>]()
    /// 排队等待执行的任务，按任务按并发优先级从低到高在数组中排列。
    private lazy var waitingTasks = [_APITask<Manager>]()
    /// 延时自动重试的任务。
    private lazy var delayedTasks = [_APITask<Manager>]()
    /// 即将执行的列队。
    private lazy var pendingTasks = [String: _APITask<Manager>]()
    /// 读写 ~Tasks 的锁。
    private var lock: pthread_mutex_t
    
    private var scheduleTime: DispatchTime?
    private var delayedTimer: DispatchSourceTimer?
    
    fileprivate init(for manager: Manager) {
        self.manager = manager
        
        var tasksLock = pthread_mutex_t.init()
        pthread_mutex_init(&tasksLock, nil)
        
        self.lock = tasksLock
    }
    
    deinit {
        if scheduleTime != nil {
            delayedTimer?.resume()
            delayedTimer?.cancel()
        }
        _ = cancelAllTasksUnsafe()
        pthread_mutex_destroy(&lock)
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
    /// 延迟执行的时间点。
    public fileprivate(set) lazy var fireDate = DispatchTime.distantFuture
    /// 执行任务的 URLSessionDataTask 对象。
    public fileprivate(set) weak var dataTask: URLSessionDataTask?
    /// 是否已取消。
    public fileprivate(set) var isCancelled: Bool = false
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
            deadlineTimer = DispatchSource.makeTimerSource(queue: Networking.queue)
        }
        deadlineTimer!.schedule(deadline: .now() + deadlineInterval, repeating: .never)
        deadlineTimer!.setEventHandler(handler: { [weak self] in
            Networking.queue.async(execute: {
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


extension Double {
    
    /// 将元组 (分子, 分母) 表示的分数转换成小数。
    /// - Parameter value: 元组形式的分数。
    public init<T: BinaryInteger, K: BinaryInteger>(fraction value: (T, K)) {
        self = Double(value.0) / Double(value.1)
    }
    
}
