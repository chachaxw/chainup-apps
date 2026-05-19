//
//  EXKlineDetailDepthView.swift
//  Chainup
//
//  Created by youbin on 2023/6/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXPagingView

class EXKlineDetailDepthView: EXTableView {
    
    lazy var depthDatas: [TransactionDepthEntity] = {
        var datas: [TransactionDepthEntity] = []
        for _ in 0..<20{
            datas.append(TransactionDepthEntity())
        }
        return datas
    }()
    
    var asksAlllength = "0"//Total selling depth
    var buysAlllength = "0"//Total depth of purchase
    
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
        tableView.register(TransactionDepthTC.self, forCellReuseIdentifier: NSStringFromClass(TransactionDepthTC.self))
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel?.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .KLineDepth(let item):
                var pricedecimals : Int = 8
                var voldecimals   : Int = 8
                if let _entity = item.2 {
                    pricedecimals = Int(_entity.price) ?? 8
                    voldecimals = Int(_entity.volume) ?? 8
                }
                let depthItem = item.0
                let bidAry = depthItem.reversed().filter { item -> Bool in
                    return item.type == .bid
                }
                let askAry = depthItem.filter { item -> Bool in
                    return item.type == .ask
                }
                let asksN = min(20, askAry.count)
                let buysN = min(20, bidAry.count)
                self.asksAlllength = "0"
                self.buysAlllength = "0"
                //wipe data 
                self.reloadDepthTableViewRowDatas()
                for i in 0..<asksN{
                    let item = askAry[i]
                    self.depthDatas[i].asks = NSString(string:  "\(item.value)").decimalString1(pricedecimals)
                    self.depthDatas[i].asksNum = NSString(string:  "\(item.amount)").decimalString1(voldecimals)
                    
                    self.asksAlllength = NSString(string: self.asksAlllength).adding(self.depthDatas[i].asksNum, decimals: voldecimals)
                    self.depthDatas[i].askslength = self.asksAlllength
                }
                
                for i in 0..<buysN{
                    let item = bidAry[i]
                    self.depthDatas[i].buys = NSString(string:  "\(item.value)").decimalString1(pricedecimals)
                    self.depthDatas[i].buysNum = NSString(string:  "\(item.amount)").decimalString1(voldecimals)
                    self.buysAlllength = NSString.init(string: self.buysAlllength).adding(self.depthDatas[i].buysNum, decimals: voldecimals)
                    self.depthDatas[i].buyslength = self.buysAlllength
                }
                
                for (idx,item) in self.depthDatas.enumerated() {
                    if let cell = self.tableView.cellForRow(at: IndexPath.init(row: idx + 1, section: 0)) as? TransactionDepthTC {
                        cell.setCell(item, index: idx, asksAlllength: self.asksAlllength, buysAlllength: self.buysAlllength)
                    }
                }
                
            default:
                break
            }
        }).disposed(by: self.disposeBag)
        
    }
    
    func reloadDepthTableViewRowDatas(){
        var array : [TransactionDepthEntity] = []
        for _ in 0..<20{
            let entity = TransactionDepthEntity()
            array.append(entity)
        }
        depthDatas = array
    }
}


extension EXKlineDetailDepthView{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.depthDatas.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            if let _entity = self.viewModel?.entity {
                let volumeTitle = "charge_text_volume".localized()+"(\(EXAppMarketManager.sharedInstance.getMarketLeft(_entity.name).aliasName()))"
                let priceTitle = "contract_text_price".localized() + "(\(EXAppMarketManager.sharedInstance.getMarketRight(_entity.name).aliasName()))"
                
                let cell : EXMarketDetailRecordCell = tableView.dequeueReusableCell(withIdentifier: "EXMarketDetailRecordCell") as! EXMarketDetailRecordCell
                cell.bindNames(leftTitle: volumeTitle, middleTitle: priceTitle, rightTitle: volumeTitle)
                return cell
            } else {
                return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
            }
            
        } else {
            return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TransactionDepthTC.self), for: indexPath)
        }
    }
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
         let contentCell = cell as? TransactionDepthTC
            contentCell?.setCell(self.depthDatas[indexPath.row - 1], index: indexPath.row - 1, asksAlllength: self.asksAlllength, buysAlllength: self.buysAlllength)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    
}



///////////////////////////////////////////////////////////////
extension EXKlineDetailDepthView: JXPagingViewListViewDelegate{
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
        if depthDatas.count == 0 {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.tableView.reloadData()
            }
        }
    }
    
}

