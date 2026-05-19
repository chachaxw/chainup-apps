//
//  EXSwapDrawerView.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

public let exsCollectionVH : CGFloat = 40//顶部滑动的高度 English: The height of top sliding

public class EXSwapDrawerViewData{
    
    var name:String = ""
    public  var searData: [EXSwapItemModel] = []
    //MARK: fix originData 貌似没用 English: MARK: Fix originData seems to be useless
    public  var originData: [EXSwapItemModel] = []
    
    public init(name:String,searData: [EXSwapItemModel],originData: [EXSwapItemModel]) {
        
        self.name = name
        self.originData = originData
        self.searData = searData
        
        self.originData.sort { (first, second) -> Bool in
            if let firstInfo = first.ex_contractInfo,
               let secondInfo = second.ex_contractInfo {
                return firstInfo.sort < secondInfo.sort
            }
            return first.instrument_id < second.instrument_id
        }
        self.searData.sort { (first, second) -> Bool in
            if let firstInfo = first.ex_contractInfo,
               let secondInfo = second.ex_contractInfo {
                return firstInfo.sort < secondInfo.sort
            }
            return first.instrument_id < second.instrument_id
        }
        
    }
    
    func isShow() -> Bool {
        
        return self.originData.count > 0
    }
    
    //获取合约所有的分类的标题 是否包含自选列表 English: Obtain whether the titles of all categories in the contract include a self selected list
    public class func getSwapDataSoureTitlelist(containerUserLike: Bool = false,containAll: Bool = false) -> [String] {
        var list = [String]()
        let dataSource = self.getSwapDataSoure(containerUserLike: containerUserLike,containAll: containAll)
        for source in dataSource {
            if source.isShow(){
                list.append(source.name)
            }
        }
        return list
    }
    //获取合约所有的分类及其分类下的币种  是否包含自选列表 English: Obtain all categories of the contract and whether the currencies under each category include a selectable list
    public class func getSwapDataSoure(containerUserLike: Bool = false,containAll: Bool = false) -> [EXSwapDrawerViewData] {
        var dataSouce = [EXSwapDrawerViewData]()
        //盈亏记录需要全部 English: Profit and loss records need to be complete
        let allData = EXSwapDrawerViewData(name:BTContract_Block_Type.CONTRACT_BLOCK_ALL .introduce, searData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_ALL) ?? [], originData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_ALL) ?? [])
        
        let list =  [EXSwapItemModel]()
        let userlike = EXSwapDrawerViewData(name: "cp_contract_customZone".ex_localized(), searData: list, originData: list)
        let usdtData = EXSwapDrawerViewData(name: "cp_contract_data_text13".ex_localized(), searData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_USDT) ?? [], originData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_USDT) ?? [])
        let coinData = EXSwapDrawerViewData(name: "cp_contract_data_text10".ex_localized(), searData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_STAND) ?? [], originData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_STAND) ?? [])
        let  mixtureData = EXSwapDrawerViewData(name: "cp_contract_data_text12".ex_localized(), searData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_INVERSE) ?? [], originData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_INVERSE) ?? [])
        let simulation = EXSwapDrawerViewData(name: "cp_contract_data_text11".ex_localized(), searData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_SIMULATION) ?? [], originData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_SIMULATION) ?? [])
        if containAll {
            dataSouce.append(allData)
        }
        if containerUserLike{
            dataSouce.append(userlike)
        }
        if usdtData.isShow() {
            dataSouce.append(usdtData)
        }
        if coinData.isShow() {
            dataSouce.append(coinData)
        }
        if mixtureData.isShow() {
            dataSouce.append(mixtureData)
        }
        if simulation.isShow() {
            dataSouce.append(simulation)
        }
        return dataSouce
    }
}

