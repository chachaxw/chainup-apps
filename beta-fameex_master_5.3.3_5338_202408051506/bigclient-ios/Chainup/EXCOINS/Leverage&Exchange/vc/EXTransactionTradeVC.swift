//
//  EXTransactionTradeVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/26.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
enum TradeHeaderLayout {
    case vertical
    case horizontal
}

class EXTransactionTradeVC: EXTradeBaseVc {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(transactionTable)
        transactionTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        transactionTable.tableHeaderView = tradeHeaderV
        tradeHeaderV.refreshEntity(entity: entity)
        addTradeSkeleton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handler.requesting = false
        EXTracking.shared.trackPage(name: .transaction, isEnter: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EXTracking.shared.trackPage(name: .transaction, isEnter: false)
        EXWebSocket.marketService.cancellAlltaskObj()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func heartBeats() {
        removeTradeSkeleton()
        getTradeLimitInfo()
        getCurrentEntrust()
        getNetWorth()
    }
    
    func getCurrentEntrust(){
        //If not logged in, do not request
        if XUserDefault.getToken() == nil{
            if rowDatas.count > 0{
                rowDatas.removeAll()
                transactionTable.reloadData()
            }
            if currentOrderIds.count > 0 {
                self.clearPankouOrders()
            }
            self.transactionTable.mj_header.endRefreshing()
            return
        }
//        print("new tradeVc, orderlistnew,  (self. entity. symbol)")
        appApi.hideAutoLoading()
        appApi.rx.request(.getNewEntrustList(symbol: self.entity.symbol,
                                             pageSize: "20",
                                             page: "1",
                                             side: nil,
                                             type: nil
        ))
            .MJObjectMap(EXCurrentEntrustArr.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                if mySelf.entity.symbol == entity.symbol {
                    mySelf.handleOrderList(entity: entity)
                }
                
                mySelf.transactionTable.mj_header.endRefreshing()
            }).disposed(by: disposeBag)
    }
    
    override func entityDidRefreshed() {
        heartBeats() 
    }
    
    //Enter the current delegation
    override func gotoCurrentEntrust(){
        if XUserDefault.getToken() == nil{
            BusinessTools.modalLoginVC()
            return
        }
        let vc = EXCoinEntrustVC()
        vc.entity = self.entity
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func createOrderAction(element:OrderCreateElement) {
        if self.didPassEtfAgreements() {
            self.orderConfirm(element: element)
        }else {
            //MARK: Fix temporarily removed
//            appApi.rx.request(.checkEtfTrade)
//                .MJObjectMap(EXAgreementEtfModel.self,false)
//                .subscribe(onSuccess: {[weak self] (model) in
//                    self?.handleAgreementEtf(status:model.status,orderInfo: element)
//                }) { [weak self] (error) in
//
//                }.disposed(by: disposeBag)
        }
    }
    
    func handleAgreementEtf(status:String,orderInfo:OrderCreateElement) {
        if status == ETFAgreementState.notAgree.rawValue {
            let etfDiscalaimerView = EXETFDisclaimerView()
            etfDiscalaimerView.alertCallback = {[weak self] agree in
                guard let mySelf = self else{return}
                if agree {
                    mySelf.startQuestions()
                }
            }
            etfDiscalaimerView.show()
        }else if status == ETFAgreementState.needKYC.rawValue {
            let user = UserInfoEntity.sharedInstance()
            if user.authLevel == UserAuthLevel.pending.rawValue {
                EXAlert.showWarning(msg: "etf_agreement_pendingKYC".localized())
            }else {
                let realName = EXIDAuthenticViewController()
                self.navigationController?.pushViewController(realName, animated: true)
            }
        }else if status == ETFAgreementState.pendingKyc.rawValue {
            EXAlert.showWarning(msg: "etf_agreement_pendingKYC".localized())
        }else if status == ETFAgreementState.notAllowedCountry.rawValue {
            EXAlert.showFail(msg: "etf_agreement_countryNotSurpport".localized())
        }else if status == ETFAgreementState.success.rawValue {
            self.orderConfirm(element: orderInfo)
        }
    }
    
    func startQuestions() {
        let vc = EXAnswersVc.init()
        vc.onAnwserback = {[weak self] in
            self?.confirmEtfAgreements()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func confirmEtfAgreements() {
        appApi.rx.request(.readStatusEtfWarn)
            .MJObjectMap(EXVoidModel.self,false)
            .subscribe(onSuccess: {[weak self] _ in
                self?.reloadUserInfo()
            }, onFailure: { _ in
                
            }).disposed(by: disposeBag)
    }
    
    func reloadUserInfo() {
        UserInfoEntity.sharedInstance().getUserInfo ({
        }) {
            
        }
    }
    
    func orderConfirm(element:OrderCreateElement) {
        handler.createOrder(side: element.side,
                            type: element.type,
                            volume: element.volume,
                            price: element.price,
                            entity: self.entity)
        handler.onCreateSuccessCallback = {[weak self] entity in
            self?.refreshOrders(entity: entity)
            self?.clearInputFields()
        }
        handler.onErrorCallback = {[weak self] in
            self?.clearInputFields()
        }
    }

    @objc override func cancelOrderAction(entity:EXCurrentEntrustEntity) {
        handler.cancelOrder(entity: entity)
        handler.onCancelSuccessCallback = {[weak self] entity in
            self?.refreshDeleteOrders(entity: entity)
            self?.clearInputFields()
        }
        handler.onErrorCallback = {[weak self] in
            self?.clearInputFields()
        }
    }
    
    func bindETFsTicker(symbol:String,ticker:EXKlineTictModel) {
        tradeHeaderV.etfJumpBar.bindJumpBarTicker(symbol: symbol, ticker: ticker)
        tradeHeaderH.etfJumpBar.bindJumpBarTicker(symbol: symbol, ticker: ticker)
    }
}

//MARK: Net ETF value
extension EXTransactionTradeVC {
    
    func getNetWorth(){
        if entity.etfOpen != "1"{
            self.transactionTable.mj_header.endRefreshing()
            return
        }
        appApi.hideAutoLoading()
        appApi.rx.request(.etfNetValue(base: entity.coinName, quote: entity.marketName))
            .MJObjectMap(EXETFNetValueModel.self,false)
            .subscribe(onSuccess: {[weak self] (model) in
                self?.setNetWorth(model.price)
                self?.transactionTable.mj_header.endRefreshing()
            }) { [weak self] (error) in
                self?.transactionTable.mj_header.endRefreshing()
            }.disposed(by: disposeBag)
    }
    
    //Set net value
    func setNetWorth(_  str : String){
        tradeHeaderV.depthArea.updateNetWorth(value: str)
        tradeHeaderH.depthArea.updateNetWorth(value: str)
    }
}

//MARK:Button Actions
extension EXTransactionTradeVC {
    
    func refreshDeleteOrders(entity:EXCurrentEntrustEntity) {
        var delIdx:Int?
        for (idx,item) in rowDatas.enumerated() {
            if item.id == entity.id {
                delIdx = idx
            }
        }
        guard let rmIdx = delIdx else { return }
        getCurrentEntrust()
        rowDatas.remove(at:rmIdx)
        self.transactionTable.reloadData()
    }
    
    func refreshOrders(entity:EXCurrentEntrustEntity) {
        getCurrentEntrust()
        if entity.id.isEmpty {
            return
        }
        if rowDatas.count > 0 {
            rowDatas.insert(entity, at: 0)
        }else {
            rowDatas.append(entity)
        }
        self.transactionTable.reloadData()
    }
}

//MARK: Popup class
extension EXTransactionTradeVC {
    
    //Whether to pass the disclaimer statement
    func didPassEtfAgreements() -> Bool {
        if self.tradeType == .exchange,self.entity.etfOpen == "1" {
            if UserInfoEntity.sharedInstance().didOpenETF() {
                return true
            }
            return false
        }
        return true
    }
    
    //MARK: Obtain transaction restriction copy
    fileprivate func getTradeLimitInfo() {
        //Request Currency to Transaction Restriction Interface
        if EXAppConfigManager.sharedInstance.isSupportTradeLimit() {
            ///Request Interface
            appApi.rx.request(.tradeLimitInfo(symbol: self.entity.symbol))
                .MJObjectMap(EXTradeLimitInfoModel.self, false)
                .subscribe{[weak self] event in
                    switch event {
                    case .success(let model):
                        self?.showAlert(model: model)
                        break
                    case .failure(_):
                        break
                    }
                    self?.transactionTable.mj_header.endRefreshing()
                }.disposed(by: self.disposeBag)
        }
    }
    
    //MARK: Popup prompt
    fileprivate func showAlert(model : EXTradeLimitInfoModel) {
        var alertStr = ""
        let firstStr = "tradeLimit_text_everyDayCount".localized() + ","
        let buyMaxStr = String(format: "tradeLimit_text_everyDayBuy".localized(), (model.trade_symbol_buy_limit as NSString).decimalString1(Int(self.entity.volume) ?? 2)) + self.entity.coinName.aliasName()
        let sellMaxStr = String(format: "tradeLimit_text_everyDaySell".localized(), (model.trade_symbol_sell_limit as NSString).decimalString1(Int(self.entity.volume) ?? 2)) + self.entity.coinName.aliasName()
        let noLimitBuy = "tradeLimit_text_noLimitBuy".localized()
        let noLimitSell = "tradeLimit_text_noLimitSell".localized()
        
        if model.trade_limit_sell_info == "1" && model.trade_limit_buy_info == "1"{
            alertStr += firstStr
            alertStr += buyMaxStr + ","
            alertStr += sellMaxStr
        }else if model.trade_limit_sell_info == "1" && model.trade_limit_buy_info == "0" {
            alertStr += firstStr
            alertStr += sellMaxStr + ","
            alertStr += noLimitBuy
        }else if model.trade_limit_sell_info == "0" && model.trade_limit_buy_info == "1" {
            alertStr += firstStr
            alertStr += buyMaxStr + ","
            alertStr += noLimitSell
        }
        
        if alertStr.count > 0 {
            //Tooltip
            let alert = EXNormalAlert()
            alert.configSigleAlert(title: "tradeLimit_text_instructions".localized(), message: alertStr, sigleBtnTitle: "alert_common_iknow".localized())
            //show
            EXAlert.showAlert(alertView: alert)
        }
    }
    
    //Click on the coin details buying and selling button
    func clickTrading(_ str : String , entity : CoinMapEntity){
        if str == "buy"{
            tradeHeaderV.orderArea.orderBuyBtn.sendActions(for: .touchUpInside)
        }else{
            tradeHeaderV.orderArea.orderSellBtn.sendActions(for: .touchUpInside)
        }
    }
}

