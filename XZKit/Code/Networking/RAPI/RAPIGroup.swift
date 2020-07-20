//
//  RAPIGroup.swift
//  XZKit
//
//  Created by Xezun on 2020/6/29.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import Foundation

public class RAPIGroup {
    
    public static let `default` = RAPIGroup.init()
    
    private var mutex: pthread_mutex_t
    
    public init() {
        var mutex = pthread_mutex_t.init()
        pthread_mutex_init(&mutex, nil)
        self.mutex = mutex
    }
    
    internal func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    internal func unlock() {
        pthread_mutex_unlock(&mutex)
    }
    
    internal func synchronize<T>(_ operation: () throws -> T) rethrows -> T {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        return try operation()
    }
    
    internal func manager<Manager: RAPIManager>(_ manager: Manager, dispatch task: Manager.Task) {
        
    }
    
    
}
