//
//  XZDataDigester.swift
//  XZKit
//
//  Created by Xezun on 2021/2/14.
//

import Foundation


extension Data {
    
    public var md5: String {
        return XZDataDigester.digest(self, algorithm: .MD5, hexEncoding: .lowercase)
    }
    
    public var MD5: String {
        return XZDataDigester.digest(self, algorithm: .MD5, hexEncoding: .uppercase)
    }
    
    public var sha1: String {
        return XZDataDigester.digest(self, algorithm: .SHA1, hexEncoding: .lowercase)
    }
    
    public var SHA1: String {
        return XZDataDigester.digest(self, algorithm: .SHA1, hexEncoding: .uppercase)
    }
    
}

extension String {
    
    public var md5: String {
        return self.data(using: .utf8)?.md5 ?? ""
    }
    
    public var MD5: String {
        return self.data(using: .utf8)?.MD5 ?? ""
    }
    
    public var sha1: String {
        return self.data(using: .utf8)?.sha1 ?? ""
    }
    
    public var SHA1: String {
        return self.data(using: .utf8)?.SHA1 ?? ""
    }
    
}

