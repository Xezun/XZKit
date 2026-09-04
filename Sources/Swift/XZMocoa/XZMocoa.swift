//
//  XZMocoa.swift
//  XZKit
//
//  Created by Xezun on 2025/1/25.
//

import Foundation
import XZKitObjC

extension XZMocoaKind: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension XZMocoaName: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension XZMocoaKey: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

public typealias XZMocoaTableHeaderFooterView = UITableViewHeaderFooterView
public typealias XZMocoaTableHeaderView = XZMocoaTableHeaderFooterView
public typealias XZMocoaTableFooterView = XZMocoaTableHeaderFooterView

public typealias XZMocoaTableHeaderViewModel = XZMocoaTableHeaderFooterViewModel
public typealias XZMocoaTableFooterViewModel = XZMocoaTableHeaderFooterViewModel

public typealias XZMocoaTableCell = UITableViewCell;


public typealias XZMocoaCollectionCell = UICollectionViewCell;
public typealias XZMocoaCollectionSupplementView = UICollectionReusableView;

public typealias XZMocoaCollectionHeaderViewModel = XZMocoaCollectionSupplementViewModel
public typealias XZMocoaCollectionFooterViewModel = XZMocoaCollectionSupplementViewModel
