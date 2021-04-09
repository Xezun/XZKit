//
//  XZDataDigester.swift
//  XZKit
//
//  Created by Xezun on 2021/2/14.
//

import Foundation

extension Data {
    
    public var md5: String {
        return DataDigester.digest(self, algorithm: .MD5, hexEncoding: .lowercase)
    }
    
    public var MD5: String {
        return DataDigester.digest(self, algorithm: .MD5, hexEncoding: .uppercase)
    }
    
    public var sha1: String {
        return DataDigester.digest(self, algorithm: .SHA1, hexEncoding: .lowercase)
    }
    
    public var SHA1: String {
        return DataDigester.digest(self, algorithm: .SHA1, hexEncoding: .uppercase)
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

extension Data {
    
    public class Digester {
        public struct Algorithm {
//            case md5
//            case sha1
//            case sha256
//            case sha384
//            case sha512
            let length: Int32
            
//            switch self {
//            case .md5:
//                return CC_MD5_DIGEST_LENGTH
//            case .sha1:
//                return CC_SHA1_DIGEST_LENGTH
//            case .sha256:
//                return CC_SHA256_DIGEST_LENGTH
//            case .sha384:
//                return CC_SHA384_DIGEST_LENGTH
//            case .sha512:
//                return CC_SHA512_DIGEST_LENGTH
//            }
            
            var initializer: (UnsafeMutableRawPointer?) -> Void {
                return CC_MD5_Init
            }
            
        }
    }
}
