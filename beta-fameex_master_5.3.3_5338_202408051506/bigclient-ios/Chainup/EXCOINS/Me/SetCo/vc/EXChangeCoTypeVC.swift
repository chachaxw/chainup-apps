////
////  EXChangeCoTypeVC.swift
////  Chainup
////
////  Created by liuxuan on 2023/11/6.
////  Copyright © 2023 Chainup. All rights reserved.
////
//
//import UIKit
//import SwiftyDrop
//
//class EXChangeCoTypeVC: NavCustomVC {
//
//    lazy var coChagneTable : UITableView = {
//        let tableView = UITableView()
//        tableView.extUseAutoLayout()
//        tableView.extSetTableView(self, self)
//        tableView.extRegistCell([EXSetLanguageTC.classForCoder()], ["EXSetLanguageTC"])
//        return tableView
//    }()
//    
//    func rowDatas() -> [AppCfgLanListItem] {
//        let old = AppCfgLanListItem.init()
//        old.name = "customSetting_text_coOld".localized()
//        old.selected = EXAppConfigManager.sharedInstance.getContractVersion() == .old
//        
//        let new = AppCfgLanListItem.init()
//        new.name = "customSetting_text_coNew".localized()
//        new.selected = EXAppConfigManager.sharedInstance.getContractVersion() == .new
//        
//        return [old,new]
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        contentView.addSubview(coChagneTable)
//        coChagneTable.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//        // Do any additional setup after loading the view.
//    }
//    
//    override func setNavCustomV() {
//        self.setTitle("customSetting_action_changeCo".localized())
//        self.xscrollView = self.coChagneTable
//        self.lastVC = true
//    }
//}
//
//extension EXChangeCoTypeVC : UITableViewDelegate,UITableViewDataSource{
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 52
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return rowDatas().count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let entity = rowDatas()[indexPath.row]
//        let cell : EXSetLanguageTC = tableView.dequeueReusableCell(withIdentifier: "EXSetLanguageTC") as! EXSetLanguageTC
//        cell.setCell(entity)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let entity = rowDatas()[indexPath.row]
//        if entity.selected == true {
//            return
//        }
//        
//        let alert:EXNormalAlert = EXNormalAlert()
//        alert.configAlert(title: "common_text_tip".localized(), message: "newContract_changeCo_desc".localized())
//        alert.alertCallback = {[weak self] action in
//            if action == 0 {
//                self?.changeCo(idx: indexPath.row)
//            }
//        }
//        EXAlert.showAlert(alertView: alert)
//        
////        let type:EXAppContractType = indexPath.row == 0 ? .old : .new
////        if type == .old {
////            EXAppCache.sharedCache.updateContractType(type: .old)
////        }else{
////            EXAppCache.sharedCache.updateContractType(type: .new)
////        }
//        
//        
////        let window = UIApplication.shared.keyWindow
////        let nav = AppDelegate().initNavBarV()
////        window?.rootViewController = nav
////
////
////Let status=type==. old? Successfully switched old contract ". localized():" Successfully switched new contract ". localized()
////        EXAlert.showSuccess(msg: status)
////        SLContractSocketManager.shared().srWebSocketClose()
////
//////Clear new contract drawer
////        EXSwapSocketManager.shared.disconnectServer()
////        EXSwapDrawerView.clearSharedInstance()
//////Clear the public use of new and old contracts
////        SLPublicSwapInfo.sharedInstance()?.setSwapInfo([])
////
////        SLPublicSwapInfo.sharedInstance()?.clearOrderBooks()
////        SLPublicSwapInfo.sharedInstance()?.setLatestTrades([])
////
////        //Old contract
////        if type == .old {
//////            EXAppCache.sharedCache.updateContractType(type: .old)
////            AppDelegate().changeHosts()
////        }else{
//////            EXAppCache.sharedCache.updateContractType(type: .new)
////            AppDelegate().reloadNewContractPublic()
////        }
//
//    }
//    
//    func changeCo(idx:Int) {
//        let type:EXAppContractType = idx == 0 ? .old : .new
//        if type == .old {
//            EXAppCache.sharedCache.updateContractType(type: .old)
//        }else{
//            EXAppCache.sharedCache.updateContractType(type: .new)
//        }
//        //Forced crash, restart
//        let arr = ["0","1"]
//        arr[2]
//    }
//
//}
//

