//
//  XZCacheManger.swift
//  XZKit
//
//  Created by Xezun on 2018/6/11.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

import Foundation

// CacheManager 目录仅仅支持通过标识符保存文件，后期考虑加入缓存大小、缓存时间控制的机制。

/// CacheManager 实现了一些将数据保存到 User Caches 目录的基本操作。
open class CacheManager: NSObject {
    
    /// 缓存域，如 com.xezun.XZKit 等。
    public struct Domain: RawRepresentable, CustomStringConvertible {
        public typealias RawValue = String
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        public var description: String {
            return rawValue
        }
    }
    
    /// 缓存空间，如 image 等。
    public struct Storage: RawRepresentable, CustomStringConvertible {
        public typealias RawValue = String
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        public var description: String {
            return rawValue
        }
    }
    
    /// 缓存域。
    public let domain: Domain
    /// 缓存分类。
    public let storage: Storage
    /// 缓存目录路径
    public let rootPath: String
    
    public init(domain: Domain, storage: Storage) throws {
        var cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        
        let manager = FileManager.default
        for directory in [domain.rawValue, "Caches", storage.rawValue] {
            cachesPath = try manager.createDirectory(directory, inPath: cachesPath)
        }
        
        self.domain   = domain
        self.storage  = storage
        self.rootPath = cachesPath
        
        super.init()
    }
    
    /// 指定标识符的缓存路径。
    /// - Note: 该方法不验证标识符有效性，请务必保证为合法的路径名。
    ///
    /// - Parameter identifier: 缓存的标识符。
    /// - Returns: 缓存文件的存储路径。
    open func filePath(forIdentifier identifier: String) -> String {
        return "\(rootPath)/\(identifier)"
    }
    
    open override var description: String {
        return "XZKit.CacheManager(domain: \(domain), storage: \(storage), directory: \(rootPath))"
    }
    
    /// 指定的标识符是否存在缓存文件。
    ///
    /// - Parameter identifier: 缓存标识符。
    /// - Returns: 缓存文件是否存在。
    open func dataExists(forIdentifier identifier: String) -> Bool {
        return FileManager.default.fileExists(atPath: filePath(forIdentifier: identifier))
    }
    
    /// 存储缓存数据，本方法会先删除已存在的缓存。
    ///
    /// - Parameters:
    ///   - data: 缓存数据。
    ///   - identifier: 缓存标识符。
    /// - Returns: 是否缓存成功。
    @discardableResult
    open func setData(_ data: Data?, forIdentifier identifier: String) -> Bool {
        guard let data = data else {
            return self.removeData(forIdentifier: identifier)
        }
        let filePath = self.filePath(forIdentifier: identifier)
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                NSLog("Remove the old file failed.")
                return false
            }
        }
        return FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
    }
    
    /// 获取缓存数据。
    ///
    /// - Parameter identifier: 缓存标识符
    /// - Returns: 缓存数据。
    open func data(forIdentifier identifier: String) -> Data? {
        return FileManager.default.contents(atPath: identifier)
    }
    
    /// 移除指定缓存标识符对应的缓存数据。
    ///
    /// - Parameter identifier: 缓存标识符。
    /// - Returns: 是否移除成功。
    @discardableResult
    open func removeData(forIdentifier identifier: String) -> Bool {
        let filePath = self.filePath(forIdentifier: identifier)
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                NSLog("Remove cached data for identifier `%@` failed.", identifier)
                return false
            }
        }
        return true
    }
    
    /// 移除所有缓存数据。
    public func removeAllData() {
        do {
            try FileManager.default.removeItem(atPath: rootPath)
            try FileManager.default.createDirectory(atPath: rootPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            NSLog("Clean the caches failed.")
        }
    }
    
}


extension FileManager {
    
    /// 在指定路径下，根据指定文件名和拓展名，生成一个不与已有文件或文件夹重复的文件路径。
    ///
    /// - Parameters:
    ///   - fileName: 文件名。
    ///   - fileType: 文件拓展名。
    ///   - rootPath: 文件目录路径。
    /// - Returns: 可用的文件路径。
    public func availablePath(forFile fileName: String, ofType fileType: String, inPath rootPath: String) -> String {
        var filePath = "\(rootPath)/\(fileName).\(fileType)"
        var flag     = 0
        while fileExists(atPath: filePath, isDirectory: nil) {
            filePath = "\(rootPath)/\(fileName)_\(flag).\(fileType)"
            flag += 1
        }
        return filePath
    }
    
    /// 在指定路径下，根据指定名称创建一个不与已有文件或文件夹重复的字路径（如果已存在则自动重命名），并返回路径。
    /// ```
    /// // 在 /user/desktop 目录下，根据名称 Image 生成一个可用的新目录。
    /// print(XZDirectoryGenerate("/user/desktop", "Image"))
    /// // 如果在 /user/desktop 目录下已有名为 Image 的文件，生成的目录
    /// // 可能为 /user/desktop/Image_1 ，其它情况则会正常生成 /user/desktop/Image 目录。
    /// ```
    ///
    /// - Parameters:
    ///   - superPath: 待创建目录的父目录路径，末尾不带 \/ 符号。
    ///   - directory: 待创建的目录，如 name 等。
    ///   - attributes: 目录属性，如果带创建的目录已存在，此参数忽略。
    /// - Returns: 实际创建的目录。
    public func createDirectory(_ directory: String, inPath superPath: String, attributes: [FileAttributeKey : Any]? = nil) throws -> String {
        var newPath = "\(superPath)/\(directory)"
        var flag    = 0
        var isDirectory = ObjCBool.init(false)
        var needsCreate = true
        while fileExists(atPath: newPath, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                needsCreate = false
                break
            } else {
                needsCreate = true
                newPath = "\(superPath)/\(directory)_\(flag)"
                flag += 1
            }
        }
        if needsCreate {
            try createDirectory(atPath: newPath, withIntermediateDirectories: true, attributes: attributes)
        }
        return superPath
    }
}

