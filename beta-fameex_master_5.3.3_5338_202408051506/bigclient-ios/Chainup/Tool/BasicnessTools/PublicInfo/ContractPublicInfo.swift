//
//  ContractPublicInfo.swift
//  Chainup
//
//  Created by zewu wang on 2023/1/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//  http://wiki.365os.com/pages/viewpage.action?pageId=5779827

import UIKit
import EXKit

@objcMembers class ContractContentModel: NSObject {
    var symbol = ""
    var pricePrecision = ""
    var settleTime = ""//delivery time 
    var contractType = ""
    var minOrderVolume = ""
    var openPrice = ""
    var sort = ""
    var maxOrderVolume = ""
    var baseSymbol = ""
    var maxLeverageLevel = ""
    var leverTypes = ""
    {
        didSet{
            let arr = leverTypes.components(separatedBy: ",")
            leverTypes_arr = arr
        }
    }
    var contractName = ""
    var id = ""
    var minMargin = ""
    var quoteSymbol = ""
    
    var leverTypes_arr : [String] = []
    
    var currentPrice = "--"//Current price
    {
        didSet{
            if currentPrice != "--"{
                currentPrice = NSString.init(string: currentPrice).decimalString1(Int(pricePrecision) ?? 4)
            }
        }
    }
    
    var rose_Color = UIColor.ThemeLabel.colorLite
    
    func getPriceDecimal()->Int {
        let tmpPrecision = Int(pricePrecision)
        if let precision = tmpPrecision {
            return precision
        }
        return 8
    }
    
    func getContractTitle() -> String{
        var contractType1 = "contract_text_perpetual".localized()
        switch contractType {
        case "0":
            contractType1 = "contract_text_perpetual".localized()
        case "1":
            contractType1 = "contract_text_currentWeek".localized() + " \(getSettleTime())"
        case "2":
            contractType1 = "contract_text_nextWeek".localized() + " \(getSettleTime())"
        case "3":
            contractType1 = "noun_date_month".localized() + " \(getSettleTime())"
        case "4":
            contractType1 = "noun_date_quarter".localized() + " \(getSettleTime())"
        default:
            break
        }
        return contractType1
    }
    
    //Obtain contract name
    func getContractName() -> String{
        return baseSymbol + quoteSymbol + " " + getContractTitle()
    }
    
    //Obtain delivery time
    func getSettleTime() -> String{
        let mouth = DateTools.getMouth(settleTime)
        let day = DateTools.getDay(settleTime)
        return mouth + day
    }
}

class ChildSceneItem: EXBaseModel {
    var item = ""
    var langTxt = ""
}

class SceneItem : EXBaseModel {
    var item = ""
    var langTxt = ""
    var childItem:[ChildSceneItem] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.childItem = ChildSceneItem.mj_objectArray(withKeyValuesArray: self.childItem).copy() as! [ChildSceneItem]
    }
}

class item :NSObject {
    var name:String=""
    var id:String=""
}

class lanItem :NSObject {
    @objc var defLan:String = ""
    @objc var lanList:Array<item> = []
}

class ContractPublicInfo: NSObject {
    @objc var marketSymbol:String=""
    
    @objc var coinList:Dictionary<String, Any>=[:]{
        didSet{
            var array : [ContractCoinListModel] = []
            for key in coinList.keys{
                if let item = coinList[key] as? [String : Any]{
                    let entity = ContractCoinListModel()
                    entity.key = key
                    entity.setEntityWithDict(item)
                    array.append(entity)
                }
            }
            self.coinListModel = array
        }
    }
    var coinListModel : [ContractCoinListModel] = []
    
    @objc var lan :lanItem?
    
    var switchModel = ContactSwitchModel()
    @objc var switch1 : [String : Any] = [:]
    {
        didSet{
            switchModel.setEntityWithDict(switch1)
        }
    }
    
    @objc override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["switch1":"switch"]
    }
    
    var marketItems : [ContractContentModel] = []
    var marketModels : [String : [ContractContentModel]] = [:]
    var resultMarketModels : [(String , [ContractContentModel])] = []
    @objc var sceneList : [SceneItem] = []
    @objc var market:Dictionary<String, Any>? {
        didSet {
            if let marketModel = market {
                for key in marketModel.keys{
                    var emptyItems : [ContractContentModel] = []
                    if let arr = marketModel[key] as? [[String : Any]]{
                        for dict in arr{
                            emptyItems.append(ContractContentModel.mj_object(withKeyValues: dict))
                        }
                    }
                    emptyItems.sort { (model1, model2) -> Bool in
                        return model1.contractType < model2.contractType
                    }
                    marketModels[key] = emptyItems
                }
                
                resultMarketModels = marketModels.sorted { (dict1, dict2) -> Bool in
                    return dict1.key < dict2.key
                }
                
//                for values in marketModel.values {
//                    emptyItems.append(ContractContentModel.mj_object(withKeyValues: values))
//                }
//                self.marketItems = emptyItems
            }
        }
    }
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.sceneList = SceneItem.mj_objectArray(withKeyValuesArray: self.sceneList).copy() as! [SceneItem]
    }
}

class ContractCoinListModel : SuperEntity{
    
    var showPrecision = ""
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        showPrecision = dictContains("showPrecision")
    }
}

//Contract switch
class ContactSwitchModel : SuperEntity{
    
    var is_more_position = ""
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        is_more_position = dictContains("is_more_position")
    }
}

