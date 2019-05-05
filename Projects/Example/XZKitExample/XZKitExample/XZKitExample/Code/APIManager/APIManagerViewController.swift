

import UIKit
import XZKit

final class APIManagerViewController: UITableViewController, NavigationBarCustomizable {
    
    deinit {
        XZLog("\(type(of: self)) is dealloc.");
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(style: .grouped)
        self.hidesBottomBarWhenPushed = true;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var api = ExampleAPIManager.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.title = "APINetworking"
        self.navigationBar.backButton?.setTitle("返回", for: .normal)
        self.navigationBar.backButton?.sizeToFit()
        self.navigationBar.backButton?.setTitleColor(.black, for: .normal)
        
        self.navigationBar.infoButton?.setTitle("查询", for: .normal)
        self.navigationBar.infoButton?.addTarget(self, action: #selector(infoButtonAction(_:)), for: .touchUpInside)
        self.navigationBar.infoButton?.sizeToFit()
        self.navigationBar.infoButton?.setTitleColor(.black, for: .normal)
        
        self.tableView.rowHeight = 44
        self.tableView.estimatedRowHeight = 0
        self.tableView.allowsMultipleSelection = true
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func infoButtonAction(_ button: UIButton) -> Void {
        self.dataArray.removeAll()
        self.tableView.reloadData()
        api.delegate = self;
        api.weather(of: "BeiJing", policy: self.policy)
        api.weather(of: "ShangHai", policy: self.policy)
        api.weather(of: "WuHan", policy: self.policy)
        api.weather(of: "ShenZhen", policy: self.policy)
    }
    
    var policy = APIConcurrency.Policy.default
    
    var dataArray: [[String]] = []
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return dataArray[section - 1].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch indexPath.section {
        case 0:
            cell.accessoryType   = .disclosureIndicator
            cell.textLabel!.text = "并发方式：" + String.init(describing: self.policy)
        default:
            cell.accessoryType = .none
            cell.textLabel!.text = dataArray[indexPath.section - 1][indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 0 else {
            return nil
        }
        let footerView = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 375, height: 12))
        footerView.text = "     查询北京、上海、武汉、深圳的天气。"
        footerView.font = UIFont.systemFont(ofSize: 9.0)
        footerView.textColor = UIColor.lightGray
        return footerView
    }
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let policyVC = APIConcurrencyPolicyViewController.init(self.policy)
            policyVC.delegate = self
            self.navigationController?.pushViewController(policyVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}

extension APIManagerViewController: APIConcurrencyPolicyViewControllerDelegate {
    
    func viewController(_ viewController: APIConcurrencyPolicyViewController, didSelect policy: APIConcurrency.Policy) {
        self.policy = policy
        self.dataArray.removeAll()
        self.tableView.reloadData()
    }
    
}

extension APIManagerViewController: ExampleAPIManagerDelegate {
    
    func apiManager(_ apiManager: ExampleAPIManager, request: ExampleAPIRequest, didFailWith error: Error) {
        XZLog("获取 %@ 天气信息失败：%@！", request.city, error)
        self.dataArray.append(["获取 \(request.city) 天气信息失败：\(error)！"])
    }
    
    func apiManager(_ apiManager: ExampleAPIManager, request: ExampleAPIRequest, didFinishWith apiResponse: ExampleAPIResponse) {
        XZLog("城市：%@\n天气：%@\n温度：%@˚\n日期：%@",
              apiResponse.location.name,
              apiResponse.weather.text,
              apiResponse.weather.temperature,
              apiResponse.date
        )
        self.dataArray.append([
            "城市：" + apiResponse.location.name,
            "天气：" + apiResponse.weather.text,
            "温度：" + apiResponse.weather.temperature + "°C",
            "日期：" + apiResponse.date])
        
        self.tableView.reloadData()
    }
    

}



