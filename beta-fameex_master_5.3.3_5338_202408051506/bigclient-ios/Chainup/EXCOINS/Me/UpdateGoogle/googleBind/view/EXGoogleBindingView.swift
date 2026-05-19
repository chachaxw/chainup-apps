//
//  EXGoogleBindingView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/15.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXGoogleBindingView: UIView {
    lazy var tableViewRowDatas : [EXGoogleCellEntity] = [EXGoogleCellEntity(),EXGoogleCellEntity(),EXGoogleCellEntity()]

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self,self)
        tableView.estimatedRowHeight = 44
        tableView.extRegistCell([EXGoogleDownloadTC.classForCoder(),EXGoogleInfoTC.classForCoder(),EXGoogleInputTC.classForCoder()], ["EXGoogleDownloadTC","EXGoogleInfoTC","EXGoogleInputTC"])
        return tableView
    }()
    
    lazy var nextBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.setTitle(LanguageTools.getString(key: "common_action_next"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickNextBtn))
        btn.isEnabled = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView,nextBtn])
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(nextBtn.snp.top).offset(-10)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-30 - TABBAR_BOTTOM)
        }
        setDatas()
        getGoogleDatas()
    }
    
    func setDatas(){
        for i in 0..<tableViewRowDatas.count{
            let entity = tableViewRowDatas[i]
            entity.tag = i + 1
            switch i{
            case 0:
                var str = "register_text_googleAuth".localized()
                if !str.hasPrefix("1."){
                    str = "1." + str
                }
                entity.name = str
            case 1:
                var str = "personal_Center_text13".localized()
                if !str.hasPrefix("2."){
                    str = "2." + str
                }
                entity.name = str
            case 2:
                var str = "safety_explain_googleauthStepTwo".localized()
                if !str.hasPrefix("3."){
                    str = "3." + str
                }
                entity.name = str
            default:
                break
            }
        }
    }
    
    //Click Next
    @objc func clickNextBtn(){
        bindGoogleData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXGoogleBindingView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        switch indexPath.row {
        case 0:
            let cell : EXGoogleDownloadTC = tableView.dequeueReusableCell(withIdentifier: "EXGoogleDownloadTC") as! EXGoogleDownloadTC
            cell.setCell(entity)
            return cell
        case 1:
            let cell : EXGoogleInfoTC = tableView.dequeueReusableCell(withIdentifier: "EXGoogleInfoTC") as! EXGoogleInfoTC
            cell.setCell(entity)
            return cell
        case 2:
            let cell : EXGoogleInputTC = tableView.dequeueReusableCell(withIdentifier: "EXGoogleInputTC") as! EXGoogleInputTC
            cell.setCell(entity)
            cell.textfieldValueChangeBlock = { [weak self] in
                self?.setBtnEnble()
            }
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
}

extension EXGoogleBindingView{
    
    func setBtnEnble(){
        let entity2 = tableViewRowDatas[2]
        if entity2.info1.count > 0 && entity2.info2.count > 0 {
            self.nextBtn.isEnabled =  true
        }else{
            self.nextBtn.isEnabled =  false
        }
    }
    //Get Google data
    func getGoogleDatas(){
        appApi.rx.request(.getGoogle)
            .MJObjectMap(EXGoogleEntity.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                self?.tableViewRowDatas[1].info1 = entity.googleKey
                self?.tableView.reloadData()
            }) { (error) in
                
            }.disposed(by: disposeBag)
    }
    
    //Bind Google Data
    func bindGoogleData(){
        let entity1 = tableViewRowDatas[1]
        let entity2 = tableViewRowDatas[2]
        if entity2.info1 == ""{
            EXAlert.showFail(msg: "common_tip_inputLoginPwd".localized())
            return
        }
        if entity2.info2 == ""{
            EXAlert.showFail(msg: "common_tip_googleAuth".localized())
            return
        }
        //Google verification binding successful
        appApi.rx.request(AppAPIEndPoint.openGoogle(loginPwd: entity2.info1, googleCode: entity2.info2, googleKey: entity1.info1)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: {[weak self] (model) in
            EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_tip_bindSuccess"))
            UserInfoEntity.sharedInstance().googleStatus = "1"
            UserInfoEntity.setTmpDict()
            self?.yy_viewController?.navigationController?.popViewController(animated: true)
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
}

