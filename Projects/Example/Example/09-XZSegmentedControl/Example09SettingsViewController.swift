//
//  Example09SettingsViewController.swift
//  Example
//
//  Created by Xezun on 2024/6/28.
//

import UIKit
import XZKit


class Example09SettingsViewController: UITableViewController {
    
    var segmentedControl: XZSegmentedControl?
    
    @IBOutlet weak var interitemSpacingControl: UISegmentedControl!
    @IBOutlet weak var headerSwitch: UISwitch!
    @IBOutlet weak var footerSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        if let segmentedControl = segmentedControl {
            interitemSpacingControl.setTitle("\(Int(segmentedControl.interitemSpacing ))", forSegmentAt: 1)
            headerSwitch.isOn = segmentedControl.headerView != nil
            footerSwitch.isOn = segmentedControl.footerView != nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = "\(segmentedControl?.indicatorSize ?? .zero)"
            case 1:
                switch segmentedControl?.indicatorStyle {
                case .markLine:
                    cell.detailTextLabel?.text = ".markLine"
                case .noteLine:
                    cell.detailTextLabel?.text = ".noteLine"
                case .custom:
                    cell.detailTextLabel?.text = ".custom"
                default:
                    fatalError()
                }
            case 2:
                if let indicatorColor = segmentedControl?.indicatorColor {
                    cell.detailTextLabel?.text = "◼︎"
                    cell.detailTextLabel?.textColor = indicatorColor
                } else {
                    cell.detailTextLabel?.text = "nil"
                    cell.detailTextLabel?.textColor = .black
                }
            case 3:
                if let image = segmentedControl?.indicatorImage {
                    if #available(iOS 13.0, *) {
                        let att = NSTextAttachment.init(image: image)
                        cell.detailTextLabel?.attributedText = .init(attachment: att);
                    } else {
                        let data = image.pngData()
                        let att = NSTextAttachment.init(data: data, ofType: "image/png")
                        cell.detailTextLabel?.attributedText = .init(attachment: att);
                    }
                    
                } else {
                    cell.detailTextLabel?.text = "nil"
                }
            default:
                fatalError()
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = "\(segmentedControl?.itemSize ?? .zero)"
            case 1:
                cell.detailTextLabel?.text = "\(segmentedControl?.interitemSpacing ?? 0)"
            default:
                fatalError()
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = segmentedControl?.headerView == nil ? "未设置" : "已设置"
            case 1:
                cell.detailTextLabel?.text = segmentedControl?.footerView == nil ? "未设置" : "已设置"
            default:
                fatalError()
            }
        default:
            fatalError()
        }
        return cell
    }
    
    @IBAction func unwindToSubmitIndicatorSize(_ unwindSegue: UIStoryboardSegue) {
        guard let sourceViewController = unwindSegue.source as? Example09SettingsSizeViewController else { return }
        segmentedControl?.indicatorSize = sourceViewController.value
        
        _ = tableView(tableView, cellForRowAt: .init(row: 0, section: 0))
    }
    
    @IBAction func unwindToSubmitIndicatorStyle(_ unwindSegue: UIStoryboardSegue) {
        guard let sourceViewController = unwindSegue.source as? Example09SettingsSelectViewController else { return }
        switch sourceViewController.value {
        case "noteLine":
            segmentedControl?.indicatorStyle = .noteLine
        case "markLine":
            segmentedControl?.indicatorStyle = .markLine
        case "custom":
            segmentedControl?.indicatorStyle = .custom
            segmentedControl?.indicatorClass = Example09SegmentedControlIndicator.self
        default:
            break
        }
        _ = tableView(tableView, cellForRowAt: .init(row: 1, section: 0))
    }
    
    @IBAction func unwindToSubmitIndicatorColor(_ unwindSegue: UIStoryboardSegue) {
        guard let sourceViewController = unwindSegue.source as? Example09SettingsColorSelectViewController else { return }
        segmentedControl?.indicatorColor = sourceViewController.value
        _ = tableView(tableView, cellForRowAt: .init(row: 2, section: 0))
    }
    
    @IBAction func unwindToSubmitIndicatorImage(_ unwindSegue: UIStoryboardSegue) {
        guard let sourceViewController = unwindSegue.source as? Example09SettingsImageSelectViewController else { return }
        segmentedControl?.indicatorImage = sourceViewController.value
        _ = tableView(tableView, cellForRowAt: .init(row: 3, section: 0))
    }
    
    @IBAction func unwindToSubmitItemSize(_ unwindSegue: UIStoryboardSegue) {
        guard let sourceViewController = unwindSegue.source as? Example09SettingsSizeViewController else { return }
        segmentedControl?.itemSize = sourceViewController.value
        _ = tableView(tableView, cellForRowAt: .init(row: 0, section: 1))
    }
    
    @IBAction func interitemSpacingControlValueChanged(_ sender: UISegmentedControl) {
        guard let segmentedControl = segmentedControl else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            if segmentedControl.interitemSpacing > 0 {
                segmentedControl.interitemSpacing -= 1
            }
        case 1:
            break
        case 2:
            segmentedControl.interitemSpacing += 1;
        default:
            break
        }
        sender.selectedSegmentIndex = UISegmentedControl.noSegment
        
        sender.setTitle("\(Int(segmentedControl.interitemSpacing))", forSegmentAt: 1)
    }
    
    @IBAction func headerSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            let headerView = UIButton.init(type: .system)
            headerView.setTitle(" + ", for: .normal)
            headerView.backgroundColor = .white
            headerView.frame.size = CGSize.init(width: 40, height: 40)
            segmentedControl?.headerView = headerView
        } else {
            segmentedControl?.headerView = nil
        }
    }
    
    @IBAction func footerSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            let footerView = UIButton.init(type: .system)
            footerView.setTitle(" - ", for: .normal)
            footerView.backgroundColor = .white
            footerView.frame.size = CGSize.init(width: 40, height: 40)
            segmentedControl?.footerView = footerView
        } else {
            segmentedControl?.footerView = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segmentedControl = segmentedControl else { return }
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "indicatorSize":
            (segue.destination as? Example09SettingsSizeViewController)?.value = segmentedControl.indicatorSize
        case "indicatorStyle":
            switch segmentedControl.indicatorStyle {
            case .noteLine:
                (segue.destination as? Example09SettingsSelectViewController)?.value = "noteLine"
            case .markLine:
                (segue.destination as? Example09SettingsSelectViewController)?.value = "markLine"
            case .custom:
                (segue.destination as? Example09SettingsSelectViewController)?.value = "custom"
            default:
                break
            }
        case "indicatorImage":
            (segue.destination as? Example09SettingsImageSelectViewController)?.value = segmentedControl.indicatorImage
        case "indicatorColor":
            (segue.destination as? Example09SettingsColorSelectViewController)?.value = segmentedControl.indicatorColor
        case "itemSize":
            (segue.destination as? Example09SettingsSizeViewController)?.value = segmentedControl.itemSize
        default:
            break
        }
    }

}


