//
//  EXCreditCardViewModel.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/31.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
///Network Request Response Status
///
let quickTradeBanxaSuccessfulUrl = "https://banxa.com/blog"
let quickTradeBanxaFailedUrl = "https://banxa.com/blog"
let quickTradeBanxaUrlKey = "banxa.com/blog"
enum EXCreditResultStatus {
    case coinlist
    case ratelist
    case servicelist //Payment provider services
    case submit //Payment provider services
}
    
class EXCreditCardViewModel: EXViewModel {
    
    let dispatchGroup = DispatchGroup()
    let queue = DispatchQueue(label: "quickBuyCoin")
    let disposeBag = DisposeBag()
    var configBuyData: EXCreditCoinData?
    var configSellData: EXCreditCoinData?
    var rateListData: EXCoinRateListData?
    var payListData: EXPayData?
    var payResult: EXPayResult?
    var payHistoryData = PayHistoryData()
  //  var result: PublishSubject<EXCreditResultStatus> = PublishSubject()
    var coinlistResult: PublishSubject<EXCreditResultStatus> = PublishSubject()
    var ratelistResult: PublishSubject<EXCreditResultStatus> = PublishSubject()
    var servicelistResult: PublishSubject<EXCreditResultStatus> = PublishSubject()
    var submitResult: PublishSubject<EXCreditResultStatus> = PublishSubject()
    var requestEnd: PublishSubject<EXCreditResultStatus> = PublishSubject()

    var isBuy = true
    ///Fiat currency
    var payCoin = EXCreditCoin()
    ///Digital currency
    var recieveCoin = EXCreditCoin()
    var rateModel: EXCoinRate?
    var serviceName = ""
    var accountListModel: EXAccountBalanceModel?
    var canUse = "0"
    
    func setCoinData(isBuy: Bool){
        
        if isBuy{
            if let fiat_list = configBuyData?.fiat_list,fiat_list.count > 0,var coin = fiat_list.first{
                coin.isFiat = true
                payCoin = coin
            }
            if let coin_list = configBuyData?.coin_list,coin_list.count > 0,var coin = coin_list.first{
                coin.isFiat = false
                recieveCoin = coin
            }
        }else{
            if let fiat_list = configSellData?.fiat_list,fiat_list.count > 0,var coin = fiat_list.first{
                coin.isFiat = true
                recieveCoin = coin
            }
            if let coin_list = configSellData?.coin_list,coin_list.count > 0,var coin = coin_list.first{
                coin.isFiat = false
                payCoin = coin
            }
        }
        
    }
    
    
    func changeBuySellupdateCoinData(){
//        print("交换后的--检查币对是否存在")
        let coinName = isBuy ? recieveCoin.name : payCoin.name
        let coinList = isBuy ? configBuyData?.coin_list : configSellData?.coin_list
//        print("isBuy = \(isBuy) coinName = \(coinName) 列表个数 = \(coinList?.count)")
        var hasCoin = false
        if let newCoinList = coinList{
            for coinItem in newCoinList{
                if coinItem.name == coinName{
                    hasCoin = true
                    break
                }
            }
            print("isBuy = \(isBuy) coinName = \(coinName) 当前列表包含 = \(hasCoin)")
            if hasCoin == false{
                if let defaultCoin = newCoinList.first {
                    
                    if payCoin.isFiat{
                        recieveCoin = defaultCoin
                    }else{
                       payCoin = defaultCoin
                    }
                    print("USD = \(payCoin.showName) payCoin.isFiat = \(payCoin.isFiat)")
                    print("COIN = \(recieveCoin.showName) recieveCoin.isFiat = \(recieveCoin.isFiat)")
                }
            }
        }
    }
    
    func setRateData(){
        serviceName = ""
        rateModel = nil
        if let rateList = rateListData?.rate_list,rateList.count > 0,let rate = rateList.first{
            rateModel = rate
            serviceName = rate.name
        }
    }
    
    ///When entering the legal currency amount, calculate the received currency quantity based on the exchange rate
    func caculate(isFait: Bool,decmal: Int = 8){
        let result = self.rateCal(amount:self.payCoin.amount, decmal: 8)
        self.recieveCoin.amount = result
    }
    
    func getDefalutCoinCanBuyRange() -> String{
        if self.payCoin.limitMin.isEmpty || self.payCoin.limitMax.isEmpty {
            return ""
        }
        if self.rateModel?.rate.isEmpty ?? true{
            return "0"
        }
        let min = rateCal(amount: self.payCoin.limitMin, decmal: 8)
        let max = rateCal(amount: self.payCoin.limitMax, decmal: 8)
        return min + "-" + max
    }
    func rateCal(amount: String,decmal: Int = 8) -> String {
        let rate = self.rateModel?.rate ?? "0"
        if rate.isEmpty || rate == "0" || amount.isEmpty {
            return ""
        }
        let result = amount.stringByDividing(divide: rate, decimal: decmal)
        return result
    }
    
    func clearData(){
        self.payCoin.amount = ""
        self.recieveCoin.amount = ""
        self.recieveCoin.coinPlaceHolder = ""
        self.rateModel?.rate = ""
        self.canUse = ""
    }
    
    func changeBuySell(){
        print("交换前")
        print("USD = \(payCoin.showName) payCoin.isFiat = \(payCoin.isFiat) url = \(payCoin.iconUrl)  mainChainSymbol =\(payCoin.mainChainSymbol)")
        print("COIN = \(recieveCoin.showName) recieveCoin.isFiat = \(recieveCoin.isFiat) url = \(recieveCoin.iconUrl)  mainChainSymbol =\(recieveCoin.mainChainSymbol)")
        
        let pay = payCoin
        payCoin = recieveCoin
        recieveCoin = pay
        //clear
        payCoin.coinPlaceHolder = ""
        recieveCoin.coinPlaceHolder = ""
        payCoin.amount = ""
        recieveCoin.amount = ""
        self.isBuy = !self.isBuy
        print("交换后")
        print("USD = \(payCoin.showName) payCoin.isFiat = \(payCoin.isFiat) url = \(payCoin.iconUrl)  mainChainSymbol =\(payCoin.mainChainSymbol)")
        print("COIN = \(recieveCoin.showName) recieveCoin.isFiat = \(recieveCoin.isFiat) url = \(recieveCoin.iconUrl)  mainChainSymbol =\(recieveCoin.mainChainSymbol)")
        dealSellCoinListCallBack()
    }
    
    func getAavialAmount(){
        if self.isBuy {
            return
        }
        let coinName = payCoin.mainChainSymbol
        print("余额查询 =\(coinName)")
        if let itemModel = self.accountListModel?.getItemWithCoinName(coinName){
            let avial = itemModel.normal_balance.formatAmount(itemModel.coinName)
            self.canUse = avial
            print("余额查询 =\(avial)")
        }
    }
    
    
    func payPassed(input: String) -> Bool {
        
        if self.isBuy == false{
            if input.greaterThan(self.canUse){
                self.payCoin.limitTip = "quick_buy_avail_check".localized()
                return false
            }
        }
        self.payCoin.limitTip = getlimitTip()
        if let max = rateListData?.max,let min = rateListData?.min{
            if input.lessThan(min){
                return false
            }
            if input.greaterThan(max){
                return false
            }
        }
        return true
    }
    func getReceviceRange() -> String {
        if let target_max = rateListData?.target_max,let target_min = rateListData?.target_min{
            return target_min + "-" + target_max
        }
        return ""
    }
    func getPayRange() -> String {
        if let max = rateListData?.max,let min = rateListData?.min{
            return "common_text_limitMin".localized() + " " + min + "-" + max
        }
        return "common_text_limitMin".localized() + " " + "0.0001" + "-" + "1000"
    }
    
    func getlimitTip() -> String{
        if let max = rateListData?.max,let min = rateListData?.min{
            return "creditCard_text10".localized() + " " + min + "-" + max + " " + payCoin.name
        }
        return ""
    }
    
    ///requeset
    func getBuyCoinlist(){
        dispatchGroup.enter()
        appApi.rx.request(.get_third_support_fiat(transferType: "1"))
            .customObjectMap(EXCreditCoinData.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                mySelf.dispatchGroup.leave()
                mySelf.configBuyData = entity
                mySelf.setCoinData(isBuy: true)
                mySelf.coinlistResult.onNext(.coinlist)
//                mySelf.getRateList()
            }) { [weak self] (error) in
                guard let mySelf = self else{return}
                mySelf.dispatchGroup.leave()
                
        }.disposed(by: disposeBag)
        
    }
    
    func getSellCoinList(){
        self.dispatchGroup.enter()
        appApi.rx.request(.get_third_support_fiat(transferType: "2"))
            .customObjectMap(EXCreditCoinData.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                mySelf.configSellData = entity
                mySelf.dispatchGroup.leave()
            }) { [weak self] (error) in
                guard let mySelf = self else{return}
                mySelf.dispatchGroup.leave()
                
        }.disposed(by: disposeBag)
    }
    
    func dealSellCoinListCallBack(){
        self.changeBuySellupdateCoinData()
        self.coinlistResult.onNext(.coinlist)
    }
    
    func getAccountList(){
        dispatchGroup.enter()
        appApi.hideAutoLoading()
        appApi.rx.request(.accountBalance(coinSymbols: nil))
            .MJObjectMap(EXAccountBalanceModel.self)
            .subscribe { [weak self] model in
                guard let `self` = self else { return }
                self.dispatchGroup.leave()
                self.accountListModel = model
            } onFailure: { [weak self] error in
                guard let `self` = self else { return }
                self.dispatchGroup.leave()
            } onDisposed: {
                
            }

    }
    
    
    func getHomeData(){
        if XUserDefault.isOffLine(){
            return
        }
        queue.async(group: dispatchGroup, execute: DispatchWorkItem(block: { [weak self] in
            guard let `self` = self else { return }
            self.getAccountList()
            
        }))
        
        queue.async(group: dispatchGroup, execute: DispatchWorkItem(block: { [weak self] in
            guard let `self` = self else { return }
            self.getBuyCoinlist()
            
        }))
        
        queue.async(group: dispatchGroup, execute: DispatchWorkItem(block: { [weak self] in
            guard let `self` = self else { return }
            self.getSellCoinList()
        }))
        
        dispatchGroup.notify(queue: queue) { [weak self] in
            print("All requests completed")
            guard let `self` = self else { return }
            self.getRateList()
        }
    }
    
    
    func getRateList(){
        if payCoin.name.isEmpty || recieveCoin.name.isEmpty {
            self.requestEnd.onNext(.ratelist)
            return
        }
        let type = self.isBuy ? "1" : "2"
        
        let fiat = self.isBuy ? payCoin.name : recieveCoin.name
        let coin = self.isBuy ? recieveCoin.name : payCoin.name
//        print("请求汇率 == fiat =\(fiat) coin =\(coin)")
        appApi.hideAutoLoading()
        appApi.rx.request(.get_paycard_rate_list(fiat:fiat, coin:coin,transferType: type))
            .customObjectMap(EXCoinRateListData.self,false)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                mySelf.rateListData = entity
                mySelf.setRateData()
                mySelf.ratelistResult.onNext(.ratelist)
                mySelf.requestEnd.onNext(.ratelist)
            }) { [weak self] (error) in
                guard let mySelf = self else{return}
                mySelf.ratelistResult.onNext(.ratelist)
                mySelf.requestEnd.onNext(.ratelist)
                
        }.disposed(by: disposeBag)
    }
    
    //MARK: Service Provider List
    func getServiceList(success: @escaping EXComVoidBlock,errorCallBack: @escaping EXComVoidBlock){
        if payCoin.name.isEmpty || recieveCoin.name.isEmpty || serviceName.isEmpty {
            errorCallBack()
            return
        }
        
        let type = self.isBuy ? "1" : "2"
        let fait = self.isBuy ? payCoin.name : recieveCoin.name
        let coin = self.isBuy ? recieveCoin.name : payCoin.name
        appApi.hideAutoLoading()
        appApi.rx.request(.get_paycard_num(fiat: fait, coin: coin, num: payCoin.amount, name: serviceName, transferType: type))
            .customObjectMap(EXPayData.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                mySelf.payListData = entity
                success()
            }) { (error) in
                errorCallBack()
        }.disposed(by: disposeBag)
    }
    
    /**
Quote_ ID Quotation ID
Name Third party name
Coin Digital Currency
Fiat fiat
Num legal currency quantity
Base_ Amount may be the actual number of fiat coins purchased after deducting handling fees
Total_ The total amount of legal currency spent by amount
Amount obtains the number of digital currencies
     rate （x fiat  1 coin）
     
     */
    ///Submit
    func submitOrder(pay:EXPayServiceinfo, success: @escaping EXComVoidBlock,errorBlock: @escaping EXComVoidBlock){
        let transferType = self.isBuy ? "1" : "2"
        
        let fiat = self.isBuy ? payCoin.name : recieveCoin.name
        let coin = self.isBuy ? recieveCoin.name : payCoin.name
        appApi.rx.request(.pay_submit(quote_id: pay.quote_id, name: pay.name, coin: coin, num: payCoin.amount, base_amount: pay.base_amount, total_amount: pay.source_amount, amount: pay.target_amount, fiat: fiat, rate: pay.rate, transferType: transferType))
            .customObjectMap(EXPayResult.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                mySelf.payResult = entity
                success()
            }) { (error) in
                errorBlock()
        }.disposed(by: disposeBag)
    }
    ///Order Record
    func getPayHistory(page:String,size:String, table:UITableView){
        appApi.hideAutoLoading()
        appApi.rx.request(.credit_card_payList(page: page, pageSize: size))
            .customObjectMap(PayHistoryData.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                mySelf.handleHistory(page: page, pageSize: size, model: entity,table:table)
                
            }) { (error) in
                table.mj_header.endRefreshing()
                table.mj_footer.endRefreshing()
        }.disposed(by: disposeBag)
    }
   
    
    
    func handleHistory(page:String,pageSize:String,model:PayHistoryData,table:UITableView) {
        if page == "1" {
            self.payHistoryData = model
            table.mj_header.endRefreshing()
        }else {
            if (model.orderList?.count ?? 0) > 0 {
                self.payHistoryData.orderList = self.payHistoryData.orderList! + model.orderList!
            }
        }
        if (model.orderList?.count ?? 0 ) < Int(pageSize)! {
            table.mj_footer.endRefreshingWithNoMoreData()
        }else {
            table.mj_footer.endRefreshing()
        }
        table.reloadData()
    }
}

