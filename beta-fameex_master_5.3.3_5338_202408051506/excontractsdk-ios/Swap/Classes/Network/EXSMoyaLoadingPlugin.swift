//
//  MoyaLoadingPlugin.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/21.
//  Copyright © 2023 zewu wang. All rights reserved.
//
import UIKit
import Moya
import EXKit

class EXSLoadingStatusModel: NSObject {
    @objc var identifer :String = ""
    @objc var loading :Bool = false
}

public final class EXSMoyaLoadingPlugin: PluginType {
    
    private var loadings :Array<EXSLoadingStatusModel> = []
    var needLoading:Bool = true
    
    func noloading() {
        needLoading = false
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        
        if let api = target as? EXContractApiEndPoint {
            switch api {
            case .publicMarketInfo,
                 .getUserPositionOrAsset,
                 .getUserConfig,
                 .price_list,
                 .currentOrderList,
                 .getUserPositionOrAsset_new,
                 .receiveCoupon,
                 .publicInfo,
                 .depthChart,
                 .getUserHistoryPosition,
                 .transferList,
                 .riskBalanceList,
                 .editUserConfig,
                 .getTransactionRecordList,
                 .symbol_rate_list,
                 .contract_optional_list,
                 .contract_optional_set,
                 .fundingRateList,
                 .getNoticeInfoLogined,
                 .getNoticeInfoNotLogined,
                 .closeNoticeBar:
                return
            case .speedCloseOrder,//闪电平仓 English: Lightning liquidation
                 .creatOrder,//平仓 English: Closing position
                 .changePositionMargin://调整保证金 English: Adjust margin
                UIView.makeLoading()  //这三个是弹框需要用window处理，用view 的话会弹框消失不了 English: These three are pop ups that need to be processed using window. If you use view, the pop ups will not disappear
                return
            default:
                break
            }
        }
        EXToast.makeLoading()
        
    }

    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        if let api = target as? EXContractApiEndPoint {
            switch api {
            case .publicMarketInfo,
                 .getUserPositionOrAsset,
                 .getUserConfig,
                 .price_list,
                 .currentOrderList,
                 .getUserPositionOrAsset_new,
                 .receiveCoupon,
                 .publicInfo,
                 .depthChart,
                 .getUserHistoryPosition,
                 .transferList,
                 .riskBalanceList,
                 .editUserConfig,
                 .getTransactionRecordList,
                 .symbol_rate_list,
                 .contract_optional_list,
                 .contract_optional_set,
                 .fundingRateList,
                 .getNoticeInfoLogined,
                 .getNoticeInfoNotLogined,
                 .closeNoticeBar:
                return
            case .speedCloseOrder,//闪电平仓 English: Lightning liquidation
                 .creatOrder,//平仓 English: Closing position
                 .changePositionMargin://调整保证金 English: Adjust margin
                UIView.hideProgressHUD()  //这三个是弹框需要用window处理，用view 的话会弹框消失不了 English: These three are pop ups that need to be processed using window. If you use view, the pop ups will not disappear
                return
            default:
                break
            }
        }
        EXToast.hideProgressHUD()
    }
}

