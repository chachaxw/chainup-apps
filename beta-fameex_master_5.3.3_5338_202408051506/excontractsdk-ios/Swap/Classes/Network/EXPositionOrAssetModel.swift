//
//  EXSPositionOrAssetModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/23.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import HandyJSON
import EXKit
import YYModel
public class EXSPositionOrAssetModel: EXCOBaseModel {
    
    public var positionList = [EXSwapPositionModel]()
    public var accountList = [EXContractAssetModel]()
    public var assetUiUrl = ""
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["positionList":EXSwapPositionModel.self,
                "accountList":EXContractAssetModel.self]
    }
}


class EXSwapPriceModel: EXCOBaseModel{
    var tagPrice: String = ""
    var lastPrice: String = ""
    var buyOne: String = ""
    var sellOne: String = ""
}
class EXPricelistModel{
    var icon: String = ""
    var priceModel: EXSwapPriceModel?
    class func itemWithDic(dic: Any) -> EXPricelistModel?{
        guard let result = dic as? [String:Any] else{
            return nil
        }
        if result.keys.count != 1 {
            return nil
        }
        let key = result.keys.first!
        guard let value = result[key] as? [String:Any] else{
            return nil
        }
        
        if let object = EXSwapPriceModel.yy_model(with: value) {
            //            //print("value = \(value)")
            //            var content = "server key=\(key) value = \(value) \n"
            let item = EXPricelistModel()
            item.icon = key
            item.priceModel = object
            //            let objcInfo = ("objcInfo key=\(key) = tagPrice =\(object.tagPrice) = lastPrice =\(object.lastPrice) =buyOne\(object.buyOne) = sellOne = \(object.sellOne)") + "\n"
            //            content = content + objcInfo
            //            EXSwapLogManger.shareInstance.writeLog(content: content)
            //            //print("key=\(key) = tagPrice =\(object.tagPrice) = lastPrice =\(object.lastPrice) =buyOne\(object.buyOne) = sellOne = \(object.sellOne)")
            return item
        }
        return nil
    }
}

