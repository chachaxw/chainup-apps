//
//  OTCPulbicManager.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/16.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import SwiftEventBus

class OTCPulbicManager: NSObject {
    
    let disposebag = DisposeBag()
    var publicInfo = EXOTCPublicInfo()

    //MARK: Single Example
    public static var sharedInstance : OTCPulbicManager{
        struct Static {
            static let instance : OTCPulbicManager = OTCPulbicManager()
        }
        return Static.instance
    }
    
    func getData() {
        otcApi.hideAutoLoading()
        otcApi.rx.request(.publicInfo)
            .customObjectMap(EXOTCPublicInfo.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.updateOTCModel(model: model)
                case .failure(_):
                    break
                }
            }.disposed(by: disposebag)
    }
    
    func updateOTCModel(model:EXOTCPublicInfo) {
        SwiftEventBus.post(EXEventBusConst.onOtcPublicInfoUpdated)
        self.publicInfo = model
    }
}

extension OTCPulbicManager{
    
    func getDefaultOTCCoinEntity()->CoinListEntity {
        let dftCoin = self.publicInfo.defaultCoin
        return EXAppMarketManager.sharedInstance.getDefaultOTCCoinEntity(dftCoin)
    }
    
    func getOtcPayments() -> [OTCPaymentModel] {
        return self.publicInfo.payments
    }
    //Obtain default payment fiat currency outside the venue
    func getOtcDefaultPaycoin() -> String {
        return self.publicInfo.otcDefaultPaycoin;
    }
    
    func getOtcPaymentModel(_ key:String) -> OTCPaymentModel? {
        let payments = self.getOtcPayments()
        for pay in payments {
            if pay.key == key {
                return pay
            }
        }
        return nil
    }
    
    func getOtcCountryNumbers() -> [OTCPaymentModel] {
        return self.publicInfo.countryNumberInfo
    }
    
    func getOtcPaycoins() -> [OTCPaymentModel] {
        return self.publicInfo.paycoins
    }
    
    func getOtcFee() -> [OTCFeeOtcListItem] {
        return self.publicInfo.feeOtcList
    }
    
    func getCancelMaxNum() ->String {
        let max = self.publicInfo.otc_order_cancel_max_num
        if max.isEmpty {
            return "3"
        }
        return max
    }
    
    func isShowWithdrawLimitTip() ->Bool {
        let limit = self.publicInfo.wind_control_switch
        if limit == "1" {
            return true
        }
        return false
    }
    
    func getFilterPaymentModel() -> EXFilterDataModel {
        let payments = self.getOtcPayments()
        var titles:[String] = ["common_action_sendall".localized()]
        var valueKeys:[String] = ["ALL"]
        for payment in payments {
            titles.append(payment.title)
            valueKeys.append(payment.key)
        }
        let payitems = EXFilterItem.getItem(titles: titles, valueKeys: valueKeys)
        return EXFilterDataModel.getFoldModel(key: "payments", title: "filter_fold_payMethod".localized(), contents: payitems)
    }
    
    func isPayCoinDisplayAtListView() -> Bool{
        let paycoins =  self.getOtcPaycoins()
        var showCount = 0
        for coin in paycoins {
//            if coin.hide == "1" || coin.hide == "0" {
//                return true
//            }
            //Change to at least one not hidden, which is the style
            if coin.hide == "0" {
                showCount += 1
            }
        }
        
        if showCount > 0,showCount < paycoins.count {
            return true
        }
        return false
    }
    
    func getCountryItems()->[EXFilterItem] {
        let countries = self.getOtcCountryNumbers()
        var titles:[String] = ["common_action_sendall".localized()]
        var valueKeys:[String] = ["ALL"]
        for country in countries {
            titles.append(country.title)
            valueKeys.append(country.numberCode)
        }
        let countryitems = EXFilterItem.getItem(titles: titles, valueKeys: valueKeys)
        return countryitems
    }
    
    
    func getFilterCountryModel() -> EXFilterDataModel {
        let countryitems = self.getCountryItems()
        return EXFilterDataModel.getFoldModel(key: "numberCode", title: "filter_fold_country".localized(), contents: countryitems)
    }
    
    func otcPayCoinItems() ->[EXFilterItem] {
        let payCoins = self.getOtcPaycoins()
        var titles:[String] = []
        var valueKeys:[String] = []
        for coin in payCoins {
            titles.append(coin.title)
            valueKeys.append(coin.key)
        }
        let coinitems = EXFilterItem.getItem(titles: titles, valueKeys: valueKeys)
        return coinitems
    }
    
    func getFilterPayCoinModel() -> EXFilterDataModel {
        let title = "filter_fold_currencyType".localized()
        return EXFilterDataModel.getFoldModel(key: "payCoin", title: title, contents: self.otcPayCoinItems())
    }
    
    func getPayCurrencyUnit(_ code: String) -> String {
        return getFilterPayCoinModel().items.filter { $0.valueKey == code }.first?.text ?? code
    }
    

}

