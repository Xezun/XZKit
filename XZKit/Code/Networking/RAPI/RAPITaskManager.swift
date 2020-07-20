//
//  RAPITaskManager.swift
//  XZKit
//
//  Created by Xezun on 2020/6/30.
//  Copyright © 2020 Xezun Inc. All rights reserved.
//

import Foundation


internal class RAPITaskManager<Manager: RAPIManager> {
    
    public typealias Request  = Manager.Request
    public typealias Response = Manager.Response
    public typealias Task     = RAPITask<Request>
    
    public var group: RAPIGroup = RAPIGroup.init()
    
    public func send(_ request: Request) -> Task {
        let task = RAPITask.init(request)
        self.group.manager(self, dispatch: task)
        return task
    }
    
    
}
