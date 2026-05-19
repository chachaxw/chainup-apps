//
//  EXSetLanguageV.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import Swap

class EXSetLanguageV: UIView {
    
    static func getViewHeight(count:Int) -> CGFloat{
        if count == 0 {
            return Device_H
        }
       var h = 16 + 28 + 20 //head
       h += 60 * count
       h += 60
       h += (isiPhoneX ? 34 : 0 )
       return CGFloat(h)
    }
    var dataArray:[AppCfgLanListItem] = []
    var selectedItem:AppCfgLanListItem?
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    ///Title
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: "customSetting_action_language".localized(), font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var cancelbtn:UIButton = {
        let btnBuy = UIButton(type: .custom)
        btnBuy.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btnBuy.setTitle("common_text_btnCancel".localized(), for: .normal)
        btnBuy.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btnBuy.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .selected)
        btnBuy.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        btnBuy.setEnlargeEdgeWithTop(10, left: 20, bottom: 10, right: 20)
        btnBuy.isSelected = true
        return btnBuy
    }()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXSetLanguageTC.classForCoder()], ["EXSetLanguageTC"])
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([titleLabel,cancelbtn,tableView])
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
            make.height.equalTo(28)
            make.right.lessThanOrEqualToSuperview()
        }
        cancelbtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
//            make.width.equalTo(60)
            make.height.equalTo(20)
            make.centerY.equalTo(titleLabel)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-60)
        }
    }
   
    func setData(){
        dataArray = EXAppConfigManager.sharedInstance.getLanListAll().map({
            let obj = AppCfgLanListItem()
            obj.name = $0.name
            obj.id = $0.id
            return obj
        })
            setSelectLan(lan: LanguageHandler.priviatePhoneLanguage)
    }
    
    func setSelectLan(lan: String){
        for item in dataArray{
            item.selected = (item.id == lan)
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func cancel() {
        self.yy_viewController?.dismiss(animated: true, completion: nil)
    }
}

extension EXSetLanguageV : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = dataArray[indexPath.row]
        let cell : EXSetLanguageTC = tableView.dequeueReusableCell(withIdentifier: "EXSetLanguageTC") as! EXSetLanguageTC
        cell.setCell(entity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Record the selected language
        let lanItem = dataArray[indexPath.row]
        guard !lanItem.selected else { return }
        setSelectLan(lan: lanItem.id)
        tableView.reloadData()
        XUserDefault.setUseChooseLan(true)
        EXAppConfigManager.sharedInstance.changLan = true
        //SAAS logic, if downloading, switch to language after completion
        if LanguageTools.shareInstance.isOnlineLanSupported(lanId: lanItem.id) != nil {
            //Need to download, complete the download and refresh the app
            self.showLoading1()
            LanguageTools.shareInstance.tryDownloadCurrentLan(lanID: lanItem.id) {[weak self] success in
                self?.hideLoading1()
                self?.reload_app(language: lanItem.id)
            }
        }else {
            //Directly using local language packs
            reload_app(language: lanItem.id)//Load directly without downloading
        }
    }
    
    @objc func reload_app(language:String){
        //Current direct switching, online download and post switching
        guard EXLanguage.updateCurrentLanguage(to: language) else {
            setSelectLan(lan: LanguageHandler.priviatePhoneLanguage)
            tableView.reloadData()
            return
        }
        EXLanguageTools.shareInstance.setLanguage(langeuage: language)
        updateSwapPublicInfo()
        EXAppLaunchConfig.upDateEXKitConfig()
        restart()
    }
    
    func restart(){ //when config info failed
        let window = UIApplication.shared.keyWindow
        let nav = AppDelegate().initNavBarV()
        window?.rootViewController = nav
    }
    
    private func updateSwapPublicInfo(){
        EXContractNetwork.queryPublicInfo { _ in
        } failure: { _ in
        }
        
    }
}


