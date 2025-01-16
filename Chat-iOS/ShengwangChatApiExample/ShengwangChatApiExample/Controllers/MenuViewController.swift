//
//  MenuViewController.swift
//  ShengwangChatApiExample
//
//  Created by 朱继超 on 1/16/25.
//

import UIKit
import ZSwiftBaseLib

import AgoraChat

final class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,AgoraChatClientDelegate {
    
    private var data = ["Send text message","Send image message","Send Voice message","Join a group","Log out"]
    
    private lazy var functionList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: ZNavgationHeight, width: ScreenWidth, height: ScreenHeight-ZNavgationHeight), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(50)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.functionList])
        self.view.backgroundColor = .white
        self.refreshHeader()
        AgoraChatClient.shared().add(self, delegateQueue: .main)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshHeader()
    }
    
    deinit {
        AgoraChatClient.shared().removeDelegate(self)
    }

}

extension MenuViewController {
    private func refreshHeader() {
        if !(AgoraChatClient.shared().currentUsername ?? "").isEmpty {
            self.functionList.tableHeaderView = UILabel(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 30)).text("current user is:\(AgoraChatClient.shared().currentUsername ?? "")").textAlignment(.center)
        }
    }
    //MARK: - UITableViewDelegate&UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "666")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "666")
        }
        let text = self.data[safe: indexPath.row]
        cell?.textLabel?.text = text
        cell?.accessoryType = (text == "Log out" ? .none:.disclosureIndicator)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var VC: UIViewController?
        let text = self.data[safe: indexPath.row]
        switch text {
        case "Log out": self.logoutAction()
        default:
            VC = AgoraChatConversationsViewController()
            VC?.title = text
        }
        if VC != nil {
            VC?.title = self.data[safe: indexPath.row]
            self.navigationController?.pushViewController(VC!, animated: true)
        }
    }
    
    private func logoutAction() {
        AgoraChatClient.shared().logout(false) { error in
            if error == nil {
                self.removeHeader()
            } else {
                assert(false, "logout failed:\(error?.errorDescription ?? "")")
            }
        }
    }
    
    private func removeHeader() {
        DispatchQueue.main.async {
            guard let del = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            self.functionList.tableHeaderView = nil
            NotificationCenter.default.post(name: Notification.Name("AgoraChatLogout"), object: nil)
        }
    }
    
    //MARK: - AgoraChatClientDelegate
    func tokenWillExpire(_ aErrorCode: AgoraChatErrorCode) {
        if aErrorCode == .tokeWillExpire {
            //refresh token
            AgoraChatClient.shared().renewToken("request token from app server")
        }
    }

}
