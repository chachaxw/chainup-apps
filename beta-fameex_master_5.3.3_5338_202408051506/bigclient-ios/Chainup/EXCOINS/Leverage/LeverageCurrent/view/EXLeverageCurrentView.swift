//
//  EXLeverageCurrentView.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXLeverageCurrentView: UIView {
    var filterData : [String : String] = ["isShowCanceled" : "0"]

    var entity = CoinMapEntity()
    {
        didSet{
            self.getDatas()
        }
    }
    
    var tableViewRowDatas : [EXCurrentEntrustEntity] = []
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.emptyDataSetSource = self
        tableView.extRegistCell([EXLeverageCurrentTC.classForCoder()], ["EXLeverageCurrentTC"])
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
            guard let self else {return}
            self.getDatas()
        })
    }
    
    func showFooter() {
        footerView.isHidden = false
        self.updateInsetToBottom(false)
    }
    
    func hideFooter() {
        footerView.isHidden = true
        self.updateInsetToBottom(true)
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
        self.tableView.scroll(to: .top, animated: false)
        self.getDatas()
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
            
            var symbol = entity.name.replacingOccurrences(of: "/", with: "").lowercased()
            var isShowCanceled = "1"
            if let isShowCanceled1 = filterData["isShowCanceled"]{
                if isShowCanceled1 == "1"{
                    isShowCanceled = "0"
                }else{
                    isShowCanceled = "1"
                }
            }
                    
            var side = ""
            if let side1 = filterData["side"]{
                side = side1
            }
            var type = ""
            if let type1 = filterData["type"]{
                type = type1
            }
            
            var coin = ""
            if let coin1 = filterData["coin"]{
                coin = coin1.lowercased()
            }
            
            if let symbol1 = filterData["symbol"] {
                symbol = symbol1
            }
          
            let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByAliaName(symbol)
            if entity.name != ""{
                symbol = entity.symbol
            }

            appApi.rx.request(.getEntrustHistorySearch(page: "1",
                                                       pageSize: "100",
                                                       entrust: "1",
                                                       side: side,
                                                       symbol: symbol,
                                                       orderType: "2",
                                                       status: "",
                                                       isShowCanceled: isShowCanceled,
                                                       quote: "",
                                                       type : type))
            .MJObjectMap(EXLeverCurrentModel.self)
            .subscribe(onSuccess: {[weak self] (arr) in
                guard let mySelf = self else{return}
                mySelf.checkFooter(arr.orderList.count)
                mySelf.tableViewRowDatas = arr.orderList
                mySelf.tableView.reloadData()
            }, onFailure: { _ in
             
            }, onDisposed: { [weak self] in
                guard let self else { return }
                self.tableView.mj_header.endRefreshing()
            }).disposed(by: disposeBag)
//        }else {
//            let symbol = entity.name.replacingOccurrences(of: "/", with: "").lowercased()
//            appApi.rx.request(.getLeverOrderCurrent(symbol: symbol, pageSize: "100", page: "1"))
//                .MJObjectMap(EXLeverCurrentModel.self).subscribe(onSuccess: {[weak self] (arr) in
//                self?.tableViewRowDatas = arr.orderList
//                self?.tableView.reloadData()
//                self?.endRefresh()
//            }) {[weak self] (error) in
//                self?.endRefresh()
//                }.disposed(by: disposeBag)
//        }
    }
    
    
    //Cancel Order
    func cancelOrder(_ entity : EXCurrentEntrustEntity){
        if entity.status == "0" || entity.status == "1" || entity.status == "3"{
            appApi.rx.request(.cancelLeverOrder(orderId: entity.id, symbol: (entity.baseCoin + entity.countCoin).lowercased())).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: {[weak self] (m) in
                EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_tip_cancelSuccess"))
                self?.getDatas()
            }, onFailure: { _ in
                
            }).disposed(by: disposeBag)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXLeverageCurrentView : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 113
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderEntity = tableViewRowDatas[indexPath.row]
        let cell : EXLeverageCurrentTC = tableView.dequeueReusableCell(withIdentifier: "EXLeverageCurrentTC") as! EXLeverageCurrentTC
        cell.setCell(orderEntity)
        cell.cancelBlock = {[weak self]entity in
            self?.cancelOrder(entity)
        }
        return cell
    }
    
    override func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -85.5
    }
}


