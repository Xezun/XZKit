//
//  AlertViewController.swift
//  Example
//
//  Created by mlibai on 2018/7/24.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit
import XZKit

class AlertViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Alert Style"
//        self.navigationBar.infoButton?.setTitle("Alert", for: .normal)
//        self.navigationBar.infoButton?.addTarget(self, action: #selector(infoButtonAction(_:)), for: .touchUpInside)
        
        view.backgroundColor = .white
    }
    
    @objc private func infoButtonAction(_ button: UIButton) {
        let action1 = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        action1.textColor = .red
        //action1.isPreferred = true
        let action2 = UIAlertAction.init(title: "Default", style: .default, handler: nil)
        action2.textColor = .green
        //action2.isPreferred = true

        let alertVC = UIAlertController.init(title: "This is title!", message: "This is message", preferredStyle: .alert)
        alertVC.addAction(action1)
        alertVC.addAction(action2)
        
        alertVC.attributedTitle = NSAttributedString.init(string: "This is a Title!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.brown])
        alertVC.attributedMessage = NSAttributedString.init(string: "Attributed message display now!", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12.0),
            NSAttributedString.Key.foregroundColor: UIColor.cyan
            ])
        
        alertVC.addTextField(configurationHandler: { (textField) in
            textField.borderStyle = .none
            textField.isEnabled = false
            textField.text = "Wrong Address"
            textField.textColor = UIColor.black
            textField.font = UIFont.systemFont(ofSize: 14.0)
            textField.background = UIImage()
            textField.disabledBackground = UIImage()
        })
        
        alertVC.addTextField(configurationHandler: { (textField) in
            textField.borderStyle = .none
            textField.isEnabled = false
            textField.text = "Wrong product option or quantity"
            textField.textColor = UIColor.black
            textField.font = UIFont.systemFont(ofSize: 14.0)
            textField.background = UIImage()
            textField.disabledBackground = UIImage()
        })
        
        alertVC.addTextField(configurationHandler: { (textField) in
            textField.borderStyle = .none
            textField.isEnabled = false
            textField.text = "No proper payment method for me This is long"
            textField.textColor = UIColor.black
            textField.font = UIFont.systemFont(ofSize: 14.0)
            textField.background = UIImage()
            textField.disabledBackground = UIImage()
        })
        
        self.present(alertVC, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
