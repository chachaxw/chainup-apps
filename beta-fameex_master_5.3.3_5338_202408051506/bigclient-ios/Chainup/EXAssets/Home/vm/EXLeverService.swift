//
//  EXLeverService.swift
//  Chainup
//
//  Created by liuxuan on 2022/10/10.
//  Copyright © 2022 Chainup. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import EXKit

class EXLeverService: NSObject {
    let disposeBag = DisposeBag()
    
    var allisolated:EXLeverageAccountListModel?
    var allcross:EXLeverCrossListModel?
    
    static let service: EXLeverService = {
        let instance = EXLeverService()
        return instance
    }()
    
    //单币种全仓币种余额
//    func fetchSingleCrossBalance(coinSymbol:String) ->Observable<EXLeverCrossCoinModel>{
//        appApi.hideAutoLoading()
//        return appApi.rx.request(.leverFinanceSymbolInfo(symbol: coinSymbol,isCross:true))
//            .MJObjectMap(EXLeverCrossCoinModel.self)
//            .asObservable()
//    }
    
    //单币种逐仓余额
//    func fetchIsolatedBalances(symbol:String) -> Observable<EXLeverIsolatedCoinModel>{
//        appApi.hideAutoLoading()
//        return appApi.rx.request(.leverFinanceSymbolInfo(symbol: symbol,isCross:false))
//            .MJObjectMap(EXLeverIsolatedCoinModel.self)
//            .asObservable()
//    }
    
    //单币种全仓币对余额
//    func fetchCrossBalances(coinName:String,marketName:String) -> Observable<(EXLeverCrossCoinModel,EXLeverCrossCoinModel)>
//    {
//        Observable.zip(fetchSingleCrossBalance(coinSymbol: coinName),
//                       fetchSingleCrossBalance(coinSymbol: marketName)) {
//            fiat, crypto in
//            return (fiat, crypto)
//        }
//                       .observeOn(MainScheduler.instance)
//                       .asObservable()
//    }
}

extension EXLeverService {
    
    //获取全量逐仓列表
//    func fetchAllIsolatedBalances() ->Observable<EXLeverageAccountListModel>{
//        if let accountList = self.allisolated {
//            return Observable.just(accountList)
//        }else {
//            appApi.hideAutoLoading()
//            return appApi.rx.request(.leverageBalance())
//                .MJObjectMap(EXLeverageAccountListModel.self)
//                .asObservable()
//        }
//    }
    
    //获取全量全仓列表
//    func fetchAllCrossBalances() ->Observable<EXLeverCrossListModel>{
//        if let accountList = self.allcross {
//            return Observable.just(accountList)
//        }else {
//            appApi.hideAutoLoading()
//            return appApi.rx.request(.leverageCrossBalance())
//                .MJObjectMap(EXLeverCrossListModel.self)
//                .asObservable()
//        }
//    }
}

extension EXLeverService {
//    func commonLeverTransfer(name:String,postionType:EXLeverPositionType,vc:UIViewController,isPopRoot:Bool = false) {
//        //全仓name是传入币种BTC,逐仓是传入币对name BTC/USDT
//        //在交易界面过来,全仓也是币对name BTC/USDT
//        
//        let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
//        transfer.transferFlow = .leverageToExchagne
//        
//        if postionType == .isolated {
//            transfer.coinMapName = name
//            transfer.canTransferType = .leverage
//        }else {
//            if name.contains("/") {
//                transfer.coinMapName = name
//                let coinTitleArr = name.components(separatedBy: "/")
//                if coinTitleArr.count > 0 {
//                    transfer.coinName = coinTitleArr[0]
//                }
//            }else {
//                transfer.coinName = name
//            }
//            transfer.canTransferType = .crossleverage
//        }
//        if isPopRoot {
//            transfer.isPopRoot = true
//        }
//        vc.navigationController?.pushViewController(transfer, animated: true)
//    }
    
    //name
//    func commonEntrustVc(name:String,postionType:EXLeverPositionType?,entrustType:EXEntrustType = .current,vc:UIViewController) {
//        if XUserDefault.getToken() == nil{
//            BusinessTools.modalLoginVC()
//            return
//        }
//        if let pstype = postionType {
//            let entrustvc = EXCoinEntrustVC.init(type: .leverage)
//            entrustvc.positionType = pstype
//            entrustvc.symbol = name
//            entrustvc.entrustType = entrustType
//            vc.navigationController?.pushViewController(entrustvc, animated: true)
//        }
//       
//    }
}

extension EXLeverService {
    
    func didOpenLever() -> Bool {
        //逐仓杠杆开关
        //全仓开关
        //逐仓币对
        //全仓币对
        let isOpenLever = EXAppConfigManager.sharedInstance.didOpenLever()
        if isOpenLever {
            //2个都开了
            if EXAppConfigManager.sharedInstance.didOpenIsolatedLever(),
               EXAppConfigManager.sharedInstance.didOpenCrossLever() {
                return EXAppMarketManager.sharedInstance.getAllLeverArray().count > 0
            }else if EXAppConfigManager.sharedInstance.didOpenIsolatedLever() {
                return EXAppMarketManager.sharedInstance.getIsolatedLevers().count > 0
            }else {
                return EXAppMarketManager.sharedInstance.getCrossLevers().count > 0
            }
        }else {
            return false
        }
    }
    
    func isSupportAllLevers() ->Bool {
        let isOpenLever = EXAppConfigManager.sharedInstance.didOpenLever()
        if isOpenLever {
            //2个都开了
            if EXAppConfigManager.sharedInstance.didOpenIsolatedLever(),
               EXAppConfigManager.sharedInstance.didOpenCrossLever() {
                return EXAppMarketManager.sharedInstance.getAllLeverArray().count > 0
            }else {
                return false
            }
        }else {
            return false
        }
    }
    
    func didReadLeverAlert() ->Bool {
        let flag = UserDefaults.standard.bool(forKey: "EXLeverageAlertView")
        if !flag && EXAppConfigManager.sharedInstance.getLeverProtocolURL().count > 0{
            return false
        }else {
            return true
        }
    }
}

