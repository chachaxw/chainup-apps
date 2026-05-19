//
//  EXAppCache.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/7.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import YYCache
import EXKit
enum EXAppGuideShowType {
    case home
    case market
    case search
    case asset
}

class EXAppCache: NSObject {
    var yyCache:YYCache?
    
    static let sharedCache: EXAppCache = {
        let instance = EXAppCache()
        instance.yyCache = YYCache.init(name: "ExChainUpAppCache")
        return instance
    }()

    //***Public_ Info_ V5 cache******
    func getPbV5Cache()-> EXAppConfigModel? {
        guard let ycache = self.yyCache else { return nil}
        if ycache.containsObject(forKey: EXAppCache.appPbV5Cache) {
            if let json = ycache.object(forKey: EXAppCache.appPbV5Cache) as? String {
                if let v5Model = EXAppConfigModel.mj_object(withKeyValues: json) {
                    return v5Model
                }
            }
        }
        return nil
    }
    
    func updatePbV5Model(model:EXAppConfigModel) {
        guard let ycache = self.yyCache else {return}
        if let jsonString =  model.mj_JSONString() {
            ycache.setObject(jsonString as NSCoding, forKey: EXAppCache.appPbV5Cache)
        }
    }
    
    //***Public_ Info_ Market cache******
    func getPbMarketCache()-> EXAppMarketModel? {
        guard let ycache = self.yyCache else { return nil}
        if ycache.containsObject(forKey: EXAppCache.appPbmarketCache) {
            if let json = ycache.object(forKey: EXAppCache.appPbmarketCache) as? String {
                if let marketModel = EXAppMarketModel.mj_object(withKeyValues: json) {
                    return marketModel
                }
            }
        }
        return nil
    }
    
    func updatePbMarketCache(model:EXAppMarketModel) {
        guard let ycache = self.yyCache else {return}
        if let jsonString =  model.mj_JSONString() {
            ycache.setObject(jsonString as NSCoding, forKey: EXAppCache.appPbmarketCache)
        }
    }
    

    func getHotCoins()-> [String]? {
        guard let ycache = self.yyCache else { return nil}
        if ycache.containsObject(forKey: EXAppCache.appHotCoinCache) {
            if let json = ycache.object(forKey: EXAppCache.appHotCoinCache) as? String {
                return json.components(separatedBy: ",")
            }
        }
        return nil
    }
    
    func updateHotCoins(coin:String) {
        guard let ycache = self.yyCache else {return}
        if coin.count > 0 {
            ycache.setObject(coin as NSCoding, forKey: EXAppCache.appHotCoinCache)
        }
    }
    
//    //***OTC/public_ Info cache******
//    func getOTCPbCache()-> EXOTCPublicInfo? {
//        guard let ycache = self.yyCache else { return nil}
//        if ycache.containsObject(forKey: EXAppCache.appPbV5Cache) {
//            if let json = ycache.object(forKey: EXAppCache.appPbV5Cache) as? String {
//                if let v5Model = EXAppConfigModel.mj_object(withKeyValues: json) {
//                    return v5Model
//                }
//            }
//        }
//        return nil
//    }
//
//    func updatePbV5Model(model:EXAppConfigModel) {
//        guard let ycache = self.yyCache else {return}
//        if let jsonString =  model.mj_JSONString() {
//            ycache.setObject(jsonString as NSCoding, forKey: EXAppCache.appPbV5Cache)
//        }
//    }
    
    
    //***Contract version******
    func getContractType()-> EXAppContractType? {
        guard let ycache = self.yyCache else { return nil}
        if ycache.containsObject(forKey: EXAppCache.appContractVersion) {
            if let type = ycache.object(forKey: EXAppCache.appContractVersion) as? String {
                return type == "1" ? .new : .old
            }
        }
        return nil
    }
    
    func updateContractType(type:EXAppContractType) {
        guard let ycache = self.yyCache else {return}
        if type == .new  {
            ycache.setObject("1" as NSCoding, forKey: EXAppCache.appContractVersion)
        }else {
            ycache.setObject("0" as NSCoding, forKey: EXAppCache.appContractVersion)
        }
    }
    
    
    func removeAllCache( isRemoved: @escaping((Bool) -> Void)) {
        guard let ycache = self.yyCache else {return}
        ycache.removeAllObjects(progressBlock: { (a, b) in }) { (hasError) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                if hasError {
                    isRemoved(false)
                }else {
                    isRemoved(true)
                }
            }
        }
    }
}

extension EXAppCache {
    
    func setAppAdShowTime() {
        guard let ycache = self.yyCache else { return }
        ycache.setObject("\(DateTools.getNowTimeInterval())" as NSCoding, forKey: EXAppCache.appAdGuideShowTime)
    }
    
    func getAppAdShowTime() -> Double? {
        guard let ycache = self.yyCache else { return nil}
        if ycache.containsObject(forKey: EXAppCache.appAdGuideShowTime) {
            if let timeInterval = ycache.object(forKey: EXAppCache.appAdGuideShowTime) as? String {
                if let time = Double(timeInterval) {
                    return time
                }
            }
        }
        return nil
    }
    
    func setAppGuideDidShow(byType:EXAppGuideShowType) {
        guard let ycache = self.yyCache else { return }
        
        switch byType {
        case .home:
            ycache.setObject("1" as NSCoding, forKey: EXAppCache.appGuideHomeShow)
        case .market:
            ycache.setObject("1" as NSCoding, forKey: EXAppCache.appGuideMarketShow)
        case .search:
            ycache.setObject("1" as NSCoding, forKey: EXAppCache.appGuideSearchShow)
        case .asset:
            ycache.setObject("1" as NSCoding, forKey: EXAppCache.appGuideAssetShow)
        }
    }
    
    func getAppGuideFirstShow(byType:EXAppGuideShowType)->Bool {
        guard let ycache = self.yyCache else { return false}
        var firstShow:Bool = true
        switch byType {
        case .home:
            if ycache.containsObject(forKey: EXAppCache.appGuideHomeShow) {
                firstShow = false
            }
        case .market:
            if ycache.containsObject(forKey: EXAppCache.appGuideMarketShow) {
                firstShow = false
            }
        case .search:
            if ycache.containsObject(forKey: EXAppCache.appGuideSearchShow) {
                firstShow = false
            }
        case .asset:
            if ycache.containsObject(forKey: EXAppCache.appGuideAssetShow) {
                firstShow = false
            }
        }
        return firstShow
    }
    
    
    func getHomeAdCache()-> EXHomeAdModel? {
        guard let ycache = self.yyCache else { return nil}
        if ycache.containsObject(forKey: EXAppCache.appAdHomeModelCache) {
            if let json = ycache.object(forKey: EXAppCache.appAdHomeModelCache) as? String {
                if let v5Model = EXHomeAdModel.mj_object(withKeyValues: json) {
                    return v5Model
                }
            }
        }
        return nil
    }
    
    func updateHomeAdCache(model:EXHomeAdModel) {
        guard let ycache = self.yyCache else {return}
        if let jsonString =  model.mj_JSONString() {
            ycache.setObject(jsonString as NSCoding, forKey: EXAppCache.appAdHomeModelCache)
        }
    }
}

extension EXAppCache {
    
    func setAppHomeVersion(ver:String) {
        guard let ycache = self.yyCache else { return }
        ycache.setObject(ver as NSCoding, forKey: "AppHomeUI")
    }
    
    func getAppHomeVersion() -> String {
        guard let ycache = self.yyCache else { return "1"}
        if ycache.containsObject(forKey:"AppHomeUI") {
            if let ver = ycache.object(forKey: "AppHomeUI") as? String {
                return ver
            }
        }
        return "1"
    }
}

extension EXAppCache {
    static let appPbV5Cache = "appPbV5Cache"//Pbv5 cache
    static let appPbmarketCache = "appPbmarketCache"//PbMarket cache
    static let appOtcPbCache = "appOtcPbCache"//Otcpublic cache
    static let appContractVersion = "appContractVersion"//Contract version
    static let appHotCoinCache = "appHotCoinCache"//Otcpublic cache
    
    static let appGuideHomeShow = "appGuideHomeShow"
    static let appGuideMarketShow = "appGuideMarketShow"
    static let appGuideSearchShow = "appGuideSearchShow"
    static let appGuideAssetShow = "appGuideAssetShow"
    static let appAdGuideShowTime = "appAdGuideShowTime"
    static let appAdHomeModelCache = "appAdHomeModelCache"

}

