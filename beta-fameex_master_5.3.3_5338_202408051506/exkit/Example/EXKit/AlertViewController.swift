//
//  AlertViewController.swift
//  EXKit_Example
//
//  Created by cwd on 2023/5/17.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EXKit
class AlertViewController: UIViewController {
    let alertTitle = "Are you sure you want to change your phone number?"
    let content = "This is the copyThis is the copyThis is the copyThis is the copyThis is the copyThis is the copy"
    let cancel = "cancel"
    let sure = "sure"
    let singlebtn = "One click Add self selection"
    let dataList = AlertType.allCases
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(150)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_H)
        }
    }
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.rowHeight = 44
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 0
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        return tableView
    }()
    
    
   

}


extension AlertViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "test")
        cell.textLabel?.text = dataList[indexPath.row].desc
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item  = dataList[indexPath.row]
        switch item{
        case .versionUpdate:
            self.versionUpdate()
           break
        case .activities:
            self.popActivitiesAlert()
            break
        case .one:
            self.pop1()
        case .two:
            self.pop2()
        case .three:
            self.pop3()
        case .four:
            self.pop4()
        case .five:
            self.pop5()
        case .six:
            self.pop6()
        case .seven:
            self.pop7()
        case .eight:
            self.pop8()
        default:
            break
        }
        
    }
}
extension AlertViewController{
    
    func pop1(){
        let alert = EXCommonAlert()
        alert.configAlert(title: alertTitle,btnLayoutStyle: .horizontal, alertCallBack: { type in
            print(type)
        })
        EXKitAlert.showAlert(alertView: alert)
    }
    func pop2(){
        let alert = EXCommonAlert()
        alert.configAlert(title: alertTitle, onlyOneBtnTitle: singlebtn, bottomOnlyOneBtn: true,  alertCallBack: { type in
            print(type)
        })
        EXKitAlert.showAlert(alertView: alert)
    }
    func pop3(){
        let alert = EXCommonAlert()
        alert.configAlert(title: alertTitle, message: content, btnLayoutStyle: .horizontal,alertCallBack: { type in
            print(type)
        })
        EXKitAlert.showAlert(alertView: alert)
    }
    func pop4(){
        let alert = EXCommonAlert()
        alert.configAlert(title: alertTitle, message: content, onlyOneBtnTitle: singlebtn, bottomOnlyOneBtn: true,alertCallBack: { type in
            print(type)
        })
        EXKitAlert.showAlert(alertView: alert)
    }
    func pop5(){
        let alert = EXCommonAlert()
        alert.configAlert(tipImage: true,title: alertTitle, message: content, btnLayoutStyle: .horizontal,alertCallBack: { type in
            print(type)
        })
        EXKitAlert.showAlert(alertView: alert)
    }
    func pop6(){
        let alert = EXCommonAlert()
        alert.configAlert(tipImage: true,title: alertTitle, message: content, onlyOneBtnTitle: singlebtn, bottomOnlyOneBtn: true,alertCallBack: { type in
            print(type)
        })
        EXKitAlert.showAlert(alertView: alert)
    }
    func pop7(){
        let alert = EXCommonAlert()
        alert.configAlert(title: alertTitle, btnLayoutStyle: .vertical,alertCallBack: { type in
            print(type)
        })
        EXKitAlert.showAlert(alertView: alert)
    }
    func pop8(){
        let alert = EXCommonAlert()
        alert.configAlert(title: alertTitle,message: content, btnLayoutStyle: .vertical,alertCallBack: { type in
            print(type)
        })
        EXKitAlert.showAlert(alertView: alert)
    }
    func versionUpdate(){
        let alert = EXNewVersionUpateAlert()
        let msg = "1.新增功能或改进现有功能的详细说明。\n2.修复了哪些已知问题或漏洞。\n3.对性能进行了哪些改进。\n4.对用户界面进行了哪些改进或优化。\n5.对安全性进行了哪些改进。\n6.对可用性进行了哪些改进。7.对兼容性进行了哪些改进。\n8.对语言或地区支持进行了哪些改进。\n9.对第三方库或框架进行了哪些更新。\n10.对其他重要信息或提示的说明."
        let msg2 = "1.新增功能或改进现有功能的详细说明。\n2.修复了哪些已知问题或漏洞。\n3.对性能进行了哪些改进。\n4.对用户界面进行了哪些改进或优化。\n5.对安全性进行了哪些改进。\n6.对可用性进行了哪些改进。7.对兼容性进行了哪些改进。\n8.对语言或地区支持进行了哪些改进。\n9.对第三方库或框架进行了哪些更新。\n10.对其他重要信息或提示的说明."
        alert.configAlert(title: "版本更新", content: msg,updateTitle: "更新",cancelTitle: "取消", forceUpdate: true, alertCallBack: { type in
            //升级
        })
        EXKitAlert.showAlert(alertView: alert)
        
    }
    func popActivitiesAlert(){
        let alert = EXOperatingActivitiesAlert()
        alert.config(title: "Grow your business with Binance Pay", content: "Reach more customers as you pay and get paid in crypto with our borderless payment technology on Binance Pay & Binance Marketplace.", image: nil)
        EXKitAlert.showAlert(alertView: alert)
    }
}
