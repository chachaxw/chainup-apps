//
//  EXQuantPendingVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/5.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXQuantPendingVC: BaseVC {

    var sid:String
    var symbol:String
    var buys:[String] = []
    var sells:[String] = []
    var coinMap:CoinMapEntity = CoinMapEntity()
    var listItem:EXQuantStrategyListItem
    
    typealias QuantOrderCountChanged = (String) -> ()
    var orderCountChange : QuantOrderCountChanged?
    
    var currentPrice:String = ""
    var orderListTimer: Disposable? = nil

    lazy var tableHeader:EXQuantPendingInfo = {
        let header = EXQuantPendingInfo.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 183))
        return header
    }()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
//        tableView.emptyDataSetSource = self
//        tableView.emptyDataSetDelegate = self
        tableView.extRegistCell([EXQuantPendingOrderCell.classForCoder()], ["EXQuantPendingOrderCell"])
        return tableView
    }()

    
    required init(strategyID:String,item:EXQuantStrategyListItem) {
        self.sid = strategyID
        self.listItem = item
        self.symbol = item.symbol
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getTicker()
        repeatOrder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        suspendTask()
    }
    
    func suspendTask() {
        orderListTimer?.dispose()
        EXWebSocket.marketService.cancellAlltaskObj()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.tableView.tableHeaderView = tableHeader
        self.coinMap = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(self.symbol)
        tableHeader.bindItems(info: self.listItem, coinMap: coinMap)
        prepareWS()
    }
    

    func getPendingOrders() {
        appApi.rx.request(.quantGetOrderingGridList(strategyId: sid))
            .MJObjectMap(EXOrderingGridListModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                mySelf.handleItems(model: model)
            }) { (error) in
                
        }.disposed(by: disposeBag)
    }
    
    func isEmptyPendings() -> Bool{
        if buys.count == 0,sells.count == 0 {
            return true
        }else {
            return false
        }
    }
    
    func handleItems(model:EXOrderingGridListModel) {
        buys.removeAll()
        sells.removeAll()
        for item in model.BUY {
            buys.append("\(item)")
        }
        for item in model.SELL {
            sells.append("\(item)")
        }
        self.filterPrice()
        let count =  buys.count + sells.count
        self.orderCountChange?("\(count)")
        tableView.reloadData()
    }
    
    override func userGoHomeScreen(_ to: Bool) {
        guard let top = AppService.topViewController(),top == self else {return}
        if to {
            suspendTask()
        }else {
            getTicker()
        }
    }
    
}

extension EXQuantPendingVC:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isEmptyPendings() ? 0 : 26
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isEmptyPendings() {
            return nil
        }else {
            let header = EXQuantPendingHeader.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 26))
            header.backgroundColor = UIColor.ThemeView.bg
            header.bindTitle(buyT: "contract_text_buyMarket".localized(), buyP: "quant_title_buyPrice".localized(), sellP: "quant_title_sellPrice".localized(), sellT: "contract_text_sellMarket".localized())
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 26
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(buys.count, sells.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var buy = ""
        var sell = ""
        if buys.count > indexPath.row  {
            buy = buys[indexPath.row].decimalString(value: coinMap.priceDecimal())
        }
        if sells.count > indexPath.row  {
            sell = sells[indexPath.row].decimalString(value: coinMap.priceDecimal())
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXQuantPendingOrderCell") as! EXQuantPendingOrderCell
        
        cell.bind(buy: buy, sell: sell, idx: "\(indexPath.row+1)",cprice: currentPrice)
        return cell
    }
}

extension EXQuantPendingVC {
    
    func getTicker() {
        //ticker
        let ticker_channel = "market_\(self.coinMap.symbol)_ticker"
        let ticker_cbid = "quantTicker_\(self.coinMap.symbol)"
        let recordItem = WSRecordItem.init(event: "sub", channels: ticker_channel, cbid: ticker_cbid)
        EXWebSocket.marketService.addRecordObject(recordItem: recordItem)
    }
    
    
    func prepareWS() {
        EXWebSocket.marketService.onwskLineEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
//                print(datas)
                guard let mySelf = self else { return }
                if event == .ticker ,symbol == mySelf.coinMap.symbol {
                    guard let tickerModel = EXKlineTictModel.mj_object(withKeyValues: datas) else { return }
                    mySelf.dispatchTickerData(tickerModel)
                }
            }).disposed(by: self.disposeBag)
    }
    
    func dispatchTickerData(_ data: EXKlineTictModel) {
        handleNowPrice(model: data)
    }
    
    func handleNowPrice(model:EXKlineTictModel) {
        guard let close = model.tick?.close else { return }
        var buy = ""
        var sell = ""
        currentPrice = close
        filterPrice()
        
        if buys.count > 0 || sells.count > 0 {
            if buys.count > 0  {
                buy = buys[0].decimalString(value: coinMap.priceDecimal())
            }
            if sells.count > 0 {
                sell = sells[0].decimalString(value: coinMap.priceDecimal())
            }
            tableHeader.updatePrice(closeP: close,buyOne:buy,sellOne: sell)
            tableView.reloadData()
        }
    }
    
    func filterPrice() {
        self.buys = self.buys.filter({ (price) -> Bool in
            return self.currentPrice.greaterThanOrEqualto(price)
        })
        self.sells = self.sells.filter({ (price) -> Bool in
            return price.greaterThanOrEqualto(self.currentPrice)
        })
    }
}

extension EXQuantPendingVC {
    
    func repeatOrder() {
        if self.listItem.isStatusPending() {
            orderListTimer?.dispose()
            getPendingOrders()
            orderListTimer = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] (element) in
                    guard let `self` = self else { return }
                    self.getPendingOrders()
                })
        }

    }
}
