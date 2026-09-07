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
    var name = "John"
}

@mocoa
class TestView: UIView, XZMocoaView {
    
    @bind(.name)
    @bind(.textColor)
    let nameLabel: UILabel = .init()
    
    @bind(.name.detailText)
    let pathLabel: UILabel = .init()
    
    @bind("icon")
    let imageView: UIImageView = .init(image: nil)
    
    @bind(title: "name", for: .normal)
    @bind(.textColor)
    let button: UIButton = .init()
    
    @bind(.backgroundColor)
    let view: TestView = .init()
    
    @objc dynamic var name: String?
    
    @objc func foobar(_ name: String?) {
        guard let viewModel = self.viewModel else { return }
        
        viewModel.addTarget(nameLabel, action: #selector(setter: UILabel.text), forKey: .text, value: nil)
        viewModel.addTarget(self, action: #selector(beginRefreshing), forKey: "beginRefreshing")
    }
    
    @objc func beginRefreshing() {
        
    }
    
    @bind(.reload, selector: #selector(UITableView.reloadData))
    let tableView: UITableView = .init()
    
    @objc func buttonAction() {
        sendEvents(.click, value: "reloadButton")
    }
    
    @bind(.image)
    @bind(.backgroundColor)
    var iconImageView: UIImageView!
    
    @bind(image: .image)
    var iconImageView2: UIImageView?
 
}

@mocoa
class TestViewModel: XZMocoaTableViewModel {
    
    required init(model: Any?) {
        self.identifier = String(describing: model)
        super.init(model: model)
    }
    
    override var shouldObserveModelKeysActively: Bool {
        return true
    }
    
    let identifier: String
    
    override var hash: Int {
        return (identifier as NSString).hash
    }
    
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
    
    @key
    var name: String = "John"
    
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
    let Groups = #mocoa("https://mocoa.xzkit.com/groups/")
    
    let card100 = Groups["100"]
    card100.modelClass = TestModel.self;
    card100.viewClass = TestView.self
    card100.viewModelClass = TestViewModel.self
}



