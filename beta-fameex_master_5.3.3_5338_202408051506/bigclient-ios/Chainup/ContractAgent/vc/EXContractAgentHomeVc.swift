//
//  EXContractAgentHomeVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage
import EXKit
import Swap
import SwiftEntryKit
import IQKeyboardManagerSwift


enum AgentStatus:String {
    case agent = "1"
    case notAgent = "0"
}

enum EXContractCellType {
    case contract
    case inviteDetail
    case inviteLink
    case register
    case spotBroker
    case goldBroker
}

class EXContractAgentHomeVc: BaseVC,NavigationPlugin {
    let inviteUrl = UserInfoEntity.sharedInstance().inviteUrl
    let inviteCode = UserInfoEntity.sharedInstance().inviteCode
    let vm = EXOTCSafetyCheckVm()
    var contractAgent: EXAgentContractModel?
    var configModel: EXInvitationPublicConfigModel?
    var agentStatus:AgentStatus = .notAgent
    var agentModel:EXAgentIndexModel = EXAgentIndexModel()
    var switchVoModel: EXInviteSwitchVoModel?
    
    var spotModel:EXInvitationSpotDataModel = EXInvitationSpotDataModel()
    var stateModel = EXAgentStatus()
    var queryPageDataSuccess = false
    private var dataSource:[EXContractCellType] = []
    
    
    internal lazy var navigation : EXNavigation = {
        let v =  EXNavigation.init(affectScroll: self.agentTable, presenter: self)
        v.popBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_return"), for: UIControl.State.normal)
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    lazy var agentTable:UITableView = {
        let v = UITableView.init(frame: .zero, style: .plain)
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = .clear
        v.separatorStyle = .none
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = 200
        v.register(EXContractAgentInfoCell.self, forCellReuseIdentifier: "EXContractAgentInfoCell")
        v.extRegistCell([EXTwoByTwoTableViewCell.classForCoder()], ["EXTwoByTwoTableViewCell"])
        v.register(EXInviteLinkCell.self, forCellReuseIdentifier: "EXInviteLinkCell")
        v.register(EXInviteRegisterRewardsCell.self, forCellReuseIdentifier: "EXInviteRegisterRewardsCell")
        v.register(EXInviteSpotBrokerRewardsCell.self, forCellReuseIdentifier: "EXInviteSpotBrokerRewardsCell")
        v.register(EXInviteGoldBrokerRewardsCell.self, forCellReuseIdentifier: "EXInviteGoldBrokerRewardsCell")
        v.contentInset = .init(top: 0, left: 0, bottom: 34, right: 0)
        return v
    }()
    
    lazy var redPacketBtn : EXRedPacketButton = {
        let v = EXRedPacketButton()
        v.clickBtnBlock = {[weak self]tag in
            guard let mySelf = self else{return}
            switch tag{
            case 0:
                self?.redPacketBtn.isHidden = true
            case 1:
                if XUserDefault.getToken() == nil{
                    BusinessTools.modalLoginVC()
                    return
                }
                if mySelf.vm.checkRedpacketSafety(mySelf) == true{
                    let vc = EXSendRedPacketVC()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            default:
                break
            }
        }
        return v
    }()
    
    
    lazy var agentHeader:EXContractAgentHeader = {
        let v = EXContractAgentHeader.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 427))
        return v
    }()
    
    func instructionAction() {
        let coUrl = EXAppConfigManager.sharedInstance.getContractAgentUrl()
        if coUrl.count > 0 {
            
            pushToWebVcWithUrl(urlString: coUrl)
        }
    }
    
    func pushToWebVcWithUrl(urlString:String?) {
        guard let urlString = urlString, !urlString.isEmpty  else {
            return
        }
        
        guard URL(string: urlString) != nil else {
            return
        }
        
        let webVc = WebVC()
        webVc.loadUrl(urlString)
        self.navigationController?.pushViewController(webVc, animated: true)
    }
    
    func handleNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: Notification.Name(rawValue: "EXLoginSuccess"), object: nil)
    }
    
    @objc func loginSuccess() {
        checkLogin()
    }
    
    func handNavigationBar() {
        self.navigation.setdefaultType(type: .normal)
        updateBackStyleIfNeed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handNavigationBar()
        handleNoti()
        setupTableView()
        view.addSubview(navigation)
        queryRedPack()
        self.checkLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryInvitationSwitch()
    }
    
    func setupTableView() {
        //Leave blank at the top of the solution tableview
        view.addSubview(agentTable)
        agentTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        agentHeader.layoutIfNeeded()
        agentHeader.height = agentHeader.container.frame.maxY + 10
        agentTable.tableHeaderView = agentHeader
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension EXContractAgentHomeVc : UITableViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateBackStyleIfNeed(scrollView.contentOffset.y)
    }
    
    func updateBackStyleIfNeed(_ offsetY: CGFloat = 0.0) {
        self.navigation.popBtn.setImage(EXKitBundle.svgImage(named: "special_return"), for: .normal)
    }
    
}

extension EXContractAgentHomeVc : UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tbDataSource().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tbDataSource()[indexPath.row] {
        case .inviteLink:
            let cell : EXInviteLinkCell = tableView.dequeueReusableCell(withIdentifier: "EXInviteLinkCell", for: indexPath) as! EXInviteLinkCell
            cell.setCellData(self.configModel?.inviteUrl, self.configModel?.inviteCode ,UserInfoEntity.sharedInstance().isCanAddSuperior)
            cell.delegate = self
            return cell
            
        case .inviteDetail:
            let cell : EXTwoByTwoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EXTwoByTwoTableViewCell") as! EXTwoByTwoTableViewCell
            cell.delegate = self
            cell.bindCellData(model: getInviteDetailCellData())
            return cell
            
        case .register:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXInviteRegisterRewardsCell", for: indexPath) as! EXInviteRegisterRewardsCell
            cell.setInvitePublicConfigModel(self.configModel)
            cell.setClickBlock { [weak self] in
                guard let self else { return }
                self.navigationController?.pushViewController(EXInviteRegisterRewardsVc(), animated: true)
            } ruleBlock: { [weak self] in
                guard let self else { return }
                self.pushToWebVcWithUrl(urlString: self.ruleUrl(section: indexPath.section))
            }
            return cell
            
        case .spotBroker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXInviteSpotBrokerRewardsCell", for: indexPath) as! EXInviteSpotBrokerRewardsCell
            cell.setInvitePublicConfigModel(self.configModel, spotModel: self.spotModel)
            cell.setClickBlock { [weak self] in
                guard let self else { return }
                self.pushToWebVcWithUrl(urlString: spotModel.recordUrl())
            } ruleBlock: { [weak self] in
                guard let self else { return }
                self.pushToWebVcWithUrl(urlString: self.ruleUrl(section: indexPath.section))
            }
            return cell
            
        case .goldBroker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXInviteGoldBrokerRewardsCell") as! EXInviteGoldBrokerRewardsCell
            cell.setClickBlock { 
            
            } ruleBlock: { [weak self] in
                guard let self else { return }
                self.pushToWebVcWithUrl(urlString: self.ruleUrl(section: indexPath.section))
            }
            return cell
            
        case .contract:
            let cell : EXContractAgentInfoCell = tableView.dequeueReusableCell(withIdentifier: "EXContractAgentInfoCell", for: indexPath) as! EXContractAgentInfoCell
            cell.bindAgentModel(config: self.configModel, model: self.contractAgent)
            cell.setClickBlock {
                
            } ruleBlock: { [weak self] in
                guard let self else { return }
                self.pushToWebVcWithUrl(urlString: self.ruleUrl(section: indexPath.section))
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}
// MARK: - Getter
extension EXContractAgentHomeVc {
    
    func tbDataSource() -> [EXContractCellType] {
        if !self.dataSource.isEmpty {
            return self.dataSource
        }
        var retV:[EXContractCellType] = [.inviteLink]
        defer {
            self.dataSource = retV
        }
        
        if let switchConfig = self.switchVoModel, switchConfig.isOpenInvitation{
            retV.append(.register)
        }
        
        if XUserDefault.isOffLine() ||
            !queryPageDataSuccess {
            return retV
        }
        
        if EXAppConfigManager.sharedInstance.didOpenUserAgent() &&
        UserInfoEntity.sharedInstance().hasAgentStatus(){
            retV.append(.spotBroker)
        }
        if self.agentStatus == .agent {
            retV.append(.contract)
        }
        self.dataSource = retV
        return retV
    }
    
    func getInviteDetailCellData() -> EXTwoByTwoItemModel {
        
        let modelB = EXTwoByTwoItemModel()
        modelB.ltitleColor = UIColor.ThemeLabel.colorMedium
        modelB.rtitleColor = UIColor.ThemeLabel.colorMedium
        modelB.lcontentFont = self.themeHNFont(size: 14)
        modelB.lcontentColor = UIColor.ThemeLabel.colorHighlight
        modelB.rcontentFont = self.themeHNFont(size: 14)
        modelB.rcontentColor = UIColor.ThemeLabel.colorHighlight
        modelB.ltitle = "invitation_number_friends".localized()
        modelB.rtitle = "invitation_rewards_amount".localized() + "（USDT）"
        modelB.rightAlignment = .left
        
        // TODO: ----- self.configModel?.config.invitationUserCoun
        modelB.lcontent = self.configModel?.inviteUserCount ?? "--"//quantity
        modelB.rcontent = self.configModel?.inviteRewardUsdtSum.formatAmount("USDT") ?? "--"//money
        return modelB
    }
    
    func getSpotCellData() -> [ExThreeColumnDataModel] {
        var retV = [ExThreeColumnDataModel]()
        
        let modell = ExThreeColumnDataModel()
        modell.title = "invitation_number_people".localized()
        modell.content = spotModel.userCount
        modell.style = getCountStyle()
        retV.append(modell)
        
        let modelm = ExThreeColumnDataModel()
        modelm.title = "invitation_ratio_commission".localized()
        modelm.content = spotModel.scaleOfDecimal() + "%"
        modelm.style = getCommonStyle()
        retV.append(modelm)
        
        let modelr = ExThreeColumnDataModel()
        modelr.content = spotModel.allBonusAmount.formatAmount("USDT")
        modelr.title = "invitation_total_commission".localized() + "（\(spotModel.allBonusCoin))"
        modelr.style = getCountStyle()
        retV.append(modelr)
        
        return retV
    }
    
    func headerName(section:NSInteger) -> String {
        
        switch tbDataSource()[section] {
        case .inviteLink:
            return ""
        case .inviteDetail:
            return "invitation_register_rewards".localized()
        case .spotBroker:
            return "invitation_spot_broker".localized()
        case .contract:
            return self.contractAgent?.roleName ?? "" //AgentModel.role_ Name
        default:
            return ""
        }
    }
    
    func ruleUrl(section:NSInteger) -> String? {
        switch tbDataSource()[section] {
        case .inviteLink:
           return self.configModel?.config.invitationRuleUrl
        case .inviteDetail:
            return self.configModel?.config.invitationRuleUrl
        case .spotBroker:
            return self.configModel?.config.exchangeBrokerRuleUrl
        case .goldBroker:
            return self.configModel?.config.exchangeBrokerRuleUrl
        case .contract:
            return self.configModel?.config.coBrokerRuleUrl
        default:
            return ""
        }
    }
    
    func getCountStyle() -> ExThreeColumnStyle {
        let style = getCommonStyle()
        style.bottomLabelColor = UIColor.ThemeLabel.colorHighlight
        return style
    }
    
    func getCommonStyle() -> ExThreeColumnStyle {
        let style = ExThreeColumnStyle()
        style.topLabelColor = UIColor.ThemeLabel.colorMedium
        style.topLabelFont = self.themeHNFont(size: 12)
        style.bottomLabelFont = self.themeHNFont(size: 14)
        style.bottomLabelColor = UIColor.ThemeLabel.colorLite
        return style
    }
    func posterImageURLs() -> [URL?] {
        return [URL(string: configModel?.config.posterOneImg ?? ""), URL(string: configModel?.config.posterTwoImg ?? "")]
    }
}

extension EXContractAgentHomeVc:EXInvitationInfoTableViewCellDelegate {
    
    func addSuperiorInviteCode() {
        let sheetView = EXInviteAddSuperiorCodeView()
        sheetView.activeFirstResponder()
        sheetView.confirmBlock = {[weak self] value in
            guard let self else { return }
            self.addInvitationedCode(code: value)
        }
        EXAlert.showSheet(sheetView: sheetView)
    }
    
    func postButtonDidClick() {
        let posterV = EXInvitationPosterView()
        posterV.setPosterImageUrl(imageUrls: posterImageURLs(), inviteUrl: configModel?.inviteUrl)
        EXAlert.showSheet(sheetView: posterV)
    }
    
    func faceToFaceButtonClickBlock() {
        let popView = EXInvitationPopView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        popView.setData(bgImageUrl: configModel?.config.faceToFaceImg?.removeAllSapce ?? "",
                        inviteUrl: configModel?.inviteUrl)
        EXAlert.showCenterView(view: popView)
    }
}

extension EXContractAgentHomeVc:EXTwoByTwoTableViewCellDelegate {
    func leftViewDidClick(cell: EXTwoByTwoTableViewCell) {
        pushToInviteDetailVc(index: 0)
    }
    
    func rightViewDidClick(cell: EXTwoByTwoTableViewCell) {
        pushToInviteDetailVc(index: 1)
    }
    
    func pushToInviteDetailVc(index:Int) {
        let vc = EXInvitationDetailVC()
        vc.currentIdx = index
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


//MARK: -Request
extension EXContractAgentHomeVc {
    
    func queryPageData(completion:@escaping (_ model:EXInvitationPublicConfigModel)->()) {
        appApi.rx.request(.inviteConfig).MJObjectMap(EXInvitationPublicConfigModel.self).subscribe { (event) in
            switch event {
            case .success(let model):
                completion(model)
                break
            case .failure(_):
                print("error")
                break
            }
        }.disposed(by: disposeBag)
    }
    
    
    // add invite code
    private func addInvitationedCode(code: String) {
        appApi.rx.request(.addInvitationedCode(invitedCode: code))
            .MJObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: {[weak self] result in
                guard let self else { return }
                UserInfoEntity.sharedInstance().getUserInfo {
                    DispatchQueue.main.async {
                        self.agentTable.reloadData()
                    }
                } _: {}

                EXAlert.dismissEnd {
                    EXAlert.showSuccess(msg: "referral_superior_toast_succ".localized())
                }
            }, onFailure: { err in
                var msg = err.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                msg = msg.isEmpty ? "referral_superior_toast_notexist".localized() : msg
                EXAlert.showFail(msg: msg)
            }) .disposed(by: disposeBag)
    }
    
    func queryRedPack(){
        EXAppConfigManager.sharedInstance.onPbV5Publish
            .subscribe(onNext: {[weak self] (success) in
                guard let mySelf = self else{return}
                //If the red envelope button is turned on
                if EXAppConfigManager.sharedInstance.didOpenRedPack() {
                    mySelf.redPacketBtn.show(mySelf.view)
                }else{//If the red envelope button is turned off
                    mySelf.redPacketBtn.dismiss()
                }
            }).disposed(by: disposeBag)
    }
    func checkLogin() {
        if XUserDefault.isOffLine() {
            BusinessTools.modalLoginVC()
            
        }else {
            var img = UIImage.themeImageNamed(imageName: "contract_agnet_banner_english")
            if LanguageTools.isHan() {
                img = UIImage.themeImageNamed(imageName: "contract_agnet_banner")
            }
            queryPageData { (model) in
                self.queryPageDataSuccess  = true
                if let appBannerImg = model.config.appBannerImg, !appBannerImg.isEmpty {
                    self.agentHeader.headerBg.yy_setImage(with: URL(string: appBannerImg),placeholder: img)
                }
                
                //Pre download images
                if let faceToFaceImg = model.config.faceToFaceImg,
                   let availableUrl = URL(string: faceToFaceImg) {
                    
                    YYWebImageManager.shared().requestImage(with:availableUrl , options: .allowBackgroundTask, progress: nil, transform: nil, completion: nil)
                }
                self.configModel = model
                self.agentTable.reloadData()
                
            }
            
            if  EXAppConfigManager.sharedInstance.didOpenOcAgent(){
                self.queryRole()
            }
        }
    }
    
    
    func queryContractAgentInfo(){
        appApi.rx.request(.contract_newAgentInfo)
            .customObjectMap(EXAgentContractModel.self)
            .subscribe{ [weak self] event in
                switch event {
                case .success(let model):
                    self?.contractAgent = model
                    self?.dataSource.removeAll()
                    self?.agentTable.reloadData()
                    break
                case .failure(let err):
                    print(err)
                    break
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    func queryRole(){
        guard let id = Int(UserInfoEntity.sharedInstance().uid) else{
            return
        }
        appApi.rx.request(.contract_agent_role(uid: id))
            .MJObjectMap(EXAgentStatus.self)
            .subscribe{ [weak self] event in
                switch event {
                case .success(let model):
                    self?.stateModel = model
                    self?.dataSource.removeAll()
                    self?.agentTable.reloadData()
                    if let status = self?.stateModel.status, status > 0{
                        self?.agentStatus = .agent
                        self?.queryContractAgentInfo()
                    }
                    break
                case .failure(_):
                    break
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    
    /// 获取业务层公共开关
    func queryInvitationSwitch() {
        BusinessTools.checkMyInviteSwitch { [weak self] config in
            guard let self else { return }
            self.switchVoModel = config
            self.dataSource.removeAll()
            DispatchQueue.main.async {
                self.agentTable.reloadData()
            }
        }
    }
    
}
