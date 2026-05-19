//
//  EXTransferVm.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/15.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EXTransferContractAccountModel :NSObject {
    var contractWalletType = "201101" //Ordinary account
    var contractAccountType = "2161001" //Contract account
}

class EXTransferCommonModel :NSObject {
    var key = "" //Account key, from type/type
    var balance = ""//balance
    var symbol = ""
}

class EXTransferVm: NSObject {
    
    let disposeBag = DisposeBag()
    let model = EXTransferContractAccountModel()
    typealias TransferSuccessCallback = (EXAccountType) -> ()
    var onTransferSuccessCallback:TransferSuccessCallback?
    //SymbolMap is only used for leverage
    func doTransfer(from:EXAccountType,to:EXAccountType,amount:String,symbol:String,symbolMap : String? = nil) {
        //If there is a contract transfer, use the contract API
        if from == .contract || to == .contract {
            
            var type = ""
            //            var fromType = ""
            //            var toType = ""
            //            if from == .contract {
            //                fromType = model.contractAccountType
            //                toType = model.contractWalletType
            //            }else {
            //                fromType = model.contractWalletType
            //                toType = model.contractAccountType
            //            }
            if from == .contract {
                type = "contract_to_wallet"
            } else if to == .contract {
                type = "wallet_to_contract"
            }
            /// //Privatization 0 Privatization
            var manager = appApi.rx.request(.coinToFuturesTransfer(amount: amount, coinSymbol: symbol,type: type))
            if from == .contract {
                let futuresType = EXAppConfigManager.sharedInstance.configVm.cfgModel.futuresType
                if futuresType.count > 0 && futuresType != "0"{
                    //Contract Cloud
                    manager = newContractApi.rx.request(.transfer(coinSymbol: symbol, amount: amount,type:type))
                }
            }
            manager.MJObjectMap(EXVoidModel.self).subscribe{[weak self] event in
                switch event {
                case .success(_):
                    self?.onTransferSuccessCallback?(to)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
            
            ///Universal version
            //            contractApi.rx.request(.capitalTransfer(fromType: fromType, toType: toType, amount: amount, bound: "BTC"))
            //            .MJObjectMap(EXVoidModel.self)
            //            .subscribe{[weak self] event in
            //                switch event {
            //                case .success(_):
            //                    self?.onTransferSuccessCallback?(to)
            //                    break
            //                case .failure(_):
            //                    break
            //                }
            //            }.disposed(by: self.disposeBag)
            
        }else if from == .leverage || to == .leverage {
            var fromType = ""
            var toType = ""
            if from == .leverage {
                fromType = EXTransferAccountKey.accountKeyOTC.rawValue
                toType = EXTransferAccountKey.accountKeyExchange.rawValue
            }else {
                fromType = EXTransferAccountKey.accountKeyExchange.rawValue
                toType = EXTransferAccountKey.accountKeyOTC.rawValue
            }
            
            appApi.rx.request(.leverFinanceTransfer(fromAccount: fromType, toAccount: toType, amount: amount, coinSymbol: symbol, symbol: ((symbolMap ?? "") as NSString).replacingOccurrences(of: "/", with: "").uppercased()))
                .MJObjectMap(EXVoidModel.self)
                .subscribe{[weak self] event in
                    switch event {
                    case .success(_):
                        self?.onTransferSuccessCallback?(to)
                        break
                    case .failure(_):
                        break
                    }
                }.disposed(by: self.disposeBag)
            
        }else {
            var fromType = ""
            var toType = ""
            if from == .coin {
                fromType = EXTransferAccountKey.accountKeyExchange.rawValue
                toType = EXTransferAccountKey.accountKeyOTC.rawValue
            }else {
                fromType = EXTransferAccountKey.accountKeyOTC.rawValue
                toType = EXTransferAccountKey.accountKeyExchange.rawValue
            }
            
            appApi.rx.request(.financeOtcTransfer(fromAccount: fromType,
                                                  toAccount: toType,
                                                  amount: amount,
                                                  coinSymbol: symbol))
                .MJObjectMap(EXVoidModel.self)
                .subscribe{[weak self] event in
                    switch event {
                    case .success(_):
                        self?.onTransferSuccessCallback?(to)
                        break
                    case .failure(_):
                        break
                    }
                }.disposed(by: self.disposeBag)
        }
    }
    
    func getToAccountName()->String {
        if EXAppConfigManager.sharedInstance.didOpenFiat() {
            if EXAppConfigManager.sharedInstance.didOpenB2C(){
                return "assets_text_otc_forotc".localized()
            }else{
                return "assets_text_otc".localized()
            }
        }else if EXAppConfigManager.sharedInstance.didOpenContract() {
            return "assets_text_contract".localized()
        }else if EXAppConfigManager.sharedInstance.didOpenLever() {
            return "leverage_asset".localized()
        }
        return ""
    }
    
    func getToAccountType()-> EXAccountType{
        if EXAppConfigManager.sharedInstance.didOpenFiat() {
            return .otc
        }else if EXAppConfigManager.sharedInstance.didOpenContract() {
            return .contract
        }else if EXAppConfigManager.sharedInstance.didOpenLever() {
            return .leverage
        }
        return .coin
    }
    
    
    func hasMultiAccounts() -> Bool {
        return   EXAppConfigManager.sharedInstance.hasMultiAccounts()
    }

}

