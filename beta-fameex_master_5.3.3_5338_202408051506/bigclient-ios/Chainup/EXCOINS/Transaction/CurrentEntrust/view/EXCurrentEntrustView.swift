//
//  EXCurrentEntrustView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXCurrentEntrustView: UIView {
    
    var filterData : [String : String] = ["isShowCanceled" : "0"]

    var entity = CoinMapEntity()
    {
        didSet{
            self.getDatas()
        }
    }
    
    var page = 1

    var tableViewRowDatas : [EXCurrentEntrustEntity] = []

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.emptyDataSetSource = self
        tableView.extRegistCell([EXCurrentEntrustTC.classForCoder()], ["EXCurrentEntrustTC"])
        return tableView
    }()
    
    lazy var footerView : EXEntrustFooterView = {
        let view = EXEntrustFooterView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        addSubview(footerView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        footerView.snp.makeConstraints { (make) in
            make.top.equalTo(tableView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.getDatas()
        })
        
    }
    
    func updateInsetToBottom(_ isMarginBottom:Bool) {
        if isMarginBottom {
            tableView.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }else {
            tableView.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(footerView.snp.top)
            }
        }
    }
    
    func reloadFilter(_ params:[String:String]){
        self.filterData = params
        self.page = 1
        self.tableView.scroll(to: .top, animated: false)
        self.getDatas()
    }
    
    func showFooter() {
        footerView.isHidden = false
        self.updateInsetToBottom(false)
    }
    
    func hideFooter() {
        footerView.isHidden = true
        self.updateInsetToBottom(true)
    }
    
    func checkFooter(_ resultCount:Int) {
        if resultCount == 0 {
            self.hideFooter()
        }else {
            if let market1 = filterData["market"]{
                if market1 != EXFoldItemType.forceAll.rawValue,market1.count > 0{
                    self.hideFooter()
                }else {
                    self.showFooter()
                }
            }else {
                self.showFooter()
            }
        }
    }
    
    func getDatas(){
        
        //Since the control returns an inverse, we need to invert the var symbol=""
        
        var symbol = entity.name.replacingOccurrences(of: "/", with: "").lowercased()
        
        var side: String? = nil
        if let side1 = filterData["side"]{
            side = side1
        }
        var type: String? = nil
        if let type1 = filterData["type"]{
            type = type1
        }
        
        if let symbol1 = filterData["symbol"]{
            symbol = symbol1
        }
        
        let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByAliaName(symbol)
        if entity.name != ""{
            symbol = entity.symbol
        }
        
        appApi.rx.request(.getNewEntrustList(symbol: symbol, pageSize: "100", page: "1", side: side, type: type))
            .MJObjectMap(EXCurrentEntrustArr.self)
            .subscribe(onSuccess: {[weak self] (arr) in
                self?.tableViewRowDatas = arr.orderList
                self?.tableView.reloadData()
                self?.endRefresh()
            }) {[weak self] (error) in
                self?.endRefresh()
            }.disposed(by: disposeBag)
    }
    
    //End refresh
    func endRefresh(){
        tableView.mj_header.endRefreshing()
    }
    
    //Cancel Order
    func cancelOrder(_ entity : EXCurrentEntrustEntity){
        if entity.status == "0" || entity.status == "1" || entity.status == "3"{
            appApi.rx.request(.cancelOrder(orderId: entity.id, symbol: (entity.baseCoin + entity.countCoin).lowercased())).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: {[weak self] (m) in
                EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_tip_cancelSuccess"))
                self?.getDatas()
            }) { (error) in
                
                }.disposed(by: disposeBag)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EXCurrentEntrustView : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 113
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderEntity = tableViewRowDatas[indexPath.row]
        let cell: EXCurrentEntrustTC = tableView.dequeueReusableCell(withIdentifier: "EXCurrentEntrustTC") as! EXCurrentEntrustTC
        cell.setCell(orderEntity)
        cell.cancelBlock = {[weak self]entity in
            self?.cancelOrder(orderEntity)
        }
        return cell
    }
    
    override func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -85.5
    }
}

