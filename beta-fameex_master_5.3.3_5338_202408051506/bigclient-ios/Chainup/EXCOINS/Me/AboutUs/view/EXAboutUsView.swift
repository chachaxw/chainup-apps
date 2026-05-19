//
//  EXAboutUsView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXAboutUsView: UIView {
    
    lazy var tableViewRowDatas : [EXAboutEntity] = []

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.estimatedRowHeight = 52
        tableView.extRegistCell([EXAboutTC.classForCoder()], ["EXAboutTC"])
        return tableView
    }()
    
    lazy var updateBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.extSetAddTarget(self, #selector(clickUpdateBtn))
        btn.setTitle("personal_action_checkUpdate".localized(), for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([tableView,updateBtn])
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        updateBtn.snp.makeConstraints { (make) in
            make.top.equalTo(tableView.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-(getSafeAreaBottom() + 16))
            make.height.equalTo(44)
        }
        
        getData()
    }
    
    //get data
    func getData(){
        let enti = EXAboutEntity()
        enti.title = "common_text_versionCode".localized()
        let info = Bundle.main.infoDictionary
        
        if let str = info?["CFBundleShortVersionString"] as? String,let s = info?["exChainupBundleVersion"] as? String{
            enti.content = "V" + str + "(\(s))"
        }
        tableViewRowDatas.append(enti)
        tableView.reloadData()
        
        appApi.rx.request(AppAPIEndPoint.getAbout)
            .MJObjectMap(CommonAryModel.self)
            .subscribe(onSuccess: {[weak self] (entity :CommonAryModel) in
                if let arr = entity.dictAry as? Array<[String : Any]>{
                    for dict in arr{
                        let exentity = EXAboutEntity()
                        if let content = dict["content"] as? String{
                            exentity.content = content
                        }
                        if let title = dict["title"] as? String{
                            exentity.title = title
                        }
                        exentity.showCopy = true
                        self?.tableViewRowDatas.append(exentity)
                    }
                    self?.tableView.reloadData()
                }
            }, onFailure: { _ in
                
            }).disposed(by: disposeBag)
        
    }
    
    //Click on the update button
    @objc func clickUpdateBtn(){
        BusinessTools.checkVersion("1")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXAboutUsView : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXAboutTC = tableView.dequeueReusableCell(withIdentifier: "EXAboutTC") as! EXAboutTC
        cell.setCell(entity)
        return cell
    }
}

