//
//  EXHistoryEntrustView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import MJRefresh
import EXKit
class EXHistoryEntrustView: UIView {
    
    var filterData : [String : String] = ["isShowCanceled" : "0"]
    
    var entity = CoinMapEntity()
    {
        didSet{
            self.filterData["symbol"] = entity.symbol
            self.getDatas()
        }
    }
    
    var page: UInt8 = 1
    let pageSize: UInt8 = 20
    
    var tableViewRowDatas : [EXCurrentEntrustEntity] = []
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.emptyDataSetSource = self
        tableView.extRegistCell([EXHistoryEntrustTC.classForCoder()], ["EXHistoryEntrustTC"])
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

        
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page = 1
            mySelf.getDatas()
        })
        self.tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.getDatas()
        })
        self.tableView.mj_footer.isHidden = true
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
    
    func getDatas(){
        self.getHistorywithclose()
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
        var startTime = ""
        if let startTime1 = filterData["startTime"]{
            startTime = startTime1
        }
        var endTime = ""
        if let endTime1 = filterData["endTime"]{
            endTime = endTime1
        }
        var status: String? = nil
        if let status1 = filterData["status"] {
            status = status1
        }
        let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByAliaName(symbol)
        if entity.name != ""{
            symbol = entity.symbol
        }
        appApi.rx.request(.getHistoryEntrustList(symbol: symbol, pageSize: String(pageSize), page: String(page), isShowCanceled: isShowCanceled, side: side, type: type, startTime: startTime, endTime: endTime,status: status))
            .MJObjectMap(EXHistoryEntrustArr.self).subscribe(onSuccess: {[weak self] (arr) in
                guard let mySelf = self else{return}
                if mySelf.page == 1{
                    mySelf.tableViewRowDatas.removeAll()
                }
                for entity in arr.orderList{
                    mySelf.tableViewRowDatas.append(entity)
                }
                mySelf.tableView.mj_footer.isHidden = false
                if arr.orderList.count < mySelf.pageSize {
                    mySelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    mySelf.tableView.mj_footer.resetNoMoreData()
                }
                
                mySelf.page = mySelf.page + 1
                mySelf.tableView.reloadData()
            }, onFailure: { _ in
                
            }, onDisposed: { [weak self] in
                guard let self else { return }
                self.endRefresh()
            }).disposed(by: disposeBag)
    }
    
    func endRefresh(){
        self.tableView.mj_header.endRefreshing()
        self.tableView.mj_footer.endRefreshing()
    }
    
    
    func endRefreshNorMore() {
        self.tableView.mj_header.endRefreshing()
        self.tableView.mj_footer.endRefreshingWithNoMoreData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EXHistoryEntrustView : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 162
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderEntity = tableViewRowDatas[indexPath.row]
        let cell : EXHistoryEntrustTC = tableView.dequeueReusableCell(withIdentifier: "EXHistoryEntrustTC") as! EXHistoryEntrustTC
        cell.setCell(orderEntity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = tableViewRowDatas[indexPath.row]
        if entity.status == "2" || entity.status == "3" || (entity.status == "4" && (entity.deal_volume as NSString).isBig("0")) {
            let vc = EXHistoryDetailVC()
            vc.entity = entity
            vc.type = .coin
            self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -85.5
    }
    
}

