//
//  EXContractUserVm.swift
//  Chainup
//
//  Created by cwd on 2022/7/20.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift
public enum EXContractFavoritesActionType {
    case singleAdd //添加1个收藏 English: Add 1 collection
    case singleDelete //删除一个收藏 English: Delete a collection
    case other //其他，批量添加、删除，调整顺序。 English: Other, batch add, delete, and adjust the order.
}
public class EXContractUserVm: NSObject {
    ///服务获取，更新本地 English: /Service acquisition, updating local
    ///增删改查，同步服务器，更新本地 English: /Add, delete, modify, check, synchronize servers, update local
    ///统一从本地去取 English: /Unified collection from local sources
    public  func getFavoriteList(callback:SwapFavirateHandler?){
        
//        //测试 English: test
//        let ids = EXStoreData.getCollectionCoinMap()
//        let swapList = EXSwapPublicInfo.shared.getFavirate(ids: ids)
//        callback?(swapList)
//        return

        //Not logged in to obtain local
        if EXSwapPlatformSDK.shared.activeAccount == nil || SLUserConfig.checkHasOpenContract == false {
           let ids = EXStoreData.getCollectionCoinMap()
           let swapList = EXSwapPublicInfo.shared.getFavirate(ids: ids)
           callback?(swapList)
           return
        }
        //登录后，服务端数据覆盖本地 English: After logging in, the server data will overwrite the local data
        networkApi.rx.request(.contract_optional_list).exs_MJObjectMap(EXSCommonStringModel.self).subscribe { (model) in
            print(model.msg)
            let arr = model.msg.components(separatedBy: ",")
            EXStoreData.renewFavorites(arr)
            let swapList = EXSwapPublicInfo.shared.getFavirate(ids: arr)
            callback?(swapList)
        } onError: { (error) in
            callback?(nil)
        }.disposed(by: disposBag)
    }
  
    
    let disposBag = DisposeBag()
    typealias completeCallBacK = ()->()
    var didComplete:completeCallBacK?
    public  typealias Handler = (Bool) -> Void
    public typealias SwapFavirateHandler = ([EXSwapItemModel]?) -> Void
    //从本地收藏 English: Collect locally
    public func getLocalFavoriteList() -> [EXSwapItemModel]?{
        let ids = EXStoreData.getCollectionCoinMap()
        let swapList = EXSwapPublicInfo.shared.getFavirate(ids: ids)
        return swapList
    }
    
    public func updateLocalFavorite(itemIds:[String]){
        //测试 English: test
        EXStoreData.renewFavorites(itemIds)
    }
    //本地存储，登录后才会同步服务端 English: Local storage, server synchronization only occurs after login
    public func handleCoFavorite(actionType:EXContractFavoritesActionType,swapIds:[String],callback:Handler?) {
        if actionType == .other {
            let resultAry = swapIds
            var results = ""
            if resultAry.count > 0 {
                results = resultAry.joined(separator: ",")
            }
            EXStoreData.renewFavorites(resultAry)
            if EXSwapPlatformSDK.shared.activeAccount == nil || SLUserConfig.checkHasOpenContract == false {
                callback?(true)
                return
            }
            networkApi.rx.request(.contract_optional_set(contractOptionalList: results)).exs_MJObjectMap(EXSVoidModel.self).subscribe { (model) in
                callback?(true)
            } onError: { (error) in
                callback?(false)
            }.disposed(by: disposBag)
        }else {
            if swapIds.count == 0 {return}
            let swapId = swapIds.first!
            if actionType == .singleAdd {
                EXStoreData.collectionCoinMap(swapId)
            }else if actionType == .singleDelete {
                EXStoreData.cancelCollectionCoinMap(swapId)
            }
            if EXSwapPlatformSDK.shared.activeAccount == nil || SLUserConfig.checkHasOpenContract == false {
                self.tip(actionType: actionType)
                callback?(true)
                return
            }
            let arr = EXStoreData.getCollectionCoinMap()
            let result = arr.joined(separator: ",")
            networkApi.rx.request(.contract_optional_set(contractOptionalList:result)).exs_MJObjectMap(EXSVoidModel.self).subscribe {[weak self] (model) in
                self?.tip(actionType: actionType)
                callback?(true)
            } onError: { (error) in
                callback?(false)
            }.disposed(by: disposBag)
        }
    }
    //MARK: 
    func tip(actionType:EXContractFavoritesActionType){
        if actionType == .singleDelete {
            EXAlert.showSuccess(msg: "kline_tip_removeCollectionSuccess".ex_localized())
        }else {
            EXAlert.showSuccess(msg: "kline_tip_addCollectionSuccess".ex_localized())
        }
    }
    
    //是否收藏 English: Whether to bookmark
    func isCollect(item:EXSwapItemModel) ->Bool {
        var isCollect: Bool = false
        let swapId = String(item.instrument_id)
        isCollect =  EXStoreData.whetherCollectionCoinMap(swapId)
        return isCollect
    }
}

