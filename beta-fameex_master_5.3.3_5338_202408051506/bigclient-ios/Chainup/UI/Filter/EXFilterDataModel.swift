//
//  EXFilterDataModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXFoldItemType:String {
    case all = "ALL"
    case forceAll = "ForceALL"
}

class EXFilterItem:NSObject {
    @objc var valueKey:String = ""
    @objc var text:String = ""//Text for buttons, used for fold type
    @objc var isSelected:Bool = false //The selected status of the button, used for fold type, only radio selected
    @objc var inputPlaceHolder:String = ""//The content prompt of the input box is also used for the right content area with half input and half selection
    @objc var unit:String = ""//Input box units, some of which have
    
    static func getItem(titles:[String],valueKeys:[String]) -> [EXFilterItem]{
        var items:[EXFilterItem] = []
        if titles.count == valueKeys.count {
            for (idx,title) in titles.enumerated() {
                let item = EXFilterItem()
                item.text = title
                item.valueKey = valueKeys[idx]
                items.append(item)
            }
        }
        return items
    }
}

class EXFilterDataModel: NSObject {
    @objc var leftKey:String = ""//Filter item key, default to leftkey for 1 item
    @objc var rightKey:String = ""//Second key
    @objc var title:String = ""//cell title
    @objc var filterType:AppFilterStyle = .input
    @objc var keyBoardType:UIKeyboardType = .default
    @objc var items:[EXFilterItem] = []
    @objc var extraItems:[EXFilterItem] = [] //mix
    var forceFilterItem :Bool = false
    var itemListHiddenAll: Bool = false //Click on all to expand. Do you need all buttons
    static func getSwitchModel(key:String,
                        title:String) ->EXFilterDataModel {
        let model = EXFilterDataModel()
        model.leftKey = key
        model.title = title
        model.filterType = .onoff
        return model
    }
    
    static func getInputModel(key:String,
                     title:String,
                     placeHolder:String,
                     unit:String?,
                     keyBoardType:UIKeyboardType = .default) ->EXFilterDataModel {
        let model = EXFilterDataModel()
        model.leftKey = key
        model.title = title
        model.filterType = .input
        model.keyBoardType = keyBoardType
        let item = EXFilterItem()
        item.inputPlaceHolder = placeHolder.localized()
        item.valueKey = key
        item.unit = unit ?? ""
        model.items = [item]
        return model
    }
    
    static func getSelectionModel(key:String,
                        title:String,
                        placeHolder:String) ->EXFilterDataModel {
        let model = EXFilterDataModel()
        model.leftKey = key
        model.title = title
        model.filterType = .selection
        let item = EXFilterItem()
        item.inputPlaceHolder = placeHolder.localized()
        item.valueKey = key
        model.items = [item]
        return model
    }
    
    static func getMixModel(title:String,
                     leftKey:String,
                     rightKey:String,
                     leftplaceHolder:String,
                     rightItems:[EXFilterItem]) -> EXFilterDataModel {
        let model = EXFilterDataModel()
        model.title = title
        model.filterType = .mix
        model.leftKey = leftKey
        model.rightKey = rightKey
        
        let leftItem = EXFilterItem()
        leftItem.inputPlaceHolder = leftplaceHolder.localized()
        
        model.items = [leftItem]
        model.extraItems = rightItems
        return model
    }
    
    
    static func getDateModel(beginDateKey:String,
                      endDateKey:String,
                      title:String) ->EXFilterDataModel {
        let model = EXFilterDataModel()
        model.leftKey = beginDateKey
        model.rightKey = endDateKey
        
        model.title = title
        model.filterType = .date
        let item = EXFilterItem()
        item.inputPlaceHolder = "filter_date_start".localized()
        item.valueKey = beginDateKey

        let itemend = EXFilterItem()
        itemend.inputPlaceHolder = "filter_date_end".localized()
        itemend.valueKey = endDateKey
        model.items = [item]
        model.extraItems = [itemend]
        return model
    }
    
    static func getFoldModel(key:String,
                     title:String,
                     contents:[EXFilterItem],
                     selectedIdx:Int = 0) -> EXFilterDataModel {
        let model = EXFilterDataModel()
        model.leftKey = key
        model.title = title
        model.filterType = .fold
        model.items = contents
        return model
    }
    
    static func getSingleSheetModel(sheetItems:[EXFilterItem])  -> EXFilterDataModel {
        let model = EXFilterDataModel()
        model.items = sheetItems
        model.filterType = .singleSheet
        return model
    }
    
    
    
    
   static func mixFilterDataModel() ->EXFilterDataModel {
        
        var coinitems = [EXFilterItem]()
        var markets = EXAppMarketManager.sharedInstance.getMarketSorts()
        markets = markets.map { (str) -> String in
            return str.aliasName()
        }
        //Remove all
        coinitems = EXFilterItem.getItem(titles: markets, valueKeys: markets)
        //Half input, half folded
        let mixModel = EXFilterDataModel.getMixModel(title: "filter_mix_tradeCoinPair".localized(),
                                                     leftKey: "coin",
                                                     rightKey: "market",
                                                     leftplaceHolder: "filter_input_coinsymbol".localized(),
                                                     rightItems: coinitems)
        mixModel.itemListHiddenAll = true
        return mixModel
    }
}

