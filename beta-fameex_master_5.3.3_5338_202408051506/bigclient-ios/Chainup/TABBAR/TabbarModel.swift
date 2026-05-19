//
//  TabbarModel.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import CYLTabBarController
import EXKit
import HandyJSON
import Swap
class TabbarModelConfig : NSObject{
    
    let onlineIcon = EXAppConfigManager.sharedInstance.getAppTabIcon()
    let onlineTitle = EXAppConfigManager.sharedInstance.getAppTitleConfig()
    
    let homeicon = EXThemeManager.isNight() ? "tabbar_home_night" : "tabbar_home_daytime"
    let marketicon = EXThemeManager.isNight() ? "tabbar_quotation_night" : "tabbar_quotation_daytime"
    let exicon = EXThemeManager.isNight() ? "tabbar_trading_night" : "tabbar_trading_daytime"
    let fiaticon = EXThemeManager.isNight() ? "tabbar_fiat_default_night" : "tabbar_fiat_default_daytime"
    let coicon = EXThemeManager.isNight() ? "tabbar_contract_night" : "tabbar_contract_daytime"
    let asseticon = EXThemeManager.isNight() ? "tabbar_assest_night" : "tabbar_assest_daytime"
    
    //原先宽高为22x22,系统tabbar最大应该是32x32
    let tabbarSize:CGSize = CGSize(width: 22, height: 22)
    
    func getHomeIconAttributes() -> [String : Any] {
        
        let isNight = EXThemeManager.isNight()
        let iconDL = EXAppConfigManager.sharedInstance.configDownloader
        let nonrmalPath = isNight ? onlineIcon.tabbar_home_default_night : onlineIcon.tabbar_home_default_daytime
        let selectedPath = onlineIcon.tabbar_home_selected
        
        guard let dlpath = iconDL.cache.filePath(fileName: nonrmalPath.md5PngFileName()),
              let hlpath = iconDL.cache.filePath(fileName: selectedPath.md5PngFileName()),
              let dlIcon = UIImage.init(contentsOfFile: dlpath)?.yy_imageByResize(to: tabbarSize),
              let hlIcon = UIImage.init(contentsOfFile: hlpath)?.yy_imageByResize(to: tabbarSize)
        else
        {
            return [CYLTabBarItemTitle:homeTitle(),
                    CYLTabBarItemImage:homeicon,
            CYLTabBarItemSelectedImage:tabBarItemSelectedImage(named: "tabbar_home_hover")]
            
        }
        
        return [CYLTabBarItemTitle:homeTitle(),
                CYLTabBarItemImage:dlIcon.withRenderingMode(.alwaysOriginal),
        CYLTabBarItemSelectedImage:hlIcon.withRenderingMode(.alwaysOriginal)]
    }
    
    func getMarketIconAttributes() -> [String : Any] {
        let isNight = EXThemeManager.isNight()
        let iconDL = EXAppConfigManager.sharedInstance.configDownloader
        let nonrmalPath = isNight ? onlineIcon.tabbar_quotes_default_night : onlineIcon.tabbar_quotes_default_daytime
        let selectedPath = onlineIcon.tabbar_quotes_selected
        
        guard let dlpath = iconDL.cache.filePath(fileName: nonrmalPath.md5PngFileName()),
              let hlpath = iconDL.cache.filePath(fileName: selectedPath.md5PngFileName()),
              let dlIcon = UIImage.init(contentsOfFile: dlpath)?.yy_imageByResize(to: tabbarSize),
              let hlIcon = UIImage.init(contentsOfFile: hlpath)?.yy_imageByResize(to: tabbarSize)
        else
        {
            
            return [CYLTabBarItemTitle:marketTitle(),
                    CYLTabBarItemImage:marketicon,
            CYLTabBarItemSelectedImage:tabBarItemSelectedImage(named: "tabbar_quotation_hover")]
        }
        
        return [CYLTabBarItemTitle:marketTitle(),
                CYLTabBarItemImage:dlIcon.withRenderingMode(.alwaysOriginal),
        CYLTabBarItemSelectedImage:hlIcon.withRenderingMode(.alwaysOriginal)]
    }
    
    func getFiatIconAttributes() -> [String : Any] {
        
        let isNight = EXThemeManager.isNight()
        let iconDL = EXAppConfigManager.sharedInstance.configDownloader
        let nonrmalPath = isNight ? onlineIcon.tabbar_fiat_default_night : onlineIcon.tabbar_fiat_default_daytime
        let selectedPath = onlineIcon.tabbar_fiat_selected
        
        guard let dlpath = iconDL.cache.filePath(fileName: nonrmalPath.md5PngFileName()),
              let hlpath = iconDL.cache.filePath(fileName: selectedPath.md5PngFileName()),
              let dlIcon = UIImage.init(contentsOfFile: dlpath)?.yy_imageByResize(to: tabbarSize),
              let hlIcon = UIImage.init(contentsOfFile: hlpath)?.yy_imageByResize(to: tabbarSize)
        else
        {
            
            return [CYLTabBarItemTitle:fiatTitle(),
                    CYLTabBarItemImage:fiaticon,
            CYLTabBarItemSelectedImage:tabBarItemSelectedImage(named: "tabbar_fiat_selected")]
        }
        
        return [CYLTabBarItemTitle:fiatTitle(),
                CYLTabBarItemImage:dlIcon.withRenderingMode(.alwaysOriginal),
        CYLTabBarItemSelectedImage:hlIcon.withRenderingMode(.alwaysOriginal)]
    }
    
    func getTxIconAttributes() -> [String : Any] {
        
        let isNight = EXThemeManager.isNight()
        let iconDL = EXAppConfigManager.sharedInstance.configDownloader
        let nonrmalPath = isNight ? onlineIcon.tabbar_exchange_default_night : onlineIcon.tabbar_exchange_default_daytime
        let selectedPath = onlineIcon.tabbar_exchange_selected
        
        guard let dlpath = iconDL.cache.filePath(fileName: nonrmalPath.md5PngFileName()),
              let hlpath = iconDL.cache.filePath(fileName: selectedPath.md5PngFileName()),
              let dlIcon = UIImage.init(contentsOfFile: dlpath)?.yy_imageByResize(to: tabbarSize),
              let hlIcon = UIImage.init(contentsOfFile: hlpath)?.yy_imageByResize(to: tabbarSize)
        else
        {
            return [CYLTabBarItemTitle:exTitle(),
                    CYLTabBarItemImage:exicon,
            CYLTabBarItemSelectedImage:tabBarItemSelectedImage(named: "tabbar_tradingt_hover")]
        }
        
        return [CYLTabBarItemTitle:exTitle(),
                CYLTabBarItemImage:dlIcon.withRenderingMode(.alwaysOriginal),
        CYLTabBarItemSelectedImage:hlIcon.withRenderingMode(.alwaysOriginal)]
    }
    
    func getCoIconAttributes() -> [String : Any] {
        let isNight = EXThemeManager.isNight()
        let iconDL = EXAppConfigManager.sharedInstance.configDownloader
        let nonrmalPath = isNight ? onlineIcon.tabbar_contract_default_night : onlineIcon.tabbar_contract_default_daytime
        let selectedPath = onlineIcon.tabbar_contract_selected
        
        guard let dlpath = iconDL.cache.filePath(fileName: nonrmalPath.md5PngFileName()),
              let hlpath = iconDL.cache.filePath(fileName: selectedPath.md5PngFileName()),
              let dlIcon = UIImage.init(contentsOfFile: dlpath)?.yy_imageByResize(to: tabbarSize),
              let hlIcon = UIImage.init(contentsOfFile: hlpath)?.yy_imageByResize(to: tabbarSize)
        else
        {
            return [CYLTabBarItemTitle:coTitle(),
                    CYLTabBarItemImage:coicon,
            CYLTabBarItemSelectedImage:tabBarItemSelectedImage(named: "tabbar_contract_hover")]
        }
        
        return [CYLTabBarItemTitle:coTitle(),
                CYLTabBarItemImage:dlIcon.withRenderingMode(.alwaysOriginal),
        CYLTabBarItemSelectedImage:hlIcon.withRenderingMode(.alwaysOriginal)]
    }
    
    func getAssetIconAttributes() -> [String : Any] {
        let isNight = EXThemeManager.isNight()
        let iconDL = EXAppConfigManager.sharedInstance.configDownloader
        let nonrmalPath = isNight ? onlineIcon.tabbar_assets_default_night : onlineIcon.tabbar_assets_default_daytime
        let selectedPath = onlineIcon.tabbar_assets_selected
        
        guard let dlpath = iconDL.cache.filePath(fileName: nonrmalPath.md5PngFileName()),
              let hlpath = iconDL.cache.filePath(fileName: selectedPath.md5PngFileName()),
              let dlIcon = UIImage.init(contentsOfFile: dlpath)?.yy_imageByResize(to: tabbarSize),
              let hlIcon = UIImage.init(contentsOfFile: hlpath)?.yy_imageByResize(to: tabbarSize)
        else
        {
            return [CYLTabBarItemTitle:assetTitle(),
                    CYLTabBarItemImage:asseticon,
            CYLTabBarItemSelectedImage:tabBarItemSelectedImage(named: "tabbar_assest_hover")]
        }
        
        return [CYLTabBarItemTitle:assetTitle(),
                CYLTabBarItemImage:dlIcon.withRenderingMode(.alwaysOriginal),
        CYLTabBarItemSelectedImage:hlIcon.withRenderingMode(.alwaysOriginal)]
    }
    
    
    func tabBarItemsAttributesForController() ->  [[String : Any]] {
        
        //todo能下载url的icon
        var tabbarItemModel : [[String : Any]] = []
        for type in EXAppConfigManager.sharedInstance.appModules {
            if type == .home {
                tabbarItemModel.append(getHomeIconAttributes())
            }else if type == .market {
                tabbarItemModel.append(getMarketIconAttributes())
            }else if type == .transaction {
                tabbarItemModel.append(getTxIconAttributes())
            }else if type == .fiat {
                tabbarItemModel.append(getFiatIconAttributes())
            }else if type == .contract {
                tabbarItemModel.append(getCoIconAttributes())
            }else if type == .assets {
                tabbarItemModel.append(getAssetIconAttributes())
            }
        }
        return tabbarItemModel
    }
}

extension TabbarModelConfig {
    
    func getHomeIcon(highLight:Bool) -> UIImage? {
        let attr = getHomeIconAttributes()
        if highLight {
            if let icon = attr[CYLTabBarItemSelectedImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: "tabbar_home_hover")?.withRenderingMode(.alwaysOriginal)
            }
        }else {
            if let icon = attr[CYLTabBarItemImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: homeicon)?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    func getMarketIcon(highLight:Bool) -> UIImage? {
        let attr = getMarketIconAttributes()
        if highLight {
            if let icon = attr[CYLTabBarItemSelectedImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: "tabbar_quotation_hover")?.withRenderingMode(.alwaysOriginal)
            }
        }else {
            if let icon = attr[CYLTabBarItemImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: marketicon)?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    func getFiatIcon(highLight:Bool) -> UIImage? {
        let attr = getFiatIconAttributes()
        if highLight {
            if let icon = attr[CYLTabBarItemSelectedImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: "tabbar_fiat_selected")?.withRenderingMode(.alwaysOriginal)
            }
        }else {
            if let icon = attr[CYLTabBarItemImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: fiaticon)?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    func getCoIcon(highLight:Bool) -> UIImage? {
        let attr = getCoIconAttributes()
        if highLight {
            if let icon = attr[CYLTabBarItemSelectedImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: "tabbar_contract_hover")?.withRenderingMode(.alwaysOriginal)
            }
        }else {
            if let icon = attr[CYLTabBarItemImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: coicon)?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    func getAssetsIcon(highLight:Bool) -> UIImage? {
        let attr = getAssetIconAttributes()
        if highLight {
            if let icon = attr[CYLTabBarItemSelectedImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: "tabbar_assest_hover")?.withRenderingMode(.alwaysOriginal)
            }
        }else {
            if let icon = attr[CYLTabBarItemImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: asseticon)?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    func getTxIcon(highLight:Bool) -> UIImage? {
        let attr = getTxIconAttributes()
        if highLight {
            if let icon = attr[CYLTabBarItemSelectedImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: "tabbar_tradingt_hover")?.withRenderingMode(.alwaysOriginal)
            }
        }else {
            if let icon = attr[CYLTabBarItemImage] as? UIImage {
                return icon
            }else {
                return UIImage.init(named: exicon)?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
}

extension TabbarModelConfig {
    
    func homeTitle()->String {
        return onlineTitle.home.count > 0 ? onlineTitle.home : "mainTab_text_home".localized()
    }
    
    func marketTitle()->String {
        return onlineTitle.quotes.count > 0 ? onlineTitle.quotes : "mainTab_text_market".localized()
    }
    
    func fiatTitle()->String {
        return onlineTitle.fiat.count > 0 ? onlineTitle.fiat : "mainTab_text_otc".localized()
    }
    
    func exTitle()->String {
        return  onlineTitle.exchange.count > 0 ? onlineTitle.exchange : "assets_action_transaction".localized()
    }
    
    func coTitle()->String {
        return onlineTitle.contract.count > 0 ? onlineTitle.contract : "mainTab_text_contract".localized()
    }
    
    func assetTitle()->String {
        return onlineTitle.assets.count > 0 ? onlineTitle.assets : "mainTab_text_assets".localized()
    }
}


extension TabbarModelConfig {
   private func tabBarItemSelectedImage(named: String) -> Any {
        if let image = UIImage.svgImage(named: named) {
            return image.withRenderingMode(.alwaysOriginal)
        }
        return named
    }
}

extension TabbarModelConfig {
   static func getTabBarChildControllers() -> [UIViewController] {
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
       return viewContrllers
    }
}
