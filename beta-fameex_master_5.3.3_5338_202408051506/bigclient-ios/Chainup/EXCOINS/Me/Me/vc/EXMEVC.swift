//
//  EXMEVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class PersonCenterBanner: EXBaseModel{
    var cmsAppDataListPcBanner = [CmsAppDataItem]()
    var fee_trade_status = ""
    var coin = ""
    var rate = ""
    var is_open = ""
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.cmsAppDataListPcBanner = CmsAppDataItem.mj_objectArray(withKeyValuesArray: self.cmsAppDataListPcBanner).copy() as! [CmsAppDataItem]
    }
}
class EXMEVC: NavCustomVC {
    private let group = DispatchGroup()
    let bag = DisposeBag()
    var vm = EXHomePageService()
    let taskVm = EXTaskViewModel()
    lazy var mainView : EXMEView = {
        let view = EXMEView()
        view.extUseAutoLayout()
        return view
    }()
  
    lazy var dayNightChangebtn: UIButton = {
        let img = UIImage.svgImage(named: "personal_night")
        let btn = UIButton(buttonType: .custom, image:img)
        btn.rx.tap
            .subscribe(onNext: { [weak btn,weak self] in
                btn!.isSelected = !btn!.isSelected
                self?.setTheme(btn: btn!)
                
            }).disposed(by:bag)
        return btn
    }()
    var personData = PersonCenterBanner()
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(TABBAR_BOTTOM + 20))
        }
        mainView.personData = self.personData
        
        
        taskVm.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch event{
            case .rewardCenter:
                self.mainView.reloadTaskInfo(vm: self.taskVm)
            default:
                break
            }
        }).disposed(by: self.disposeBag)
        
        self.vm.getPersonRateData()
            .subscribe(onNext:{[weak self] data in
                guard let s = self else{return}
                s.mainView.personData = data
                s.taskVm.getRewardCenterInfo()
            }).disposed(by: self.disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if XUserDefault.getToken() != nil{
            //Request personal information and update
            UserInfoEntity.sharedInstance().getUserInfo ({ [weak self] in
                guard let ss = self else{return}
                ss.mainView.infoView.reloadView()
                ss.getAuthInfo()
                ss.getNoRead()
                ss.getRewardStatus()
            }) {
                
            }
            
        }else{
            self.mainView.infoView.reloadView()
        }
        
        
    }
    override func setNavCustomV() {
        navCustomView.backView.addSubview(dayNightChangebtn)
        dayNightChangebtn.snp.updateConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(40)
            make.width.equalTo(80)
            make.centerY.equalTo(navCustomView.popBtn)
            make.bottom.equalToSuperview()
        }
        
    }
    
    
    func setTheme(btn: UIButton){
        btn.isEnabled = false
        
        if (EXThemeManager.current == .day){
            EXTheme.dark.active()
        }else if EXThemeManager.current == .night{
            EXTheme.light.active()
        }
        EXAppLaunchConfig.upDateEXKitConfig()
        btn.isEnabled = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
            self.navigationController?.popToRootViewController(animated: false)
            BusinessTools.reloadWindow()
            XHUDManager.sharedInstance.dismissWithDelay {
                
            }
        })
        
    }

    func getNoRead(){
        appApi.hideAutoLoading()
        appApi.rx.request(AppAPIEndPoint.getNoReadMessageCount)
            .MJObjectMap(EXNoReadEntity.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                let count = entity.noReadMsgCount
                for entity in mySelf.mainView.tableViewRowDatas{
                    if entity.name == LanguageTools.getString(key: "personal_text_message"){
                        entity.unRead = count == "0"
                        break
                    }
                }
                mySelf.mainView.tableView.reloadData()
            }) { (error) in
                
            }.disposed(by: disposeBag)
    }
    
    func getRewardStatus() {
        self.taskVm.getUnCollectTaskInfo{ [weak self] model in
            guard let self = self else { return }
            for entity in self.mainView.tableViewRowDatas{
                if entity.name == LanguageTools.getString(key: "menus_rewardCenter"){
                    entity.unRead = model.count == 0
                    break
                }
            }
            self.mainView.tableView.reloadData()
        }
    }
    func getAuthInfo() {
        if XUserDefault.isOffLine(){
            return
        }
        let _ = appApi.rx.request(.getKycAuthCurrentLevel)
            .customObjectMap(EXCurrentAuthResult.self).subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.mainView.infoView.item = model
            }, onFailure: {  _ in
                
            }, onDisposed: {
            })
    }
    
    override func navBack() {
        guard let navigationController = navigationController else { return }
        let transition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: .linear)
        transition.type = .reveal
        transition.subtype = .fromRight
        navigationController.view.layer.add(transition, forKey: nil)
        navigationController.popViewController(animated: false)
    }
    
}

