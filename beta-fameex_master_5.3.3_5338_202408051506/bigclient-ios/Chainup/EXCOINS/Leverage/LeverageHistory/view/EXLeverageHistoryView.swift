//
//  EXLeverageHistoryView.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXLeverageHistoryView: UIView {
    
    var filterData : [String : String] = ["isShowCanceled" : "0"]
    
    var entity = CoinMapEntity()
    {
        didSet{
            self.filterData["symbol"] = entity.symbol
            self.getDatas()
        }
    }
    
    var page = 1
    let pageSize: UInt8 = 20
    
    var tableViewRowDatas : [EXLeverageHistoryDetailModel] = []
    
    lazy var tableView : UITableView = {
        let v = UITableView()
        v.extUseAutoLayout()
        v.extSetTableView(self, self)
        v.emptyDataSetSource = self
        v.extRegistCell([EXLeverageHistoryTC.classForCoder()], ["EXLeverageHistoryTC"])
        v.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let self else{return}
            self.page = 1
            self.getDatas()
        })
        v.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let self else{return}
            self.page += 1
            self.getDatas()
        })
        v.mj_footer.isHidden = true
        return v
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
    
    func getDatas(){
//        self.getHistorywithopen()
        self.getHistorywithclose()
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
    
    func getHistorywithopen(){
        var symbol = entity.name.replacingOccurrences(of: "/", with: "").lowercased()
        if let symbol1 = filterData["symbol"] {
            symbol = symbol1
        }

        var status = ""
        if let status1 = filterData["status"] {
            status = status1
        }

        let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByAliaName(symbol)
        if entity.name != ""{
            symbol = entity.symbol
        }
        
        //Since the control returns an inverse, we need to invert it here
        var isShowCanceled = ""
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
        appApi.rx.request(.getEntrustHistorySearch(page: String(page),
                                                   pageSize: String(pageSize),
                                                   entrust: "2",
                                                   side: side,
                                                   symbol: symbol,
                                                   orderType: "2",
                                                   status: status,
                                                   isShowCanceled: isShowCanceled,
                                                   quote: "",
                                                   type : type))
            .MJObjectMap(EXLeverHistoryEntrustArr.self).subscribe(onSuccess: {[weak self] (arr) in
                guard let self else{return}
                self.checkFooter(arr.orders.count)
                if self.page == 1{
                    self.tableViewRowDatas.removeAll()
                }
                for entity in arr.orders{
                    self.tableViewRowDatas.append(entity)
                }
                self.tableView.reloadData()
                if arr.orders.count == 0 {
                    self.hideFooter()
                }
                self.tableView.mj_footer.isHidden = false
                if arr.orders.count < self.pageSize {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer.resetNoMoreData()
                }
            }, onFailure: { _ in
                
            }, onDisposed: { [weak self] in
                guard let self else { return }
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            }).disposed(by: disposeBag)
    }
    
    func getHistorywithclose(){
        var symbol = self.entity.symbol

        var coin = ""
        if let coin1 = filterData["coin"]{
            coin = coin1.lowercased()
        }
        var market = ""
        if let market1 = filterData["market"]{
            market = market1.lowercased()
        }
        if coin != "" && market != ""{
            filterData["symbol"] = coin + market
        }
        if let symbol1 = filterData["symbol"]{
            symbol = symbol1
        }
        if symbol == ""{
            return
        }

        //Since the control returns an inverse, we need to invert it here
        var isShowCanceled = ""
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
        var status = ""
        if let status1 = filterData["status"] {
            status = status1
        }
        let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByAliaName(symbol)
        if entity.name != ""{
            symbol = entity.symbol
        }
        appApi.rx.request(.getLeverOrderHistory(page: String(page), pageSize: String(pageSize), symbol: symbol, isShowCanceled: isShowCanceled, side: side,type : type, status: status))
            .MJObjectMap(EXLeverageHistoryModel.self).subscribe(onSuccess: {[weak self] (arr) in
                guard let self else{return}
                if self.page == 1{
                    self.tableViewRowDatas.removeAll()
                }
                for entity in arr.orderList{
                    self.tableViewRowDatas.append(entity)
                }
//                if self.tableViewRowDatas.count == 0 {
//                    self.tableView.mj_footer.isHidden = true
//                } else {
//                    self.tableView.mj_footer.isHidden = false
//                }
                self.tableView.mj_footer.isHidden = false
                if arr.orderList.count < self.pageSize {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer.resetNoMoreData()
                }
                self.tableView.reloadData()
            }, onFailure: { _ in
                
            }, onDisposed: { [weak self] in
                guard let self else { return }
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXLeverageHistoryView : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 162
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderEntity = tableViewRowDatas[indexPath.row]
        let cell : EXLeverageHistoryTC = tableView.dequeueReusableCell(withIdentifier: "EXLeverageHistoryTC") as! EXLeverageHistoryTC
        cell.setLeverCell(orderEntity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = tableViewRowDatas[indexPath.row]
        if entity.status == "2" || entity.status == "3" || (entity.status == "4" && (entity.deal_volume as NSString).isBig("0")){
            let vc = EXHistoryDetailVC()
            vc.leverEntity = entity
            vc.type = .lever
            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -85.5
    }
}

