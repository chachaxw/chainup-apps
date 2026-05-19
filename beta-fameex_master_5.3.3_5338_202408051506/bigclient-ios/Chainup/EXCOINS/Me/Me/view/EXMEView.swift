//
//  EXMEView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXMEView: UIView {
    var showBanner: Bool = false
    lazy var infoView : EXMEInfoView = {
        let view = EXMEInfoView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 70))
        view.backgroundColor = UIColor.ThemeView.card1
        view.reloadView()
        return view
    }()
    
    var tableViewNameDatas : [(String , String)] = []
//    var banner: CmsAppDataItem = {
//        let b = CmsAppDataItem()
//        b.imageUrl = "personal_banner"
//        return b
//    }()
    var tableViewRowDatas : [EXMEEntity] = []
    var personData = PersonCenterBanner() {
        didSet{
            self.reload(personData: personData)
        }
    }
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.backgroundColor = UIColor.ThemeView.card1
        tableView.rowHeight = 52
        tableView.bounces = false
        tableView.extRegistCell([EXMETC.classForCoder(),UITableViewCell.classForCoder()], ["EXMETC","UITableViewCell"])
        tableView.register(EXSeperatorCell.self)//Division line
        tableView.tableHeaderView = infoView
        tableView.register(EXHomeSubBannerCell.self)//Deputy banner
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        setData(personData: PersonCenterBanner())
    }
    
    func setData(personData:PersonCenterBanner){
        let safe = (LanguageTools.getString(key: "personal_text_safetycenter"),"personal_security")
        let inviteFriend =   ("common_action_inviteFriend".localized(),"personal_invitefriends")
        let rateDis =  (LanguageTools.getString(key: "personal_Center_text3"),"personal_ratediscount")
        let setting = (LanguageTools.getString(key: "personal_text_setting"),"personal_setup")
        let line = ("line","")
        let online = ("personal_text_onlineservice".localized(), "personal_onlineservice")
        let help = (LanguageTools.getString(key: "personal_text_helpcenter"),"personal_help")
        let zhanneimsg = (LanguageTools.getString(key: "personal_text_message"),"personal_notice")
//        let notice = (LanguageTools.getString(key: "personal_text_notice"),"personal_notice")
        let blackListItem = (LanguageTools.getString(key: "personal_text_blacklist"),"personal_blacklist")
        let feeRate = ("personal_center_FeeRate".localized(),"personal_ratediscount")
//        let aboutUs = (LanguageTools.getString(key: "personal_text_aboutus"),"personal_aboutus")
        tableViewNameDatas.removeAll()
        tableViewNameDatas = [safe,inviteFriend]
        if EXAppConfigManager.sharedInstance.configVm.cfgModel.membership_level_open == "1" {
            tableViewNameDatas.append(feeRate)
        }else if personData.is_open == "1"{
            tableViewNameDatas.append(rateDis)
        }
        tableViewNameDatas.append(setting)
        tableViewNameDatas.append(line)
        if EXAppConfigManager.sharedInstance.getOnlineServiceURL() != "" || EXAppConfigManager.sharedInstance.didOpenServiceOnline(){//If there is online customer service
            tableViewNameDatas.append(online)
        }
        tableViewNameDatas.append(contentsOf: [help,zhanneimsg])
        if EXAppConfigManager.sharedInstance.didOpenFiat() {
            tableViewNameDatas.append(blackListItem)
        }
//        tableViewNameDatas.append(aboutUs)
        //Switch routes
//        if LanguageTools.isOverSeasVersion() == false {
//            if let hosts = EXNetworkDoctor.sharedManager.hosts,hosts.count > 0 {
//                tableViewNameDatas.append(("customSetting_action_changeHost".localized(), "personal_multilink"))
//            }
//        }
        
        var arr : [EXMEEntity] = []
        for tuple in tableViewNameDatas{
            let entity = EXMEEntity()
            entity.name = tuple.0
            entity.imgName = tuple.1
            entity.tip = tuple == rateDis
            arr.append(entity)
        }
        tableViewRowDatas = arr
        tableView.reloadData()
    }
    
    
    func reloadTaskInfo(vm: EXTaskViewModel){
        if vm.rewardCenter?.confSwitch == 1 {
            let task = (LanguageTools.getString(key: "menus_rewardCenter"),"personal_taskcenter")
            let entity = EXMEEntity()
            entity.name = task.0
            entity.imgName = task.1
            entity.tip = false
//            if vm.rewardCenter?.count ?? 0 > 0 {
//                entity.unRead = false
//            }
           
            tableViewRowDatas.insert(entity, at: 1)
            self.tableView.reloadData()
        }
    }
    func reload(personData:PersonCenterBanner){
        setData(personData: personData)
        for entity in self.tableViewRowDatas{
            if entity.name == LanguageTools.getString(key: "personal_Center_text3"){
                entity.detail = String(format: "personal_Center_text4".localized(), personData.coin)
                break
            }
        }
        if personData.cmsAppDataListPcBanner.count > 0 {
            //self.banner = personData.cmsAppDataListPcBanner[0]
            self.showBanner = true
        }else{
            self.showBanner = false
        }

        if XUserDefault.getToken() != nil{ //Logged in
            let height:CGFloat =  self.showBanner ? 77 : 92
            infoView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: height)
        }
        self.tableView.reloadData()
    }
    
    
    //Obtain index
    func getIndex(name:String, inArray:[(String,String)]) -> Int{
        if name.isEmpty {
            return 0
        }
        var index: Int = 0
        for item in inArray {
            if item.0 == name  {
                return index
            }
            index += 1
        }
        return index
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXMEView : UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 
        }
        return tableViewRowDatas.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
           return self.showBanner ? (SCREEN_WIDTH / 375 * 60 + 26) : 0
        }
        let entity = tableViewRowDatas[indexPath.row]
        if entity.name == "line" {
            return 18
        }
        return 52
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXHomeSubBannerCell
           // let item = banner
            cell.bindBanners(subBanner: self.personData.cmsAppDataListPcBanner)
           return cell
        }
        
        let entity = tableViewRowDatas[indexPath.row]
        if entity.name == "line" { //Division line
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXSeperatorCell
            cell.contentView.backgroundColor = UIColor.ThemeView.card1
            cell.lineV.isHidden = false
            return cell
        }
        let cell :EXMETC = tableView.dequeueReusableCell(withIdentifier: "EXMETC") as! EXMETC
        cell.entity = entity
//        cell.setCell(entity,lineVHidden : true)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        
        let entity = tableViewRowDatas[indexPath.row]
        switch entity.name {
        case "line":
            break
        case LanguageTools.getString(key: "menus_rewardCenter"):
            if XUserDefault.isOffLine(){
                BusinessTools.modalLoginVC()
                return
            }
            let vc = EXTaskCenterViewController()
            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        case LanguageTools.getString(key: "personal_text_setting"):
            let vc = EXSetVC()
            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        case LanguageTools.getString(key: "personal_text_helpcenter"):
            if EXAppConfigManager.sharedInstance.getHelpCenter() != ""{//The help center has been set up in the background
                let web = WebVC()
                web.loadUrl(EXAppConfigManager.sharedInstance.getHelpCenter())
                self.yy_viewController?.navigationController?.pushViewController(web, animated: true)
            }else{
                let vc = EXHelpVC()
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            }
        case LanguageTools.getString(key: "personal_text_notice"):
            let vc = EXAnnouncementVC()
            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
//        case LanguageTools.getString(key: "personal_text_aboutus"):
//            let vc = EXAboutUsVC()
//            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        case "personal_text_onlineservice".localized():
            EXZenDeskManger.manger.goToNext()
//            guard let viewController = Zendesk.instance?.messaging?.messagingViewController() else { return }
//            self.yy_viewController?.show(viewController, sender: self.yy_viewController)
//
//
//            return
//            let vc = WebVC()
//            vc.loadUrl(EXAppConfigManager.sharedInstance.getOnlineServiceURL())
//            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        case "customSetting_action_changeHost".localized():
            let vc = EXChangeHostVC()
            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        default:
            if XUserDefault.getToken() == nil{
                BusinessTools.modalLoginVC()
                return
            }
            switch entity.name{
            case LanguageTools.getString(key: "personal_Center_text3"):
                let vc = EXCapitalRateVc()
                vc.personData = self.personData
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            case LanguageTools.getString(key: "personal_text_safetycenter"):
                let vc = EXSecurityCenterVC()
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            case LanguageTools.getString(key: "personal_text_message"):
                let vc = EXAppMailVC()
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            case LanguageTools.getString(key: "personal_text_blacklist"):
                let vc = EXShieldingVC()
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            case LanguageTools.getString(key: "common_action_inviteFriend"):
                let vc = EXContractAgentHomeVc()
                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            case "personal_center_FeeRate".localized():
                let webViewController = WebVC()
                webViewController.loadUrl(EXAppConfigManager.sharedInstance.configVm.cfgModel.membership_level_url)
                yy_viewController?.navigationController?.pushViewController(webViewController, animated: true)
            default:
                break
            }
        }
    }
}

