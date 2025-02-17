//
//  XZObjcDescriptor.swift
//  XZObjcDescriptor
//
//  Created by 徐臻 on 2025/1/30.
//

import Foundation

#if SWIFT_PACKAGE
@_exported import XZObjcDescriptorObjC
#endif

extension XZObjcType {
    
    public var isScalarNumber: Bool {
        return __XZObjcIsScalarNumber(self)
    }
    
}
