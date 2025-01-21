//
//  LoginViewController.swift
//  ShengwangChatApiExample
//
//  Created by 朱继超 on 1/16/25.
//

import UIKit
import AgoraChat

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userField: UITextField!
    
    @IBOutlet weak var tokenField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginButton.layer.cornerRadius = 4
        loginButton.clipsToBounds = true
    }


    @IBAction func loginAction(_ sender: Any) {
        AgoraChatClient.shared().logout(false)
        //token generate：https://console-pre.shengwang.cn/product/IM?tab=IMOperation
        guard let user = userField.text, let token = tokenField.text else {
            return
        }
        AgoraChatClient.shared().login(withUsername: user, token: token) { (userId,error) in
            if error == nil {
                NotificationCenter.default.post(name: Notification.Name("AgoraChatLogin"), object: nil)
            } else {
                assert(false, "login error:\(error?.errorDescription ?? "")")
            }
        }
    }
    
    
}

