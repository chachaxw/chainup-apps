//
//  EXIDAuthenticViewController.swift
//  Chainup
//
//  Created by cwd on 2023/11/1.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
//import
class EXIDAuthenticViewController: NavCustomVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    override func setNavCustomV() {
        navtype = .listtitle
        self.lastVC = false
        self.setTitle("kyc_page_name".localized())
        
    }

    func configView(){
        contentView.backgroundColor = .Ex.fill2
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
            make.left.right.equalToSuperview()
        }
    }
    
    
    
    lazy var mainView: EXIDAuthenticMainView = {
        let v = EXIDAuthenticMainView()
        return v
    }()
}

extension EXIDAuthenticViewController{
    
//    func configNoti(){
//        _ = NotificationCenter.default.rx
//            .notification(Notification.Name(rawValue: EXAuthenticManagerTool.keySumsubKey))
//            .take(until: self.rx.deallocated)
//            .subscribe(onNext: {[weak self] noti in
//                self?.getData()
//            })
//    }
    
    func getData(){
        getkyclist()
    }
    
    
    func getkyclist() {
        let _ = appApi.rx.request(.getkycList)
            .MJObjectMap(CommonAryModel.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let `self` = self else { return }
                self.dealKycData(model)
            }, onFailure: {  _ in
                
            }, onDisposed: {
                
            })
    }
    
    
    func dealKycData(_ model:CommonAryModel) {
        let data = EXIDAuthenticModel.getALLAuthLevelData(model: model)
        self.mainView.dataList = data
        
    }
}
