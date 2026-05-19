//
//  EXPushNavigator.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import Swap
enum EXPushNavigation:Navigation {
    case slContractDetail(id:String)
}

struct EXPushAppNavigation:AppNavigation {
    
    func viewcontrollerForNavigation(navigation: Navigation) -> UIViewController {
        if let navigation = navigation as? EXPushNavigation {
            switch navigation {
            case .slContractDetail(let id):
                if EXAppConfigManager.sharedInstance.getContractVersion() == .new {
                    return EXSwapKLineDetailVC()
                }
            }
        }
        return UIViewController()
    }
    
    func navigate(_ navigation: Navigation, from: UIViewController, to: UIViewController) {
        from.navigationController?.pushViewController(to, animated: true)
    }
}
