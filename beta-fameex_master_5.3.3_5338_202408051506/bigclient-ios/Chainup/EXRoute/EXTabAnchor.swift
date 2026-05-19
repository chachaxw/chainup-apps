//
//  EXTabAnchor.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

enum EXTabAnchorType {
    case exMarket
    case slContract
    case exOtc
    case exAsset
    case exHome
    case exTransaction
}

//This only handles

class EXTabAnchor{
    
    var currentViewController:UIViewController?
    
    static let `manager` = EXTabAnchor()
    open class var shared: EXTabAnchor {
        return manager
    }
    
    func tabAnchorTo(_ type:EXTabAnchorType, animated:Bool = false, parameters:[String:String] = [:]) {
        guard let rootTabBar = BusinessTools.getRootTabbar() else {return}
        guard let topVc = AppService.topViewController() else { return}
        
        var tabIdx:Int = 0
        switch type {
        case .exMarket:
            tabIdx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .market) ?? 0
            break
        case .slContract:
            tabIdx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .contract) ?? 0
            break
        case .exOtc:
            tabIdx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .fiat) ?? 0
            break
        case .exAsset:
            let asset = EXAssetsVc.init()
            tabIdx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .assets) ?? 0
            break
        case .exHome:
            tabIdx = 0
            break
        case .exTransaction:
            tabIdx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .transaction) ?? 0
            break
        }
        
        //Processing assets on the secondary page, tabIdx, not found
        if type == .exAsset,tabIdx == 0 {
            let asset = EXAssetsVc.init()
            topVc.navigationController?.pushViewController(asset, animated: true)
        }else {
            rootTabBar.selectIndex(tabIdx)
            topVc.navigationController?.popToRootViewController(animated: animated)
        }
        self.currentViewController = rootTabBar.getCurrentTabbarVC()
        guard let vc = self.currentViewController else {return}
        if let protocal = vc as? EXTabActionProtocal,parameters.count > 0{
            protocal.handleParameter(parameters)
        }
        
    }
}

