//
//  main.swift
//  Client
//
//  Created by Xezun on 2026/4/13.
//

import Foundation
import UIKit
import XZKit

@mocoa
class TestModel: NSObject, XZMocoaModel {
    
    @key
    let id: UUID = UUID()
    
    @key
    var name: String?
    
    @key
    var age: Int = 12
    
    @key
    var detail: String?
    
}

@mocoa
class TestView: UIView, XZMocoaView {
    
    @objc var name: String?
    
    // 不可选读写属性
    @bind(text: .name)
    var nameLabel: UILabel = .init()
    
    // 可选读写属性
    @bind(image: .icon)
    @link(backgroundColor: .color)
    var iconImageView: UIImageView? {
        didSet {
            viewModel?.bindTarget(iconImageView, action: #selector(setter: UIImageView.image), forKey: .icon)
            viewModel?.linkTarget(iconImageView, action: #selector(setter: UIImageView.backgroundColor), forKey: .color)
        }
    }
    
    @link(.isRefreshing, selector: #selector(TestView.beginRefreshing(_:)))
    var view: TestView = .init()
    
    @link(text: .title)
    @link(textColor: .textColor)
    var titleLabel: UILabel! = .init()
    
    @link(text: .detailText)
    @link(textColor: .textColor)
    let detailLabel: UILabel = .init()
    
    @link(image: "icon")
    let imageView: UIImageView = .init(image: nil)
    
    @link(title: "button", for: .normal)
    @link(titleColor: .textColor, for: .normal)
    let button: UIButton = .init()
    
    @link(title: "button", for: .normal)
    @link(titleColor: .textColor, for: .normal)
    var saveButton: UIButton = .init()
    
    @link
    @objc func beginRefreshing(_ isRefreshing: Bool) {
        
    }
    
    @link(.reload, selector: #selector(UITableView.reloadData))
    let tableView: UITableView = .init()
    
    @objc func buttonAction() {
        sendEvents(.click, value: "reloadButton")
    }
 
}

@mocoa
class TestViewModel: XZMocoaTableViewModel {
    
    @key
    @link
    var name: String?
    
    @link
    var min: Int = 1
    
    @key
    var age: Int = 20
    
    @key("foobar1")
    var foobar: Float = 0.0
    
    @key
    let identifier: XZMocoaViewModel = .init(model: nil)
    
    override func prepare() {
        super.prepare()
        
        let viewModel = XZMocoaViewModel.init(model: nil)
        addSubViewModel(viewModel)
        
        self.sendEvents(.reloadData, value: nil)
        
        self.sendActions(forKey: "beginRefreshing", value: kCFNull)
        
    }
    
    override func didReceive(_ events: XZMocoaEvents) {
        switch events.key {
        case .reloadData:
            self.reloadData()
        default:
            super.didReceive(events)
        }
    }
    
    @bind
    @objc func rangeDidChange(_ min: Int, _ max: Int) {
        
    }
    
}

extension NSFetchedResultsController: @retroactive XZMocoaGroupModel {}
extension NSFetchedResultsController: @retroactive XZMocoaModel {}
extension NSFetchedResultsController: @retroactive XZMocoaTableModel {
    
    @NSManaged public var mocoaName: XZMocoaName?
    
    public func mocoa(_ context: Any, numberOfSections null: Any?) -> Int {
        return self.sections?.count ?? 0;
    }
    
    public func mocoa(_ context: Any, numberOfCellsInSection section: Int) -> Int {
        guard let sections = self.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    public func mocoa(_ context: Any, modelForCellAt indexPath: IndexPath) -> Any? {
        return self.object(at: indexPath)
    }
    
    public func mocoa(_ context: Any, kind: XZMocoaKind, numberOfSupplementsInSection section: Int) -> Int {
        // 方案一：
        // 直接根据 context 类型判断，前提是未重写 XZMocoaGroupViewModel 获取数据的方法。
        if context is XZMocoaTableViewModel {
            return 1
        }
        
        // 方案二
        // 通过给数据设置不同的 mocoaName 来区分不同的情形。
        switch self.mocoaName {
        case "HeaderFooter":
            return 1
        case "None":
            return 0
        case "Header":
            return kind == .header ? 1 : 0
        case "Footer":
            return kind == .footer ? 1 : 0
        default:
            return 0
        }
        
        // 或者
        // 不实现 XZMocoaTableModel 协议，使用默认的，全部带 header 或 footer 不想显示的将高度设置为 0
    }
    
    public func mocoa(_ context: Any, kind: XZMocoaKind, modelForSupplementAt indexPath: IndexPath) -> Any? {
        return self
    }
}


public func loadGroups() {
    let Groups = #module("https://mocoa.xzkit.com/groups")
    
    let card100 = Groups["100"]
    card100.modelClass = TestModel.self;
    card100.viewClass = TestView.self
    card100.viewModelClass = TestViewModel.self
}

@mocoa
class ExampleCellModel: NSObject, XZMocoaModel {
    
    var mocoaName: XZMocoaName? {
        return "example"
    }
    
    @key var firstName: String?
    @key var lastName: String?
}

@mocoa
class ExampleCellViewModel: XZMocoaTableCellViewModel {
    
    @key
    var name: String?
    
    
    @bind
    func setupName(firstName: String?, lastName: String?) {
        name = [firstName, lastName].compactMap({ $0 }).joined(separator: " ")
        
        
    }
    
    
}

@mocoa
class ExampleCell: UITableViewCell {
    
    @bind(text: .name)
    let nameLabel: UILabel = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(nameLabel)
    }
}



class TableModel: XZMocoaTableModel {
    
    func mocoa(_ context: Any, numberOfSections null: Any?) -> Int {
        return 0;
    }
    
    func mocoa(_ context: Any, modelForCellAt indexPath: IndexPath) -> Any? {
        return nil
    }
    
    func mocoa(_ context: Any, numberOfCellsInSection section: Int) -> Int {
        return 0;
    }
    
    func mocoa(_ context: Any, kind: XZMocoaKind, numberOfSupplementsInSection section: Int) -> Int {
        return 0
    }
    
    func mocoa(_ context: Any, kind: XZMocoaKind, modelForSupplementAt indexPath: IndexPath) -> Any? {
        return nil
    }
}




