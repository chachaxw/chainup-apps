//
//  EXRealNameCertificationChooseView.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXRealNameCertificationChooseView: UIView {
    
    lazy var tableViewNameDatas : [String] = [LanguageTools.getString(key: "kyc_text_country")]
    
    lazy var tableViewRowDatas : [EXRealNameEntity] = []
    
    var regionEntity = RegionEntity()
    {
        didSet{
            if tableViewRowDatas.count > 0{
                if LanguageTools.isHan() {
                    tableViewRowDatas[0].text = regionEntity.cnName
                }else{
                    tableViewRowDatas[0].text = regionEntity.enName
                }
                tableViewRowDatas[0].info = regionEntity.dialingCode
                tableViewRowDatas[0].numberCode = regionEntity.numberCode
                tableView.reloadData()
            }
        }
    }

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXRealNameOneTC.classForCoder()], ["EXRealNameOneTC"])
        return tableView
    }()
    
    lazy var nextBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.isEnabled = false
        btn.extSetAddTarget(self, #selector(clickNextBtn))
        btn.setTitle(LanguageTools.getString(key: "common_action_next"), for: UIControl.State.normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView,nextBtn])
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(nextBtn.snp.top).offset(-10)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-30 - TABBAR_BOTTOM)
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        setDatas()
    }
    
    func setDatas(){
        for str in tableViewNameDatas{
            let entity = EXRealNameEntity()
            entity.title = str
            switch str{
            case LanguageTools.getString(key: "kyc_text_country"):
                entity.placeholder = LanguageTools.getString(key: "common_action_select")
                entity.type = "1"
                if let rentity = CountryList.getRegion(UserInfoEntity.sharedInstance().countryCode){
                    regionEntity = rentity
                    if LanguageTools.isHan() {
                        entity.text = regionEntity.cnName
                    }else{
                        entity.text = regionEntity.enName
                    }
                    entity.info = regionEntity.dialingCode
                    entity.numberCode = regionEntity.numberCode
                }else if let rentity = CountryList.getRegionWithNumber(EXAppConfigManager.sharedInstance.getDefaultCountryCodeReal()){
                    regionEntity = rentity
                    if LanguageTools.isHan() {
                        entity.text = regionEntity.cnName
                    }else{
                        entity.text = regionEntity.enName
                    }
                    entity.info = regionEntity.dialingCode
                    entity.numberCode = regionEntity.numberCode
                }else if let rentity = CountryList.getRegion(EXAppConfigManager.sharedInstance.getDefaultCountryCode()){
                    regionEntity = rentity
                    if LanguageTools.isHan() {
                        entity.text = regionEntity.cnName
                    }else{
                        entity.text = regionEntity.enName
                    }
                    entity.info = regionEntity.dialingCode
                    entity.numberCode = regionEntity.numberCode
                }
            default:
                break
            }
            tableViewRowDatas.append(entity)
        }
        tableView.reloadData()
        observerTextField()
    }
    
    func observerTextField(){
        
        for entity in tableViewRowDatas{
            if entity.info == ""{
                nextBtn.isEnabled = false
                return
            }
        }
        nextBtn.isEnabled = true
    }
    
    //get data
    func getData(){
        appApi.hideAutoLoading()
        appApi.rx.request(AppAPIEndPoint.kycGetToken).MJObjectMap(EXRealNameModel.self).subscribe(onSuccess: {[weak self] (model) in
            EXRealNameModelManager.sharedInstance.model = model
            self?.gotoNext()
        }) {[weak self] (error) in
            self?.gotoNext()
            }.disposed(by: disposeBag)
    }
    
    //Obtain copy
    func getLanguage(){
        appApi.hideAutoLoading()
        appApi.rx.request(AppAPIEndPoint.kycGetWriting).MJObjectMap(EXRealNameWriteModel.self).subscribe(onSuccess: { (model) in
            EXRealNameModelManager.sharedInstance.model.language = model.language
        }) { (error) in
            
            }.disposed(by: disposeBag)
    }
    
    //Click Next
    @objc func clickNextBtn(){
//        nextBtn.showLoading()
        showLoading1()
        //If the setting is on and China+86 is selected
        if EXAppConfigManager.sharedInstance.isOpenFaceID() && self.regionEntity.dialingCode == "+86"{
            getData()
        }else{
            gotoNext()
        }
    }
    
    //Go to the next step
    func gotoNext(){
//        nextBtn.hideLoading()
        hideLoading1()
        if EXRealNameModelManager.sharedInstance.model.openAuto == "1" && self.regionEntity.dialingCode == "+86" && EXRealNameModelManager.sharedInstance.model.limitFlag != "1"{//If there is kyc in Chinese Mainland and the limit is not exceeded, enter kyc for verification,
            self.yy_viewController?.navigationController?.popViewController(animated: false)
            guard let appDelegate = UIApplication.shared.delegate else {
                return
            }
            let vc = WebVC()
            vc.modalPresentationStyle = .fullScreen
            vc.loadUrl(EXRealNameModelManager.sharedInstance.model.toKenUrl)
            appDelegate.window??.rootViewController?.present(vc, animated: true, completion: nil)
            return
        }
        
        appApi.rx.request(AppAPIEndPoint.kycConfig).MJObjectMap(EXKYCConfigModel.self,false).subscribe(onSuccess: {[weak self] (model) in
            guard let mySelf = self else{return}
             //If singpass is enabled, then singpass. If it is not enabled but template 2 is selected, it also needs to be redirected
            if model.openSingPass == "1" || model.verfyTemplet == "2"{
                var url = ""
                if model.openSingPass == "1"{//URL of singpass
                    url = model.h5_singpass_url
                }else{//Template 2 URL
                    url = model.h5_templet2_url
                }
                let country = mySelf.regionEntity.numberCode
                let countryKeyCode = mySelf.regionEntity.dialingCode.replacingOccurrences(of: "+", with: "")
                RegionManager.sharedInstance.regionEntity = mySelf.regionEntity
                if let url1 = URL.init(string: url){
                    if let _ = url1.query {
                        url = url + "&country=" + country + "&countryKeyCode=" + countryKeyCode
                    }else {
                        url = url + "?country=" + country + "&countryKeyCode=" + countryKeyCode
                    }
                }
                self?.yy_viewController?.navigationController?.popViewController(animated: false)
                guard let appDelegate = UIApplication.shared.delegate else {
                    return
                }
                let vc = WebVC()
                vc.modalPresentationStyle = .fullScreen
                vc.loadUrl(url)
                appDelegate.window??.rootViewController?.present(vc, animated: true, completion: nil)
            }else{
                //Other situations are subject to manual review
                self?.gotoRealName()
            }
        }) {[weak self] (error) in
            self?.gotoRealName()
        }.disposed(by: disposeBag)
        
    }
    
    func gotoRealName(){
        //Enter manual review
        let vc = EXRealNameOneVC()
        vc.mainView.regionEntity = self.regionEntity
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXRealNameCertificationChooseView : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewNameDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXRealNameOneTC = tableView.dequeueReusableCell(withIdentifier: "EXRealNameOneTC") as! EXRealNameOneTC
        cell.setCell(entity)
        
        cell.textfieldValueChangeBlock = {[weak self] in
            self?.observerTextField()
        }
        
        cell.clickTextBlock = {[weak self](entity,textFieldSelect) in
            guard let mySelf = self else{return}
            if entity.title == LanguageTools.getString(key: "kyc_text_country"){
                let vc = RegionVC()
                vc.clickRegionCellBlock = {rentity in
                    mySelf.regionEntity = rentity
                    mySelf.observerTextField()
                }
                textFieldSelect.normalStyle()
                EXAlert.showVc(controller: vc,ratio: 0.9)
//                vc.modalPresentationStyle = .fullScreen
//                self?.yy_viewController?.navigationController?.present(vc, animated: true, completion: nil)
            }
        }
        return cell
    }
}

