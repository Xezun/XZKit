//
//  XZImageCacheManager.swift
//  XZKit
//
//  Created by mlibai on 2018/6/11.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit

public let ImageCacheStorage = "image"

extension CacheManager.Domain {
    
    public static let XZKit = CacheManager.Domain.init(rawValue: "com.mlibai.XZKit.CacheManager")
}

extension CacheManager.Storage {
    
    public static let image = CacheManager.Storage.init(rawValue: "image")
}

/// 图片缓存。
@objc(XZImageCacheManager)
final public class ImageCacheManager: CacheManager {
    
    /// XZKit 默认的图片缓存。
    @objc(defaultManager)
    public static let `default` = try! ImageCacheManager.init(domain: .XZKit, storage: .image)
    
    @objc(XZImageCacheType)
    public enum ImageType: Int, CustomStringConvertible {
        @objc(XZImageCacheTypePNG)
        case png
        @objc(XZImageCacheTypeJPG)
        case jpg
        public var description: String {
            switch self {
            case .png: return "png"
            case .jpg: return "jpg"
            }
        }
    }
    
    @objc(identifierForImageName:type:scale:)
    public func identifier(for imageName: String, type: ImageType, scale: CGFloat) -> String {
        return "\(imageName)@\(Int(scale))x.\(type.description)"
    }
    
    @objc(imageNamed:type:scale:)
    public func image(named imageName: String, type: ImageType = .png, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let identifier = self.identifier(for: imageName, type: type, scale: scale)
        return UIImage.init(named: self.filePath(forIdentifier: identifier))
    }
    
    @discardableResult
    @objc(cacheImage:name:type:scale:)
    public func cache(_ image: UIImage?, name: String, type: ImageType = .png, scale: CGFloat = UIScreen.main.scale) -> Bool {
        let identifier = self.identifier(for: name, type: type, scale: scale)
        guard let image = image else {
            return self.removeData(forIdentifier: identifier)
        }
        if let data = image.pngData() {
            return self.setData(data, forIdentifier: identifier)
        } else if let data = image.jpegData(compressionQuality: 1.0) {
            return self.setData(data, forIdentifier: identifier)
        }
        return false
    }
    
    /// 匹配图片名称中的拓展名，如 @2x.png 等。
    private static let regularExpression = try! NSRegularExpression.init(pattern: "(@[1-9]+x)*.[a-z]+$", options: .caseInsensitive)
    
    /// 图片 URL 生成标识符。
    ///
    /// - Parameter imageURL: 图片 URL 。
    /// - Returns: 图片缓存标识符。
    @objc(identifierForImageURL:)
    public func identifier(for imageURL: URL) -> String {
        let fileFullName = imageURL.lastPathComponent as NSString
        if let match = ImageCacheManager.regularExpression.firstMatch(in: fileFullName as String, options: .init(rawValue: 0), range: NSMakeRange(0, fileFullName.length)) {
            let fileExt = fileFullName.substring(with: match.range)
            return imageURL.absoluteString.md5 + fileExt
        }
        return imageURL.absoluteString.md5 + ".img"
    }
    
    /// 缓存指定 URL 对应的图片数据。
    ///
    /// - Parameters:
    ///   - imageData: 图片数据。
    ///   - imageURL: 图片地址。
    /// - Returns: 是否缓存成功。
    @discardableResult
    @objc(cacheImageData:forImageURL:)
    public func cache(_ imageData: Data?, for imageURL: URL) -> Bool {
        return setData(imageData, forIdentifier: self.identifier(for: imageURL))
    }
    
    @objc(imageForImageURL:)
    public func image(for imageURL: URL) -> UIImage? {
        let identifier = self.identifier(for: imageURL)
        guard let imageData = self.data(forIdentifier: identifier) else { return nil }
        return UIImage.init(data: imageData)
    }
    
}

