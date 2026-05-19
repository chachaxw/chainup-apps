//
//  EXSetView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import Swap
enum EXSettingAction {
    case lan
    case klineColor
    case theme
    case push
    case changeCo
    case none
    case changeLine
    case aboutUs
    case uploadInfo
}

class EXSetView: UIView {
    
    let uploader:EXImageUploader = EXImageUploader.init()
//    var pfIndex = 0
//    let pfDatas : [String] = [LanguageTools.getString(key: "customSetting_action_themeDay"),
//                              LanguageTools.getString(key: "customSetting_action_themeNight")
//    ]
//                              LanguageTools.getString(key: "customSetting_action_themeDay_KlineNight")]
    
//    var zdIndex = 0
//    let zdDatas : [String] = [LanguageTools.getString(key: "customSetting_action_global"),
//                              LanguageTools.getString(key: "customSetting_action_china")]
    
    var tableViewNameDatas : [String] = [LanguageTools.getString(key: "customSetting_action_language"),
                                         LanguageTools.getString(key: "customSetting_action_kline"),
                                         LanguageTools.getString(key: "personal_Center_text26")]
    //        tableViewNameDatas.append(aboutUs)
   
    lazy var pushEntity : EXSetEntity = {
        let entity = EXSetEntity()
        entity.name = "customSetting_action_pushSetting".localized()
        entity.action = .push
        return entity
    }()
    
    lazy var contractChangeEntity : EXSetEntity = {
        let entity = EXSetEntity()
        entity.name = "customSetting_action_changeCo".localized()
        entity.action = .changeCo
        entity.rightName = EXAppConfigManager.sharedInstance.getContractVersionDesc()
        entity.hideExplain = false
        entity.hideRedDot = false
        return entity
    }()
    
    var tableViewRowDatas : [EXSetEntity] = []

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXSetTC.classForCoder()], ["EXSetTC"])
        return tableView
    }()
    
    lazy var logoutBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.backgroundColor = UIColor.ThemeBtn.highlight
        btn.setTitle(LanguageTools.getString(key: "common_text_logout"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickLogoutBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([tableView,logoutBtn])
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(logoutBtn.snp.top)
        }
        logoutBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-30 - TABBAR_BOTTOM)
            make.height.equalTo(44)
        }
        if XUserDefault.getToken() == nil{
            logoutBtn.isHidden = true
        }
        setData()
    }
    
//    func rowActions()->[EXSettingAction] {
//        return [.lan,.klineColor,.theme]
//    }
    func updateAbouts(){
        for item in tableViewRowDatas{
            if item.action == .aboutUs {
                item.hideRedDot = false
            }
        }
        tableView.reloadData()
    }
    func setData(){
        
        var arr : [EXSetEntity] = []
       //Switch routes
        if EXKitStanders.isOverSeasVersion() == false {
            if let hosts = EXNetworkDoctor.sharedManager.hosts,hosts.count > 0 {
                if !tableViewNameDatas.contains("customSetting_action_changeHost".localized()){
                    tableViewNameDatas.append("customSetting_action_changeHost".localized())
                }
            }
        }
        if !tableViewNameDatas.contains("personal_text_aboutus".localized()){
            tableViewNameDatas.append("personal_text_aboutus".localized())
        }
//        if !tableViewNameDatas.contains("customSetting_action_log_network".localized()){
//            tableViewNameDatas.append("customSetting_action_log_network".localized())
//        }
        for (_,str) in tableViewNameDatas.enumerated() {
            let entity = EXSetEntity()
            entity.name = str
            ///Logic optimization and display are based on the configured Index of language articles
            switch str{
            case LanguageTools.getString(key: "customSetting_action_language"):
                entity.action = .lan
                    let item = EXAppConfigManager.sharedInstance.getLanItem(lanId: LanguageHandler.priviatePhoneLanguage)
                    entity.rightName = item?.name ?? ""
            case LanguageTools.getString(key: "customSetting_action_kline"):
                entity.rightName = EXTheme.KLineTrend.current.localized
                entity.action = .klineColor
            case LanguageTools.getString(key: "personal_Center_text26"):
                entity.rightName =  EXTheme.current.localized
                entity.action = .theme
            case LanguageTools.getString(key: "customSetting_action_changeHost"):
                entity.action = .changeLine
            case LanguageTools.getString(key: "customSetting_action_log_network"):
                entity.action = .uploadInfo
            default:
                entity.action = .aboutUs
                let info = Bundle.main.infoDictionary
                if let str = info?["CFBundleShortVersionString"] as? String,let s = info?["exChainupBundleVersion"] as? String{
                    entity.rightName = "V" + str + "(\(s))"
                }
                break
            }
            arr.append(entity)
        }
        
        if EXAppConfigManager.sharedInstance.supportPush() &&
            !arr.contains(pushEntity){
            arr.append(pushEntity)
        }
        
        tableViewRowDatas = arr
        tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXSetView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXSetTC = tableView.dequeueReusableCell(withIdentifier: "EXSetTC") as! EXSetTC
        cell.setCell(entity)
        cell.onInfoBtnAction = {[weak self] entity in
            self?.handleInfoAction(entity: entity)
        }
        return cell
    }
    
    func handleInfoAction(entity:EXSetEntity) {
        if entity.action == .changeCo {
//            let eranView = EXSwapEranMoneyAlertView()

            let alert = EXScrollAlertView()
            EXAlert.showAlert(alertView: alert)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = tableViewRowDatas[indexPath.row]
        switch entity.action {
        case .lan:
            let pushvc = EXSetLanguageVC()
            pushvc.modalPresentationStyle = .custom
            pushvc.transitioningDelegate = self
            self.yy_viewController?.navigationController?.present(pushvc, animated: true, completion: nil)
        case .klineColor:
            roseFallSheet(entity)
        case .theme:
            skinSheet(entity)
        case .push:
            if XUserDefault.isOffLine() {
                BusinessTools.modalLoginVC()
                return
            }
            let pushvc = EXPushSettingVc()
            self.yy_viewController?.navigationController?.pushViewController(pushvc, animated: true)
            break
        case .aboutUs:
            let vc = EXAboutUsVC()
            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            break
        case .changeLine:
            let vc = EXChangeHostVC()
            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
            break
            
        case .changeCo:
            break
        case .uploadInfo:
            uploadInfo()
        default:
            break
        }
    }
}

extension EXSetView{
    func uploadInfo(){
        uploader.rx_imgUrl.skip(1)
            .subscribe(onNext: { [weak self] imgUrl in
                guard let mySelf = self else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading1()
                    EXAlert.showSuccess(msg: "toast_trade_success".localized())
                }
            }).disposed(by: self.disposeBag)

        if let data = EXSwapLogManger.shareInstance.readFile() {
            print(data.count)
            self.showLoading1()
            uploader.uploadFile(data: data)
        }
    }
    
    
    
    //Click on the exit login button
    @objc func clickLogoutBtn(){
        
        let normalAlert = EXCommonAlert()
        normalAlert.configAlert(tipImage: nil, title: "common_tip_logoutDesc".localized(), message: nil, cancelBtnTitle: "common_text_btnCancel".localized(), sureBtnTitle: "common_text_btnConfirm".localized(), btnLayoutStyle: .horizontal, alertCallBack: { [weak self] type in
            guard let self = self else { return }
            if type == .sure {
                self.logOutRequest()
            }
        })
        
        EXAlert.showAlert(alertView: normalAlert)
    }
    
   
    func roseFallSheet(_ entity : EXSetEntity){
        let allCases = EXTheme.KLineTrend.allCases
        let sheet = EXOldActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            guard let newTrend = allCases.safeObject(at: idx), newTrend.active() else { return }
            mySelf.setData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                mySelf.yy_viewController?.navigationController?.popToRootViewController(animated: false)
                BusinessTools.reloadWindow()
                XHUDManager.sharedInstance.dismissWithDelay {
                    
                }
            })
        }
        
        
        let zdDatas : [String] = allCases.map({ $0.localized })
        let idx = allCases.firstIndex(of: EXTheme.KLineTrend.current) ?? 0
        sheet.configButtonTitles(title:"customSetting_action_kline".localized(), buttons:zdDatas,selectedIdx: idx)
        EXAlert.showSheet(sheetView: sheet)
        
    }
    
    func skinSheet(_  entity : EXSetEntity){
        var allCases = EXTheme.allCases
        allCases.removeLast()
        let sheet = EXOldActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            guard let newTheme = allCases.safeObject(at: idx), newTheme.active() else { return }
         //   SvgConfigManger.shared.updateThemeColor()
            EXAppLaunchConfig.upDateEXKitConfig()
            
            mySelf.setData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                mySelf.yy_viewController?.navigationController?.popToRootViewController(animated: false)
                BusinessTools.reloadWindow()
                XHUDManager.sharedInstance.dismissWithDelay {
                    
                }
            })
        }
        let pfDatas : [String] = allCases.map({ $0.localized })
        let idx = allCases.firstIndex(of: EXTheme.current) ?? 0
        sheet.configButtonTitles(title: "personal_Center_text26".localized(),buttons:pfDatas,selectedIdx: idx)
        EXAlert.showSheet(sheetView: sheet)
    }
    
    func logOutRequest(){
            _ =  appApi
                .rx
                .request(.logOut)
                .MJObjectMap(EXVoidModel.self)
                .subscribe(onSuccess: { [weak self] model in
                    guard let self = `self` else { return }
                    self.logOutAction()
                })
    }
    
    func logOutAction(){
        XUserDefault.tokenValue = nil
        //            UserInfoEntity.removeAllData()
        EXSwapPlatformSDK.shared.activeAccount = nil
        EXSwapPlatformSDK.shared.inviteUrl = nil
        EXSwapPlatformSDK.shared.resetUSerConfig()
        NotificationCenterTool.postNoti(noti: .logOut)
        EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_action_logout"))
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.yy_viewController?.navigationController?.popToRootViewController(animated: true)
        }
    }
}


extension EXTheme {
    var localized: String {
        switch self {
        case .dark:
            return "customSetting_action_themeNight".localized()
        case .dayKLineNight:
            return "customSetting_action_themeDay_KlineNight".localized()
        case .light:
            fallthrough
        default:
            return "customSetting_action_themeDay".localized()
        }
    }
}

extension EXTheme.KLineTrend {
    var localized: String {
        switch self {
        case .reversed:
            return "customSetting_action_china".localized()
        case .normal:
            fallthrough
        default:
            return "customSetting_action_global".localized()
        }
    }
}


extension EXSetView: UIViewControllerTransitioningDelegate{
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return MyPresentViewController(presentedViewController: presented, presenting: presenting)
    }
}

//After switching languages using EXAlert and restarting the app, when setting shortcut login as gesture login, it cannot pop up So use UIPresentationController here instead
class MyPresentViewController: UIPresentationController,UIGestureRecognizerDelegate{
//    lazy var visualView: UIVisualEffectView = {
//        let blur = UIBlurEffect(style: .light)
//        let visualView = UIVisualEffectView(effect: blur)
//        visualView.frame = self.containerView!.bounds
//        visualView.alpha = 0.4
//        visualView.backgroundColor = UIColor.ThemeView.bg
//        return visualView
//    }()
    
    //It is called when the presentation transition is about to begin
    override func presentationTransitionWillBegin() {
        self.containerView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click(tap:)))
        tap.delegate = self
        self.containerView?.addGestureRecognizer(tap)
        self.containerView?.backgroundColor = UIColor.ThemeView.mask.withAlphaComponent(0.4)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        
    }
    
    override func dismissalTransitionWillBegin() {
        
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
    }
    
    override var frameOfPresentedViewInContainerView: CGRect{
        var maxH = Device_H * 0.9
        let count = EXAppConfigManager.sharedInstance.getLanListAll().count
        var viewH = EXSetLanguageV.getViewHeight(count: count)
        if viewH > maxH {
           viewH = maxH
        }
        self.presentedView?.frame =  CGRect(x: 0, y:Device_H - viewH, width: Device_W, height: viewH)
        return self.presentedView!.frame
        
    }
    
    
    @objc func click(tap: UIGestureRecognizer){
        presentedViewController.dismiss(animated: true , completion: nil)
    }
    
    //Click to switch language without responding to events, so that the pop-up view does not respond to the click of the parent view
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view,let presented = self.presentedView{
            if touchView.isDescendant(of: presented){
                return false
            }
        }
        return true
    }
    
}

