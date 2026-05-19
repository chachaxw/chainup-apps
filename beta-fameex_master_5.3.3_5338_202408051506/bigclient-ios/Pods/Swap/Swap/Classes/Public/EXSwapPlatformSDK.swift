//
//  EXCoPlatformSDK.swift
//  CoNetworkTest
//
//  Created by ZYJ on 2023/1/14.
//

import UIKit
import EXKit
import EXFlutterKLineKit
public typealias EXSwapSDKCallBack = ()->()
public typealias EXSwapSDKTransferOnClickedCallBack = (String,UIViewController)->()
//url /title / vc / type
public typealias EXSwapSDKGotoH5CallBack = (String,String?,UIViewController?,SwapH5Type?)->()
public enum SwapH5Type{
    case coProfitRecord
}
public class EXSwapPlatformSDK {
    static let `manager` = EXSwapPlatformSDK()
    open class var shared: EXSwapPlatformSDK {
        return manager
    }
    public var flutteEngine : EXFlutterEngine?
    public var lauchSuccess = false
    public var appName:String?
    public var app_img:String?
    public var app_img_night:String?
    public var activeAccount : EXSwapAccount?
    public var inviteUrl:String? //邀请二维码链接 English: Invitation QR code link
    public var loginCallBack:EXSwapSDKCallBack?
    public var getFiatCoinSymbolBack:EXSwapSDKCallBack? //获取汇率 English: Obtain exchange rate
    public var transferOnClickedCallBack:EXSwapSDKTransferOnClickedCallBack?
    public var rechargeCallBack:EXSwapSDKTransferOnClickedCallBack? //充币 English: Recharge coins
    public var realNameAuthenticationCallBack:EXSwapSDKCallBack?
    public var upDateEXKitConfigCallBack:EXSwapSDKCallBack?
    public var changeHostLineCall:EXSwapSDKCallBack? //Switch main host
    public var changeWsHostLineCall:EXSwapSDKCallBack? //Switch ws
    public var goToH5:EXSwapSDKGotoH5CallBack? //h5
    public func resetToDefaultConfig(){
        //下单二次弹窗 English: Order Second Pop Up
        EXStoreData.setComfirmSwapAlertStatus(true)
        //小k线设置为默认 English: Set the small candlestick as the default
        EXStoreData.setStoreObjectAndKey(false, key: contract_chart_hasSeted)
        EXStoreData.setStoreObjectAndKey(true, key: contract_chart_open)
        EXStoreData.setStoreObjectAndKey(true, key: contract_chart_top)
        //买卖点 English: Buying and selling points
        EXStoreData.setStoreObjectAndKey(false, key: swapKlineHistoryShow)
        //止盈止损 English: Stop profit and stop loss
        EXStoreData.setStoreObjectAndKey(false, key: contract_stopLossAndProfit_firstTiped)
        EXStoreData.setStoreObjectAndKey(1, key: contract_filter_selectId)
        //合约开通 English: Contract activation
        EXStoreData.setStoreObjectAndKey(false, key: HAS_OPNE_CONTRACT)
        //清空选择的记录id English: Clear selected record IDs
        EXStoreData.setStoreObjectAndKey(String(-1), key: EXNewFuturesContractID)
        
    }
    
    public func resetUSerConfig(){
        //Contract activation
        EXStoreData.setStoreObjectAndKey(false, key: HAS_OPNE_CONTRACT)
    }
    
    public static func updateContractLan(){
        EXUIDatasource.shared.alertOnlyBtnTitle = "cp_extra_text28".ex_localized()
        EXUIDatasource.shared.cancelTitle = "cp_overview_text56".ex_localized()
        EXUIDatasource.shared.confirmTitle = "cp_calculator_text16".ex_localized()
//        EXUIDatasource.shared.common_tip_nodata = "cp_loadmore_nodata".ex_localized()
        EXUIDatasource.shared.refresh_refreshing = "cp_loadmore_loading".ex_localized()
    }
    
    func getKlineImage() -> String?{
        if EXTheme.current == .dark {
            return self.app_img_night
        }else{
            return self.app_img
        }
        return nil
    }
    
}

