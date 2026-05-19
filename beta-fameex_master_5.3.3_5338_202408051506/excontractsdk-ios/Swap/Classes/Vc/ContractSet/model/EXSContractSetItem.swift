//
//  EXSContractSetItem.swift
//  Chainup
//
//  Created by cwd on 2022/11/13.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit


enum ContractSetType{
    case positonMode //持仓模式 English: Position holding mode
    case unit // 展示单位 English: Display unit
    case confirmAgain //二次确认 English: Secondary confirmation
    case chart  //图表位置 English: Chart Position
    case time  //有效期 English: Validity period
}

//MARK: fix 文案 English: MARK: Fix copy
enum ContactChartLocation{
    case top
    case bottom
    case none
    var display: String{
        switch self {
        case .top:
            return "cp_set_1".ex_localized()
        case .bottom:
            return "cp_set_2".ex_localized()
        case .none:
            return "cp_set_3".ex_localized()
        }
    }
  
}

class EXSContractSetItem{
    var type = ContractSetType.positonMode
    var title: String = ""
    var titleDes: String = "" //标题底部描述 English: Title bottom description
    var contentValue: String = ""
    var open: Bool = false
    
    static func getSetDatalist() -> [EXSContractSetItem]{
        var arr = [EXSContractSetItem]()
        let positonMode = EXSContractSetItem()
        positonMode.type = .positonMode
        positonMode.title = "cp_contract_setting_text14".ex_localized()
        var positonModeValue = "cp_contract_setting_text16".ex_localized()
        let idx = EXStoreData.storeObject(forKey: EXS_HOLD_MODE) as? Int ?? 0
        if idx == 0 {
            positonModeValue = "cp_contract_setting_text15".ex_localized()
        }
        positonMode.contentValue = positonModeValue
        arr.append(positonMode)
        
        let unit = EXSContractSetItem()
        unit.type = .unit
        unit.title = "cp_contract_setting_text17".ex_localized()
        var unitValue = "cp_extra_text82".ex_localized()
        let idx2 = EXStoreData.storeObject(forKey: EXS_UNIT_VOL) as? Int ?? 0
        if idx2 == 0 {
            unitValue = "cp_overview_text9".ex_localized()
        }
        unit.contentValue = unitValue
        arr.append(unit)
        
        let confiragin = EXSContractSetItem()
        confiragin.type = .confirmAgain
        confiragin.title = "cp_contract_setting_text19".ex_localized()
        confiragin.open = EXStoreData.getOnComfirmSwapAlert()
        arr.append(confiragin)
        
        let chart = EXSContractSetItem()
        chart.type = .chart
        chart.title = "cp_trading_area_chart_title".ex_localized()
        var chartLocationType: ContactChartLocation = .top
        let open = EXStoreData.storeBool(forKey: contract_chart_open)
        if !open{ //关闭 English: close
            chartLocationType = .none
        }else{//打开的分上下 English: Open Up and Down
            let top = EXStoreData.storeBool(forKey: contract_chart_top)
            if top{
                chartLocationType = .top
            }else{
                chartLocationType = .bottom
            }
        }
        chart.contentValue = chartLocationType.display
        arr.append(chart)
        
        let time = EXSContractSetItem()
        time.type = .time
        time.title =  "cp_contract_setting_text21".ex_localized()
        time.titleDes = "cp_tip_text26".ex_localized()
        let idx3 = EXStoreData.storeObject(forKey: EX_DATE_CYCLE) as? Int ?? 0
        time.contentValue = EXSwapPlanOrderValidityPeriod.init(rawValue: idx3)?.introduced ?? ""
        arr.append(time)
        return arr
    }
}

