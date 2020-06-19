//
//  XZAPIManager.swift
//  XZKit
//
//  Created by Xezun on 2018/7/3.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import Foundation

/// APIManager 共用的并发列队。
public let NetworkingQueue = DispatchQueue(label: APIError.Domain, attributes: .concurrent)

/// 接口管理协议，网络请求的接口设计规范。
/// - Note: 默认情况下，所有方法在子线程上执行。
public protocol APIManager: APINetworking {
    
    /// 接口请求。
    associatedtype Request: APIRequest
    
    /// 接口响应。
    associatedtype Response: APIResponse where Response.Request == Request
    
    /// 分数表示的进度，value / scale 得到百分比。
    typealias Progress = (completed: Int64, total: Int64)
    
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
    
    /// 当接口请求发生错误时，此方法会被调用。
    /// - Note: 属性 retryIfFailed 为 true 的请求在失败时，会通过此方法获取当前时间到下次重试之间的时间间隔，返回 nil 终止重试。
    /// - Note: 主动取消的任务，不会触发重试询问。
    /// - Note: 参数 error 的属性 numberOfRetries 表示当前已重试的次数（不包括第一次请求，值为 nil 时表示当前非重试问答模式）。
    /// - Note: 返回合适的时间间隔，以提高程序性能，比如随次数逐渐增加每次重试的时间间隔等。
    /// - Parameters:
    ///   - request: 接口请求对象。
    ///   - error: 接口请求过程中的错误对象。
    @discardableResult
    func request(_ request: Request, didFailWith error: APIError) -> TimeInterval?
    
}


// MARK: - APIManager 默认实现

extension APIManager {
    
    /// 组。必须在没有请求任务时才能 APIManager 发送任何请求前设置组
    public var group: APIGroup {
        get { return taskManager.group     }
        set { taskManager.group = newValue }
    }
    
    @discardableResult
    public func send(_ request: Request) -> APITask {
        return taskManager.send(request)
    }
    
    /// 是否有正在进行、等待中、延迟中的任务。
    public var isRunning: Bool {
        return taskManager.isRunning
    }
    
    /// 取消所有正在执行的接口请求，异步操作。
    /// - Note: 取消任务，将会收到 APIError.canceled 错误。
    /// - Note: 在 APIManager 销毁后，会自动取消所有正在进行的请求。
    public func cancelAllTasks() {
        taskManager.cancelAllTasks()
    }
    
    fileprivate var taskManager: APITaskManager<Self> {
        if let manager = objc_getAssociatedObject(self, &AssociationKey.apiTaskManager) as? APITaskManager<Self> {
            return manager
        }
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if let manager = objc_getAssociatedObject(self, &AssociationKey.apiTaskManager) as? APITaskManager<Self> {
            return manager
        }
        let manager = APITaskManager(for: self)
        objc_setAssociatedObject(self, &AssociationKey.apiTaskManager, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return manager
    }
    
}



// MARK: - APITaskManager

/// 管理了 APIManger 的请求任务和多线程处理。
/// - Note: APITaskManager 实际上就是 APIManager ，管理了 APITask 。
/// - Note: APIManger 默认功能都是由 APITaskManager 处理的，一般情况下，你不需要用到它，除非默认提供的功能不能满足你的需求。
/// - Note: 所有异步操作都使用 weak 以避免 APITaskManager 生命周期的延长。
fileprivate class APITaskManager<Manager: APIManager>: APIGroup, APITimerDelegate {
    
    typealias Request  = Manager.Request
    typealias Response = Manager.Response
    typealias Task     = _APITask<Manager>
    
    deinit {
        _ = cancelAllTasksUnsafe(sendsEvents: false, retrievable: false)
        if group != self {
            group.remove(self)
        }
    }
    
    public init(for manager: Manager) {
        super.init()
        self.manager = manager
        self.group   = self
    }
    
    override public var group: APIGroup! {
        get {
            return super.group
        }
        set {
            if let oldGroup = super.group, oldGroup != self {
                oldGroup.remove(self)
            }
            super.group = newValue
            if let newGroup = newValue, newGroup != self {
                newGroup.add(self)
            }
        }
    }
    
    public var isRunning: Bool {
        return !(pendingTasks.isEmpty && runningTasks.isEmpty && waitingTasks.isEmpty && delayedTasks.isEmpty)
    }
    
    public func send(_ request: Request) -> APITask {
        let apiTask = _APITask(request, delegate: self)
        
        let identifier = apiTask.identifier
        group.lock(execute: {
            self.pendingTasks[identifier] = apiTask
        })
        
        NetworkingQueue.async(execute: { [weak self] in
            guard let self = self else { return }
            self.group.lock(execute: {
                guard let apiTask = self.pendingTasks.removeValue(forKey: identifier) else { return }
                self.dispatchUnsafe(apiTask)
            })
        })
        
        return apiTask
    }
    
    public func cancelAllTasks() {
        group.lock(execute: {
            cancelAllTasksUnsafe(sendsEvents: true, retrievable: false)
        })
    }
    
    override func add(_ item: APIGroup) {
        assert(false, "The APIManager's default APIGroup should only be used by itself!")
    }
    
    override func remove(_ item: APIGroup) {
        assert(false, "The APIManager's default APIGroup should only be used by itself!")
    }
    
    override var hasRunningTasksUnsafe: Bool {
        return !runningTasks.isEmpty
    }
    
    override func cancelAllTasksUnsafe(sendsEvents: Bool, retrievable: Bool) {
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
        
        for apiTask in apiTasks {
            apiTask.retrievable = retrievable
            apiTask.isCancelled = true
            apiTask.dataTask?.cancel()
        }
        
        guard sendsEvents else { return }
        NetworkingQueue.async(execute: { [weak self] in
            guard let self = self else { return }
            for apiTask in apiTasks {
                self.complete(apiTask, data: nil, error: APIError.cancelled)
            }
        })
    }
    
    override var maximumPriorityInWaitingTasksUnsafe: Int? {
        return waitingTasks.last?.request.concurrencyPolicy.priority.rawValue
    }
    
    override func scheduleWaitingTaskUnsafe() {
        if waitingTasks.isEmpty {
            return
        }
        dispatchUnsafe(waitingTasks.removeLast())
    }
    
    /// 将任务按并发策略进行调度：放入执行列队或等待列队。
    private func dispatchUnsafe(_ apiTask: _APITask<Manager>) {
        do {
            if apiTask.isCancelled {
                throw APIError.cancelled
            }
            guard let apiTask = try enqueueUnsafe(apiTask) else {
                return
            }
            NetworkingQueue.async(execute: { [weak self] in
                guard let self = self else { return }
                self.perform(apiTask)
            })
        } catch {
            NetworkingQueue.async(execute: { [weak self] in
                guard let self = self else { return }
                self.complete(apiTask, data: nil, error: error)
            })
        }
    }
    
    // 将任务按并发策略加入对应的列队，如果任务需立即执行，则返回该任务。
    private func enqueueUnsafe(_ apiTask: Task) throws -> Task? {
        switch apiTask.request.concurrencyPolicy {
        case .ignoreCurrent:
            if group.hasRunningTasksUnsafe {
                throw APIError.ignored
            }
            runningTasks[apiTask.identifier] = apiTask
            
        case .default:
            runningTasks[apiTask.identifier] = apiTask
            
        case .cancelOthers:
            group.cancelAllTasksUnsafe(sendsEvents: true, retrievable: true)
            runningTasks[apiTask.identifier] = apiTask
            
        case .wait(let priority):
            if group.hasRunningTasksUnsafe {
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
            apiTask.deadline = ((request.deadline == nil) ? nil : (.now() + request.deadline!))
            apiTask.dataTask = try manager.dataTask(for: request, progress: { [weak self] in
                guard let manager = self?.manager else { return }
                manager.request(request, didProcess: ($0, $1))
            }, completion: { [weak self] (data, error) in
                NetworkingQueue.async(execute: {
                    guard let self = self else { return }
                    if let apiTask = self.group.lock(execute: {
                        self.runningTasks.removeValue(forKey: identifier)
                    }) {
                        apiTask.deadline = nil
                        self.complete(apiTask, data: data, error: error)
                    }
                })
            })
        } catch {
            if let apiTask = self.group.lock(execute: {
                self.runningTasks.removeValue(forKey: identifier)
            }) {
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
            var apiError = APIError(error)
            if apiTask.retrievable {
                apiError.numberOfRetries = apiTask.numberOfRetries
                let delay = manager.request(apiTask.request, didFailWith: apiError)
                if apiTask.request.retryIfFailed, let delay = delay {
                    group.lock(execute: {
                        self.dispatchUnsafe(apiTask, delay: delay)
                    })
                }
            } else {
                manager.request(apiTask.request, didFailWith: apiError)
            }
        }
        
        group.lock(execute: { self.group.scheduleWaitingTaskUnsafe() })
    }
    
    private func dispatchUnsafe(_ delayedTask: Task?, delay: TimeInterval) {
        let now = DispatchTime.now()
        
        if let apiTask = delayedTask {
            apiTask.numberOfRetries += 1
            apiTask.isCancelled  = false
            apiTask.dataTask     = nil
            apiTask.delaying     = now + delay
            if let index = self.delayedTasks.firstIndex(where: {
                $0.delaying > apiTask.delaying
            }) {
                self.delayedTasks.insert(apiTask, at: index)
            } else {
                self.delayedTasks.append(apiTask)
            }
            // 延时计时器已启动，且比新任务早，不需继续执行。
            if let oldDelay = self.delayedTimer?.deadline,
                oldDelay <= apiTask.delaying {
                return
            }
        }
        
        var apiTasks = [Task]() // 延时到期的任务
        
        // 找到触发时间在 0.001 秒以内的任务。
        while !delayedTasks.isEmpty {
            let time1 = delayedTasks[0].delaying.uptimeNanoseconds
            let time2 = now.uptimeNanoseconds
            guard Int64(bitPattern: time1 &- time2) < 1_000_000 else {
                break
            }
            apiTasks.append(delayedTasks.removeFirst())
        }
        
        // 调整延时计时器的触发时间。
        if let new = delayedTasks.first?.delaying {
            if delayedTimer == nil {
                delayedTimer = APITimer(delegate: self)
            }
            delayedTimer!.deadline = new
        } else {
            delayedTimer?.deadline = nil
        }
        
        // 执行延时任务。
        for apiTask in apiTasks {
            dispatchUnsafe(apiTask)
        }
    }
    
    /// 延时任务计时器事件。
    public func timerWasTimeout(_ timer: APITimer) {
        group.lock(execute: {
            self.dispatchUnsafe(nil, delay: 0)
        })
    }
    
    /// 任务超时事件。
    public func deadlineTimerWasTimeout(_ apiTask: Task) {
        guard let removedTask = self.group.lock(execute: {
            runningTasks.removeValue(forKey: apiTask.identifier)
        }) else { return }
        removedTask.dataTask?.cancel()
        complete(removedTask, data: nil, error: APIError.overtime)
    }
    
    /// 任务取消事件。
    public func cancelMethodWasCalled(_ apiTask: Task) {
        group.lock(execute: {
            apiTask.retrievable = false
            apiTask.isCancelled = true
            apiTask.dataTask?.cancel()
        })
    }
    
    private weak var manager: Manager?
    /// 正在执行的任务。
    private lazy var runningTasks = [UUID: _APITask<Manager>]()
    /// 排队等待执行的任务，按任务按并发优先级从低到高在数组中排列。
    private lazy var waitingTasks = [_APITask<Manager>]()
    /// 延时自动重试的任务。
    private lazy var delayedTasks = [_APITask<Manager>]()
    /// 即将执行的列队。
    private lazy var pendingTasks = [UUID: _APITask<Manager>]()
    /// 延时倒计时。
    private var delayedTimer: APITimer?
    
}

/// 接口请求任务。
fileprivate final class _APITask<Manager: APIManager>: APITask, APITimerDelegate {
    
    public typealias Request = Manager.Request
    public typealias TaskManager = APITaskManager<Manager>
    
    public init(_ request: Request, delegate: TaskManager) {
        self.request  = request
        self.delegate = delegate
    }
    
    public let request: Request
    public let identifier      = UUID()
    public var numberOfRetries = 0
    public var isCancelled     = false
    public weak var dataTask: URLSessionDataTask?
    public var deadline: DispatchTime? {
        didSet {
            if let deadline = self.deadline {
                if deadlineTimer == nil {
                    deadlineTimer = APITimer(delegate: self)
                }
                deadlineTimer!.deadline = deadline
            } else {
                deadlineTimer?.deadline = nil
            }
        }
    }
    
    /// 取消当前任务。
    public func cancel() {
        delegate?.cancelMethodWasCalled(self)
    }
    
    public func timerWasTimeout(_ timer: APITimer) {
        delegate?.deadlineTimerWasTimeout(self)
    }
    
    /// 延时。
    public var delaying: DispatchTime = .distantFuture
    /// 是否可重试。
    public var retrievable = true
    
    private weak var delegate: TaskManager?
    private var deadlineTimer: APITimer?
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


fileprivate protocol APITimerDelegate: class {
    func timerWasTimeout(_ timer: APITimer)
}

fileprivate final class APITimer {
    
    public private(set) weak var delegate: APITimerDelegate?
    
    public init(delegate: APITimerDelegate? = nil) {
        self.delegate = delegate
    }
    
    private var dispatchTimer: DispatchSourceTimer?
    
    public var deadline: DispatchTime? {
        didSet {
            if let deleyedTime = deadline {
                if dispatchTimer == nil { // 计时器尚未创建。
                    dispatchTimer = DispatchSource.makeTimerSource(queue: NetworkingQueue)
                    dispatchTimer!.schedule(deadline: deleyedTime)
                    dispatchTimer!.setEventHandler(handler: { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.timerWasTimeout(self)
                    })
                    dispatchTimer!.resume()
                } else if oldValue == nil { // 计时器处于停止状态。
                    dispatchTimer!.schedule(deadline: deleyedTime)
                    dispatchTimer!.resume()
                } else { // 计时器运行中。
                    dispatchTimer?.schedule(deadline: deleyedTime)
                }
            } else if oldValue != nil { // 计时取消了
                dispatchTimer?.schedule(deadline: .distantFuture)
                dispatchTimer?.suspend()
            }
        }
    }
    
    deinit {
        if deadline == nil {
            dispatchTimer?.resume()
        }
        dispatchTimer?.cancel()
    }
    
}

/// 组。
public class APIGroup: Hashable {
    
    private var mutex: pthread_mutex_t
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    public init() {
        var mutex = pthread_mutex_t.init()
        pthread_mutex_init(&mutex, nil)
        self.mutex = mutex
    }
    
    fileprivate weak var group: APIGroup!
    
    fileprivate func add(_ item: APIGroup) {
        pthread_mutex_lock(&mutex)
        item.mutex = mutex
        items.insert(Item(item))
        pthread_mutex_unlock(&mutex)
    }
    
    fileprivate func remove(_ item: APIGroup) {
        pthread_mutex_lock(&mutex)
        if let item = items.remove(Item(item)) {
            var mutex = pthread_mutex_t.init()
            pthread_mutex_init(&mutex, nil)
            item.value?.mutex = mutex
        }
        pthread_mutex_unlock(&mutex)
    }
    
    fileprivate var hasRunningTasksUnsafe: Bool {
        return items.contains(where: {
            $0.value?.hasRunningTasksUnsafe == true
        })
    }
    
    fileprivate func cancelAllTasksUnsafe(sendsEvents: Bool, retrievable: Bool) {
        for item in items {
            item.value?.cancelAllTasksUnsafe(sendsEvents: sendsEvents, retrievable: retrievable)
        }
    }
    
    fileprivate var maximumPriorityInWaitingTasksUnsafe: Int? {
        return nil
    }
    
    fileprivate func scheduleWaitingTaskUnsafe() {
        if hasRunningTasksUnsafe {
            return
        }
        items.max(by: { (item1, item2) -> Bool in
            if let priority1 = item1.value?.maximumPriorityInWaitingTasksUnsafe {
                if let priority2 = item2.value?.maximumPriorityInWaitingTasksUnsafe {
                    return priority1 < priority2
                }
                return false
            }
            return (item2.value?.maximumPriorityInWaitingTasksUnsafe != nil)
        })?.value?.scheduleWaitingTaskUnsafe()
    }
    
    fileprivate func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    fileprivate func unlock() {
        pthread_mutex_unlock(&mutex)
    }
    
    fileprivate func lock<T>(execute operation: () throws -> T) rethrows -> T {
        pthread_mutex_lock(&mutex)
        let result = try operation()
        pthread_mutex_unlock(&mutex)
        return result
    }
    
    private class Item: Hashable {
        static func == (lhs: APIGroup.Item, rhs: APIGroup.Item) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        weak var value: APIGroup?
        init(_ value: APIGroup) {
            self.value = value
        }
        func hash(into hasher: inout Hasher) {
            if let value = self.value {
                hasher.combine(value)
            } else {
                hasher.combine(0)
            }
        }
    }
    
    private lazy var items = Set<Item>()
    
    public static func == (lhs: APIGroup, rhs: APIGroup) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(unsafeBitCast(self, to: Int.self));
    }
    
}
