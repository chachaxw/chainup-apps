//
//  EXShieldingView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXShieldingView: UIView {
    
    var tableViewRowDatas : [EXRelationShip] = []

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXShieldTC.classForCoder()], ["EXShieldTC"])
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView])
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        getData()
    }
    
    func getData(){
        otcApi.rx.request(OTCAPIEndPoint.personRelationship(relationType: "BLACKLIST", pageSize: "1000", page: "1")).MJObjectMap(EXShieldEntity.self).subscribe(onSuccess: {[weak self] (entity) in
            self?.tableViewRowDatas = entity.relationshipList
            self?.tableView.reloadData()
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension EXShieldingView : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXShieldTC = tableView.dequeueReusableCell(withIdentifier: "EXShieldTC") as! EXShieldTC
        cell.setCell(entity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editaction = UITableViewRowAction.init(style: UITableViewRowAction.Style.destructive, title: "address_action_delete".localized()) {[weak self](action, indexpath)in
            guard let mySelf = self else{return}
            mySelf.removeprompt(mySelf.tableViewRowDatas[indexPath.row])
        }
//        var img = UIImage.init(named: "AppIcon")
//        img = img?.yy_imageByResize(to: CGSize.init(width: 50, height: 56), contentMode: UIViewContentMode.right)
//        editaction.backgroundColor = UIColor.init(patternImage: img!)
        return [editaction]
    }
    
    //Remove prompt
    func removeprompt(_ entity : EXRelationShip){
        let alert = EXNormalAlert()
        alert.configAlert(title: LanguageTools.getString(key: "common_tip_removeBlackList"), message: "", passiveBtnTitle: LanguageTools.getString(key: "common_action_thinkAgain"), positiveBtnTitle: LanguageTools.getString(key: "common_text_btnConfirm"))
        alert.alertCallback = {[weak self]tag in
            if tag == 1{//
                
            }else if tag == 0{
                self?.userContactsRemove(entity)
            }
        }
        EXAlert.showAlert(alertView: alert)
    }
    
    //Remove blacklist
    func userContactsRemove(_ entity : EXRelationShip){
        otcApi.rx.request(OTCAPIEndPoint.userContactsRemove(uid: entity.userId)).MJObjectMap(EXBaseModel.self).subscribe(onSuccess: {[weak self] (model) in
            guard let mySelf = self else{return}
            for i in 0..<mySelf.tableViewRowDatas.count{
                if mySelf.tableViewRowDatas[i].userId == entity.userId{
                    mySelf.tableViewRowDatas.remove(at: i)
                    mySelf.tableView.reloadData()
                    break
                }
            }
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
}

