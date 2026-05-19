//
//  EXOTCMerchantListView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import JXPagingView
import EXKit

class EXOTCMerchantListView: NibBaseView {
    
    @IBOutlet var merchantTable: UITableView!
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    var uid:String?
    var page:Int = 1
    var listModel:EXMerchantAdListModel = EXMerchantAdListModel()
    
    typealias TradeActionCallback = (EXAdListItem,OTCTradeType) -> ()
    var onTradeConfirmCallback :TradeActionCallback?

    var otcTradeType :OTCTradeType = .none
    
    func beginLoading() {
        self.merchantTable.mj_header.beginRefreshing()
    }
    
    func loadAdlist() {
        var type = ""
        if otcTradeType == .otcbuy {
            type = "buy"
        }else if otcTradeType == .otcsell {
            type = "sell"
        }
        if type.isEmpty {
            
            return
        }
        
        guard let mUid = self.uid else {
            return
        }
        
        otcApi.rx
            .request(.personAds(uid: mUid, pageSize: "20", page:("\(page)"), adType: type))
            .customObjectMap(EXMerchantAdListModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                self?.handleAdlist(model)
            }) {[weak self] (error) in
                self?.handleAdlist(nil)
                
            }.disposed(by: disposeBag)
        
    }
    
    func handleAdlist(_ list:EXMerchantAdListModel? ) {
        if let model = list {
            if page == 1 {
                self.listModel = model
                listModel.adList = model.adList
            }else {
                listModel.adList = listModel.adList + model.adList
            }
            self.resetRefresh()
            if model.adList.count < 20 {
                self.merchantTable.mj_footer.endRefreshingWithNoMoreData()
            }
            self.merchantTable.reloadData()
        }else {
            self.resetRefresh()
        }
    }
    
    func resetRefresh() {
        self.merchantTable.mj_header.endRefreshing()
        self.merchantTable.mj_footer.endRefreshing()
    }
 
    override func onCreate() {
        self.merchantTable.register(UINib.init(nibName: "EXOTCMerchantAdCell", bundle: nil), forCellReuseIdentifier: "EXOTCMerchantAdCell")
        self.handleRefresh()
    }
    
    func handleRefresh(){
        self.merchantTable.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else {return}
            mySelf.page = 1
            mySelf.loadAdlist()
        })
        self.merchantTable.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else {return}
            mySelf.page += 1
            mySelf.loadAdlist()
        })
    }
    
    deinit {
        listViewDidScrollCallback = nil
    }
}

extension EXOTCMerchantListView : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 151
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listModel.adList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXOTCMerchantAdCell",for:indexPath)  as! EXOTCMerchantAdCell
        let item = self.listModel.adList[indexPath.row]
        cell.tradeType = self.otcTradeType
        cell.bindMechantCellData(item: item)
        cell.onConfirmCallback = {[weak self] in
            guard let `self` = self else {return}
            self.handleConfirmAction(item)
         }
        return cell
    }
    
    func handleConfirmAction(_ item:EXAdListItem) {
        
        let pass = EXAuthenticManagerTool.kycRightPassed(right: .c2c)
        if pass == false{
            return
        }
        
        //The merchant's type is reversed
        var typeForBuyer:OTCTradeType = .none
        if self.otcTradeType == .otcbuy {
            typeForBuyer = .otcsell
        }else if self.otcTradeType == .otcsell {
            typeForBuyer = .otcbuy
        }
        self.onTradeConfirmCallback?(item,typeForBuyer)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.listViewDidScrollCallback?(scrollView)
    }
}

extension EXOTCMerchantListView : JXPagingViewListViewDelegate {
    
    func listView() -> UIView {
        return self
    }
    
    func listScrollView() -> UIScrollView {
        return self.merchantTable
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallback = callback
    }
}

