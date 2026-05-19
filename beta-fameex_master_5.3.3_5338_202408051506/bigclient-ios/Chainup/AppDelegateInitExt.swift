//
//  AppDelegateInitExt.swift
//  AppProject
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import CYLTabBarController
import Swap
extension AppDelegate{
    
    fileprivate func initTabbarV() -> UITabBarController {
        //A contract+OTC
        //B OTC
        //C contract
        //D default
        var viewContrllers:[UIViewController] = []
  
        for type in EXAppConfigManager.sharedInstance.appModules {
            if type == .home {
                viewContrllers.append(EXHomepageVc())
            }else if type == .market {
                viewContrllers.append(EXMarketHubController())
            }else if type == .transaction {
                viewContrllers.append(EXTradeHubController())
            }else if type == .fiat {
                let otc = EXOTCHomeContainerVc.instanceFromStoryboard(name: StoryBoardNameOTC)
                viewContrllers.append(otc)
            }else if type == .contract {
                viewContrllers.append(EXNewContractVc())
            }else if type == .assets {
                let asset = EXAssetsVc.init()
                viewContrllers.append(asset)
            }
        }

        let tabbarConfig = TabbarModelConfig.init()
        let tabbarController = TabbarController.init(viewControllers: viewContrllers, tabBarItemsAttributes:tabbarConfig.tabBarItemsAttributesForController())
        return tabbarController
    }
   
    func initNavBarV() -> UINavigationController{
        print("initNavBarV=----->>>")
        let navBar = NavController()
        let tabbar = initTabbarV()
        navBar.isNavigationBarHidden = true
        navBar.viewControllers = [tabbar]
        navController = navBar
        return navBar
    }
    
    func initWindow() -> UIWindow{
        let window = UIWindow(frame: UIScreen.main.bounds)
        let nav = initNavBarV()
        window.backgroundColor = UIColor.ThemeView.bg
        window.rootViewController = nav
        window.makeKeyAndVisible()
        return window
    }
    
}

