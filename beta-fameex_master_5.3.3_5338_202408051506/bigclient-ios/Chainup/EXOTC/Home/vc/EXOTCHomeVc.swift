//
//  EXOTCHomeVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftEventBus
import RxSwift
import EXKit

class EXOTCHomeVc: UIViewController,StoryBoardLoadable,EXEmptyDataSetable {
    
    @IBOutlet var titleView: UIView!
    @IBOutlet var homeTableView: UITableView!
    @IBOutlet var otcSymbolTitle: EXDirectionButton!
    @IBOutlet var considerLabel: UILabel!
    
    var coinEntity :CoinListEntity?
    var searchModel:EXOTCSearch = EXOTCSearch()
    var otcVm:EXOTCVm = EXOTCVm()
    var page :Int = 1
    var searchParams = [String:String]()
    var considerPrice:String?
    var balanceEmpty:Bool?//Check if your balance is 0 when selling
    var hasPaymentType:Bool = false //Check if your balance is 0 when selling
    var myPaymentTypeModel:CommonAryModel = CommonAryModel()
    var payCoin:String = ""
    var otcBalanceModel:EXOTCAccountListModel = EXOTCAccountListModel()
    var otcHeader:EXFiatHeaderView = EXFiatHeaderView()
    
    var tradeType:OTCTradeType = .otcbuy {
        didSet {
            
        }
    }
    
    var symbol:String = "" {
        didSet {
            otcHeader.fiatBtn.titleLabel.text = symbol.aliasName()
//            otcHeader.fiatBtn.text(content: symbol.aliasName())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tradeType == .otcsell {
            updateBalance()
        }
    }
    
    func updateBalance() {
        if XUserDefault.isOffLine() {
            return
        }
        appApi.hideAutoLoading()
        appApi.rx.request(.financeAccountList)
        .MJObjectMap(EXOTCAccountListModel.self,false)
        .subscribe{[weak self] event in
            switch event {
            case .success(let model):
                self?.checkBalance(model: model)
                break
            case .failure(_):
                break
            }
        }.disposed(by: self.disposeBag)
        self.refreshPayments()
    }
    
    func refreshPayments() {
        otcApi.hideAutoLoading()
        otcApi.rx.request(.paymentFind(isOpen: "1"))
        .MJObjectMap(CommonAryModel.self,false)
        .subscribe{[weak self] event in
            switch event {
            case .success(let model):
                self?.handelUserPayments(model)
                break
            case .failure(_):
                break
            }
        }.disposed(by: self.disposeBag)
    }
           
    
    func handelUserPayments(_ model:CommonAryModel){
        self.myPaymentTypeModel = model
        hasPaymentType = model.dictAry.count > 0
    }
    
    func checkBalance(model:EXOTCAccountListModel) {
        self.otcBalanceModel = model
        self.otcVm.otcCoinMap = model.getCoinMap(coinSymbol: self.symbol)
        self.balanceEmpty = model.isBalanceEmpty(coinSymbol: self.symbol)
    }

    func getPublicInfoPayCoin() {
        let coins = OTCPulbicManager.sharedInstance.getOtcPaycoins()
        if coins.count > 0 {
            let item = coins[0]
            self.payCoin = item.key
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rp = "otc_text_rp".localized()
        considerLabel.text = rp + ":--"
        otcSymbolTitle.titleLabel.font = UIFont.ThemeFont.BodyRegular
        otcSymbolTitle.titleLabel.textColor = UIColor.ThemeLabel.colorLite
        self.homeTableView.register(UINib.init(nibName: "EXOTCHomeCell", bundle: nil), forCellReuseIdentifier: "EXOTCHomeCell")
        var tempSymbol = ""
        if let entity = coinEntity {
            tempSymbol = entity.name
        }else {
            let defaultCoin = OTCPulbicManager.sharedInstance.getDefaultOTCCoinEntity()
            tempSymbol = defaultCoin.name
        }

        self.symbol = tempSymbol
        self.exEmptyDataSet(self.homeTableView, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:(self.otcHeader.isShowPayCoin() ? 200 : 0),
            ]
        })
        otcHeader.fiatBtn.addTarget(self, action: #selector(onClickSymbolAction(_:)), for:.touchUpInside)
        
        self.handleRefresh()
        self.homeTableView.mj_header.beginRefreshing()
        //If it is not retrieved, listen to eventbus and refresh again if there is a return value
        if self.payCoin.isEmpty {
            self.getPublicInfoPayCoin()
            if OTCPulbicManager.sharedInstance.isPayCoinDisplayAtListView() {
                let payCoins = OTCPulbicManager.sharedInstance.getOtcPaycoins()
                for coin in payCoins {
                    if coin.hide == "0" {
                        self.payCoin = coin.key
                        break
                    }
                }
            }else {
                self.getPublicInfoPayCoin()
            }
        }
        
        
    
        
        otcHeader.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: otcHeader.configHeaderHeight())
        
        otcHeader.configHeaderInfos()
        otcHeader.onUpdateFiatCallback = {[weak self] key in
            self?.updateFiat(key)
        }
        self.homeTableView.tableHeaderView = otcHeader
        otcHeader.cellDidExpandBlock = {[weak self] expand in
            self?.expandHeader(expand)
        }
        
        let addPayMentSuccess = NSNotification.Name(rawValue: "AddPayMentSuccessNotification")
        _ = NotificationCenter.default.rx
            .notification(addPayMentSuccess)
            .take(until: self.rx.deallocated)
            .subscribe(onNext:{ [weak self] notification in
                self?.refreshPayments()
            })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        EXAppVersionHandler.getVersionForPublicInfo()
       
    }
    
    func updateFiat(_ key:String) {
//        - key : "payCoin"
//        - value : "USD"
        
//        self.homeTableView.mj_header.beginRefreshing()
        self.handlefilter(["payCoin":key])
    }
    
    func expandHeader(_ expand:Bool ) {
        
        if let headerView = self.homeTableView.tableHeaderView {
            headerView.frame =  CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: otcHeader.configHeaderHeight(expand))
            self.homeTableView.tableHeaderView = headerView
        }
    }
    
    func handleRefresh(){
        self.homeTableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else {return}
            mySelf.page = 1
            mySelf.otcSearch(atPage: mySelf.page)
        })
        self.homeTableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else {return}
            mySelf.page += 1
            mySelf.otcSearch(atPage: mySelf.page)
        })
        
    }
    
    func handlefilter(_ params:[String:String]) {
        self.page = 1
        self.searchParams = params
        self.otcSearch(atPage: self.page)
    }
    
    func otcSearch(atPage:Int){
        
        if symbol.isEmpty {
            self.resetRefresh()
            let defaultCoin = OTCPulbicManager.sharedInstance.getDefaultOTCCoinEntity()
            self.symbol = defaultCoin.name
            return
        }
        
        let side = self.tradeType == .otcbuy ? OTCTradeSideKey.otcBuy.rawValue : OTCTradeSideKey.otcSell.rawValue
        let payCoin = self.searchParams["payCoin"]
        let price = self.searchParams["price"]
        let payments = self.searchParams["payments"]
        let numberCode = self.searchParams["numberCode"]
        let blockTrade = self.searchParams["isBlockTrade"]
        
        if let pay = payCoin {
            if self.payCoin != pay {
                self.payCoin = pay
            }
        }
        
        let paramPaycoin = payCoin ?? self.payCoin
        if paramPaycoin.isEmpty {
            self.resetRefresh()
            self.getPublicInfoPayCoin()
            return
        }
        
        otcApi.hideAutoLoading()
        otcApi.rx.request(.otcSearch(side: side,
                                     symbol: symbol,
                                     page: atPage,
                                     payCoin: paramPaycoin,
                                     price: price,
                                     payments: payments,
                                     numberCode: numberCode,
                                     isBlockTrade:blockTrade))

            .customObjectMap(EXOTCSearch.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    print(model)
                    self?.handleSearchList(model: model)
                    break
                case .failure(let error):
                    print(error)
                    self?.resetRefresh()
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    func resetRefresh() {
        self.homeTableView.mj_footer.endRefreshing()
        self.homeTableView.mj_header.endRefreshing()
    }
    
    func handleSearchList(model:EXOTCSearch) {
        if model.advertList.count < 20 {
            self.homeTableView.mj_footer.endRefreshingWithNoMoreData()
        }else {
            self.homeTableView.mj_footer.endRefreshing()
        }
        self.homeTableView.mj_header.endRefreshing()

        if self.page == 1 {
            self.searchModel = model
        }else {
            self.searchModel.advertList = searchModel.advertList + model.advertList
        }
   
        homeTableView.reloadData()
    }
    
    @IBAction func onClickTipAction(_ sender: Any) {
        let normal = EXNormalAlert()
        normal.configSigleAlert(title: nil, message: "alert_content_otcRPdesc".localized())
        EXAlert.showAlert(alertView: normal)
    }
    
    @IBAction func onClickSymbolAction(_ sender: Any) {
        let allcoins = EXAppMarketManager.sharedInstance.getAllOTCCoinList()
        var supportOtc:[String] = []
        var selectIdx = 0
        for (idx,item) in allcoins.enumerated() {
            if symbol == item.name {
                selectIdx = idx
            }
            supportOtc.append(item.name.aliasName())
        }
        let sheet = EXOldActionSheetView()
        sheet.configButtonTitles(buttons: supportOtc,selectedIdx: selectIdx)
        sheet.actionIdxCallback = {[weak self] tag in
            guard let self else { return }
            self.changeSymbol(tag: tag)
            self.otcHeader.fiatBtn.setOn(false, animated: true)
//            self?.otcHeader.fiatBtn.checked(check: false)
//            self?.otcSymbolTitle.checked(check: false)
        }
        sheet.actionCancelCallback = {[weak self]  in
            guard let self else { return }
            self.otcHeader.fiatBtn.setOn(false, animated: true)
//            self?.otcHeader.fiatBtn.checked(check: false)
//            self?.otcSymbolTitle.checked(check: false)
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    
    func changeSymbol(tag:Int) {
        let allcoins = EXAppMarketManager.sharedInstance.getAllOTCCoinList()
        let item = allcoins[tag]
        self.coinEntity = item
        self.symbol = item.name
        self.page = 1
        self.homeTableView.mj_header.beginRefreshing()
        self.balanceEmpty = self.otcBalanceModel.isBalanceEmpty(coinSymbol: self.symbol)
    }
    
    func onActionConfirm(item:OTCSearchListItem) {
        let kycPass =  EXAuthenticManagerTool.kycRightPassed(right: .c2c)
        if kycPass == false{
            return
        }
        self.otcVm.otcOrderPreCheck(advertId:item.advertId ,type: self.tradeType, vc: self,emptyBalance: balanceEmpty,hasPayment: hasPaymentType,sellerPayment:item.payments,myPaymentModel: myPaymentTypeModel )
    }
    
    func onMerchantDetailAction(item:OTCSearchListItem) {
        let exmerchant = EXOTCMerchantDetailVc.instanceFromStoryboard(name: StoryBoardNameOTC)
        exmerchant.userID = item.userId
        self.navigationController?.pushViewController(exmerchant, animated: true)
    }
}

extension EXOTCHomeVc : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
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
    
}

extension EXOTCHomeVc : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchModel.advertList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = searchModel.advertList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXOTCHomeCell",for:indexPath)  as! EXOTCHomeCell
        cell.tradeType = self.tradeType
        cell.bindCellData(item: item,symbol: symbol)
        cell.onConfirmCallback = {[weak self] in
            self?.onActionConfirm(item: item)
        }
        cell.avatarCallback = {[weak self] in
            self?.onMerchantDetailAction(item: item)
        }
        
        return cell
    }
}

extension EXOTCHomeVc : EXRefreshProtocal {
    func refreshProtocalTrigger() {
        self.homeTableView.mj_header.beginRefreshing()
    }
}

extension EXOTCHomeVc : EXTradeCmdProtocal {
    
    func excuteCmd(symbol: String, action: String) {
        if let entity = EXAppMarketManager.sharedInstance.getCoinEntity(symbol) {
            self.coinEntity = entity
            self.symbol = entity.name
            self.page = 1
            self.homeTableView.mj_header.beginRefreshing()
        }
    }
}


