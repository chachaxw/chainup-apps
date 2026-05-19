//
//  EXPosDetailVC.swift
//  Chainup
//
//  Created by lcus on 2023/9/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//details

import UIKit
import RxSwift
import EXKit

class EXPosProtocolDetailVC: NavCustomVC {

    var maibutton = UIButton()
    var posbutton = UIButton()
    var projectID:String = ""
    var url:String?
    var disposable: Disposable? = nil
    var infoVM:EXPosProjectDetailVM = EXPosProjectDetailVM()
    var enity: EXPosDetailProtocolEnity = EXPosDetailProtocolEnity()
    var detailView:EXPosDetailProtocolView = {
        
         let View = EXPosDetailProtocolView()
         return View
    }()
        
       
        
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.ThemeView.bg
        self.view.addSubview(detailView)
        detailView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(NAV_SCREEN_HEIGHT)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
        }
        detailView.tableView.snp_makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.bringSubviewToFront(navCustomView)
        self.loadDetailInfo()
        relayout(showMail: false)
        _ = NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext:{ [weak self] _ in
               self?.loadDetailInfo()
            })

    }
    
    func loadDetailInfo() {
        
        infoVM.getProjectInfo(projectId: projectID, MapType: EXPosDetailProtocolEnity.self) {[weak self] (enity) in
        
            let postionEnity = enity as! EXPosDetailProtocolEnity
            self?.enity = postionEnity
            self?.url  = postionEnity.url
            self?.dealMailBtn()
            let listData = self?.infoVM.packageProtocolCellData(enity:postionEnity)
            self?.handeCountDown(enity: postionEnity)
            self?.detailView.dataEnity = postionEnity
            self?.url = postionEnity.url
            self?.detailView.dataSouce = listData ?? []
            if postionEnity.needAuth == 1 {
                UserInfoEntity.sharedInstance().getUserInfo({
                    _ = EXAuthenticManagerTool.kycRightPassed(right: .licai)
                }, {
                    
                }, postNoti: false)
            }
        };
        
    }
    
    func handeCountDown(enity:EXPosDetailProtocolEnity) {
        
        self.disposable?.dispose()
        if enity.activeStatus != 0 { return }
        let timesCout = Int(enity.remainingTimeSeconds)
       
        self.disposable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .take(while: { $0 < timesCout ?? 1})
            .subscribe( onCompleted: { [weak self] in
                guard let mySelf = self else{return}
                mySelf.enity.activeStatus = 1
                let listData = mySelf.infoVM.packageProtocolCellData(enity: mySelf.enity)
                mySelf.detailView.dataEnity = mySelf.enity
                mySelf.detailView.dataSouce = listData
                
            })
        
    }
    
    
    
    
    
    
    deinit {
//        print("released")
    }
    

    override func setNavCustomV() {
        self.navCustomView.backgroundColor = UIColor.ThemeNav.bg
        
      
        let img =  UIImage.svgImage(named: "personal_mail",version: .five)
        maibutton.setImage(img, for: .normal)
        maibutton.addTarget(self, action: #selector(infoClick), for: .touchUpInside)
        navCustomView.backView.addSubview(maibutton)
       
        let tipMine = EXPosDetailServer.sharedInstance.tipMine
        posbutton.setTitle(tipMine, for: .normal)
        posbutton.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        posbutton.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        posbutton.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        navCustomView.backView.addSubview(posbutton)
        
        maibutton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.width.lessThanOrEqualTo(100)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        posbutton.snp.makeConstraints { (make) in
            make.right.equalTo(maibutton.snp.left).offset(-20)
            make.width.lessThanOrEqualTo(100)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        
    }
    @objc  func buttonClick() {
        if XUserDefault.getToken() == nil{
            BusinessTools.modalLoginVC()
            return
        }
        let poshistory =  EXPosHistoryVC.instanceFromStoryboard(name: "FreeStacking")
        poshistory.postInfoType = "3"
        self.navigationController?.pushViewController(poshistory, animated: true)
        
    }
    @objc func infoClick() {
        
        if let pojectadv = self.url  {
            let webVC = WebVC()
            webVC.loadUrl(pojectadv)
            self.navigationController?.pushViewController(webVC, animated: true)
        }
      
    }
    func dealMailBtn(){
        
        if let ur = self.url, ur.hasPrefix("http"){
            relayout(showMail: true)
        }else{
            relayout(showMail: false)
        }
    }
    func relayout(showMail: Bool){
        maibutton.isHidden = !showMail
           if showMail{
               maibutton.snp.remakeConstraints { (make) in
                   make.right.equalTo(navCustomView).offset(-15)
                   make.width.lessThanOrEqualTo(100)
                   make.centerY.equalTo(self.navCustomView.popBtn)
                   make.height.equalTo(20)
               }
               posbutton.snp.remakeConstraints { (make) in
                   make.right.equalTo(maibutton.snp.left).offset(-20)
                   make.width.lessThanOrEqualTo(100)
                   make.centerY.equalTo(self.navCustomView.popBtn)
                   make.height.equalTo(20)
               }
           }else{
               posbutton.snp.remakeConstraints { (make) in
                   make.right.equalToSuperview().offset(-20)
                   make.width.lessThanOrEqualTo(100)
                   make.centerY.equalTo(self.navCustomView.popBtn)
                   make.height.equalTo(20)
               }
           }
        
       }
    

}

