//
//  EXCapitalRateView.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/15.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXCapitalRateView: EXView {
    var personData = PersonCenterBanner(){
        didSet{
            setData()
        }
    }
    var entity = EXSecurityEntity()
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.extUseAutoLayout()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.extSetTableView(self, self)
        tableView.register(EXCapitalRateCell.self)
        return tableView
    }()

    func setData(){
        entity.name = "personal_Center_text18".localized().formatWithArguments(arguments: [self.personData.coin])
        let info = "personal_Center_text19".localized().formatWithArguments(arguments: [self.personData.rate])
        entity.info = info
        XUserDefault.switchRate(self.personData.fee_trade_status == "1")
        entity.switchOn = XUserDefault.getRateStatus()
        self.tableView.reloadData()
        
    }
    override func setupView() {
        self.backgroundColor = UIColor.ThemeView.bg

        self.addSubViews([tableView])
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
extension EXCapitalRateView:UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXCapitalRateCell
            cell.setCell(entity)
            cell.onValueChangeCallback = {[weak self](b) in
                guard let mySelf = self else{return}
                mySelf.switchV(open:b)
            }
            return cell

    }
    
    func switchV(open: Bool){
        let status = open ? "1" : "0"
        appApi.rx.request(.updatePcTradeFeeStatus(status: status)).MJObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: { [weak self](model) in
//            EXAlert.showSuccess(msg: "login_tip_gestureClosed".localized())
                self?.entity.switchOn = open
                XUserDefault.switchRate(open)
                self?.tableView.reloadData()
        }, onError: { (error) in
            
        }).disposed(by:disposeBag)
        
    }
}
