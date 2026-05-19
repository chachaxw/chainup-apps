//
//  EXPosPositionDetailVC.swift
//  Chainup
//
//  Created by lcus on 2023/10/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXPosPositionDetailVC: NavCustomVC {

    
    var projectID:String = ""
    var url:String?
    var maibutton = UIButton()
    var posbutton = UIButton()
    var infoVM:EXPosProjectDetailVM = EXPosProjectDetailVM()
    var detailView:EXPosDetailPostionView = {
        let View = EXPosDetailPostionView()
        return View
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
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
        // Do any additional setup after loading the view.
        infoVM.getProjectInfo(projectId: projectID, MapType: EXPosDetailPostionEnity.self) {[weak self] (enity) in
            
            let postionEnity = enity as! EXPosDetailPostionEnity
            self?.url = postionEnity.url
            EXLogger.debug(message: "postionEnity = \(postionEnity.url)")
            self?.dealMailBtn()
            let listData = self?.infoVM.packgeCellData(enity:postionEnity)
            self?.detailView.dataEnity = enity as! EXPosDetailPostionEnity
            self?.detailView.dataSouce = listData ?? []
        };
        
        
        
    }
    
    override func setNavCustomV() {
        self.navCustomView.backgroundColor = UIColor.ThemeNav.bg
        
        let img =  UIImage.svgImage(named: "personal_mail",version: .five)
        maibutton.setImage(img, for: .normal)
        maibutton.addTarget(self, action: #selector(infoClick), for: .touchUpInside)
        navCustomView.backView.addSubview(maibutton)
        maibutton.isHidden = true
        
        let tipMine = EXPosDetailServer.sharedInstance.tipMine
        posbutton.setTitle(tipMine, for: .normal)
        posbutton.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        posbutton.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        posbutton.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        navCustomView.addSubview(posbutton)
       
        
        maibutton.snp.makeConstraints { (make) in
            make.right.equalTo(navCustomView).offset(-15)
            make.width.lessThanOrEqualTo(100)
            make.centerY.equalTo(self.navCustomView.popBtn)
            make.height.equalTo(20)
        }
        posbutton.snp.makeConstraints { (make) in
            make.right.equalTo(maibutton.snp.left).offset(-20)
            make.width.lessThanOrEqualTo(100)
            make.centerY.equalTo(self.navCustomView.popBtn)
            make.height.equalTo(20)
        }
        
        if maibutton.isHidden {
            posbutton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-20)
                make.width.lessThanOrEqualTo(100)
                make.centerY.equalTo(self.navCustomView.popBtn)
                make.height.equalTo(20)
            }
        }
        
    }
    @objc  func buttonClick() {
        if XUserDefault.getToken() == nil{
            BusinessTools.modalLoginVC()
            return
        }
        let poshistory =  EXPosHistoryVC.instanceFromStoryboard(name: "FreeStacking")
        
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
