//
//  EXKlineDetailDealView.swift
//  Chainup
//
//  Created by youbin on 2023/6/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXPagingView

class EXKlineDetailDealView: EXTableView {
    
    var tableViewRowDatas : [EXTickDataItem] = []
    
    var viewModel: EXKlineDetailNewViewModel?
    
    required init(viewModel: EXViewModelProtocol?) {
        self.viewModel = viewModel as? EXKlineDetailNewViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        tableView.register(UINib.init(nibName: "EXMarketDetailRecordCell", bundle: nil), forCellReuseIdentifier: "EXMarketDetailRecordCell")
        tableView.register(TransactionDetailsTC.self, forCellReuseIdentifier: NSStringFromClass(TransactionDetailsTC.self))
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel?.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .OrderHistory(let items):
                self.handleOrderData(items: items)
            
            case .OrderData(let items):
                self.handleOrderData(items: items)
            default:
                break
            }
        }).disposed(by: self.disposeBag)
        
        
        
    }
    
    func handleOrderData(items:[EXTickDataItem]) {
        guard let _entity = self.viewModel?.entity else { return }
        tableViewRowDatas = items + tableViewRowDatas
        if tableViewRowDatas.count > 20 {
            tableViewRowDatas.removeSubrange(20...tableViewRowDatas.count - 1)
        }
        for (idx,item) in tableViewRowDatas.enumerated() {
            if let cell = tableView.cellForRow(at: IndexPath.init(row: idx + 1, section: 0)) as? TransactionDetailsTC {
                cell.setCellWithEntity(item, volDecimal:_entity.volDecimal(), priceDecimal: _entity.priceDecimal())
            }
        }
    }
    
}



extension EXKlineDetailDealView {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 21
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            if let _entity = self.viewModel?.entity {
                let volumeTitle = "charge_text_volume".localized()+"(\(EXAppMarketManager.sharedInstance.getMarketLeft(_entity.name).aliasName()))"
                let priceTitle = "contract_text_price".localized() + "(\(EXAppMarketManager.sharedInstance.getMarketRight(_entity.name).aliasName()))"
                
                let cell : EXMarketDetailRecordCell = tableView.dequeueReusableCell(withIdentifier: "EXMarketDetailRecordCell") as! EXMarketDetailRecordCell
                cell.bindNames(leftTitle: "kline_text_dealTime".localized(), middleTitle: priceTitle, rightTitle: volumeTitle)
                return cell
                
            } else {
                return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TransactionDetailsTC.self), for: indexPath)
            }
        } else {
            
            return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TransactionDetailsTC.self), for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
}





extension EXKlineDetailDealView: JXPagingViewListViewDelegate{
    func listView() -> UIView {
        return self
    }
    
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.scrollCallback = callback
    }
    
    func listWillAppear() {
        if tableViewRowDatas.count == 0 {
            self.viewModel?.getHistoryKline()
        }
    }
    
    
}
