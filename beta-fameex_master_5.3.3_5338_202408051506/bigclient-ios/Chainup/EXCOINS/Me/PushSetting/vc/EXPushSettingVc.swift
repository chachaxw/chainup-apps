//
//  EXPushSettingVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXPushSettingVc: NavCustomVC {
    
    var rowData:EXPushSettingModel = EXPushSettingModel()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXSetTC.classForCoder()], ["EXSetTC"])
        tableView.register(UINib (nibName: "EXSwitchFilterCell", bundle: nil), forCellReuseIdentifier: "EXSwitchFilterCell")
        
        return tableView
    }()
    
    override func setNavCustomV() {
        self.setTitle(LanguageTools.getString(key: "customSetting_action_pushSetting"))
        self.xscrollView = tableView
        self.lastVC = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.navCustomView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        getSettings()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(becomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func becomeActive() {
        tableView.reloadData()
    }
    
    
    func getSettings() {
        appApi.rx.request(.userPushSwitch)
            .MJObjectMap(EXPushSettingModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let settingModel):
                    self?.handleModel(settingModel)
                    break
                case .failure(_):
                    break
                }
        }.disposed(by: self.disposeBag)
    }
    
    func handleModel(_ model:EXPushSettingModel) {
        self.rowData = model
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension EXPushSettingVc : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowData.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.rowData.list[indexPath.row]
        //System main switch
        if item.type == "all" {
            let entity = EXSetEntity()
            entity.name = item.title
            entity.rightName = EXGeTuiHandler.shared.getAuthorizationStatusAllowed() ? "personal_text_safeSettingOpen".localized() : "personal_text_safeSettingOff".localized()
            let cell : EXSetTC = tableView.dequeueReusableCell(withIdentifier: "EXSetTC") as! EXSetTC
            cell.setCell(entity)
            return cell
        }else {
            let model = EXFilterDataModel()
            model.title = item.title
            let cell : EXSwitchFilterCell = tableView.dequeueReusableCell(withIdentifier: "EXSwitchFilterCell") as! EXSwitchFilterCell
            cell.exSwitch.isHidden = (rowData.status == "0")
            cell.itemDidSwitchBlock = {[weak self] isON in
                self?.handleSwitchOption(isON, item)
            }
            cell.bindModel(model, lastValue: item.value)
            return cell
        } 
    }
    
    func handleSwitchOption(_ isOn:Bool , _ model:EXPushListItem) {
        appApi.rx.request(.saveAppPushUser(type:model.type))
            .MJObjectMap(EXVoidModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(_):
                    EXAlert.showSuccess(msg: "common_tip_editSuccess".localized())
                    model.value = isOn ? "1" : "0"
                    self?.tableView.reloadData()
                    break
                case .failure(_):
                    model.value = isOn ? "0" : "1"
                    self?.tableView.reloadData()
                    break
                }
        }.disposed(by: self.disposeBag)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.rowData.list[indexPath.row]
        if item.type == "all" {
            //Todo system settings
            if let setting = URL.init(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(setting) {
                    UIApplication.shared.open(setting) { (success) in}
                }
            }
        }
    }
    
    
}


