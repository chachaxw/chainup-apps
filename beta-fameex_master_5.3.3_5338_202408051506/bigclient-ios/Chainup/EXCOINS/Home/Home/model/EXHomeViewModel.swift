//
//  EXHomeViewModel.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXHomeViewModelType {
    case one//The first set (default SAAS version in China)
    case two//Second set (international version)
    case three//Third set (Japanese version)
    case contract//Contract homepage
}

enum EXHomePageStyle {
    case saas//currency
    case king//King version
    case momo//momo
    case bitsg//bitsg
    case lxg
}

class EXHomeViewModel: NSObject {

    //Which set of homepage to return to
    class func status() -> EXHomeViewModelType{
        var status = EXHomeViewModelType.one
        #if DEBUG
        let ver = EXAppCache.sharedCache.getAppHomeVersion()
        if ver == "1" {
            status = .one
        }else if ver == "2" {
            status = .two
        }else if ver == "3" {
            status = .three
        }else if ver == "4" {
            status = .contract
        }
        #else
        if let plistpath = Bundle.main.path(forResource: "Info", ofType: "plist"){
            if let dict = NSDictionary.init(contentsOfFile: plistpath){
                if let homeViewStatus = dict["HomeViewStatus"] as? String{
                    switch homeViewStatus{
                    case "1":
                        status = .one
                    case "2":
                        status = .two
                    case "3":
                        status = .three
                    case "4":
                        status = .contract
                    default:
                        status = .one
                        break
                    }
                }
            }
        }
        #endif
        return status
    }
    class func isUIStatusNormal() -> Bool {
        return status() == .one || isContractStatus()
    }
    class func isContractStatus() -> Bool {
        return status() == .contract
    }
    
    //All belong to the first set of saas, with status=. one, which is further divided into 1,2,3,4. Default 1
    class func homepageStyle() -> EXHomePageStyle{
        if let plistpath = Bundle.main.path(forResource: "Info", ofType: "plist"){
            if let dict = NSDictionary.init(contentsOfFile: plistpath){
                if let homeSettingStatus = dict["HomePageStyle"] as? String{
                    switch homeSettingStatus {
                    case "1":
                        return .saas
                    case "2":
                        return .king
                    case "3":
                        return .momo
                    case "4":
                        return .bitsg
                    case "5":
                        return .lxg
                    default:
                        return .saas
                    }
                }
            }
        }
        return .saas
    }
    
    //1. The default daytime image returned by the SAAS version in China is named home_ Personal_ Daytime;
    //2. King's return is home_ Personal_ King (black and white are the same)
    class func getHomePersonDayImage() -> String{
        var iconName = "home_personal_daytime"
        if let plistpath = Bundle.main.path(forResource: "Info", ofType: "plist"){
            if let dict = NSDictionary.init(contentsOfFile: plistpath){
                if let homeSettingStatus = dict["HomePageStyle"] as? String{
                  switch homeSettingStatus{
                  case "1":
                     iconName = "home_personal_daytime"
                  case "2":
                     iconName = "home_personal_king"
                  default:
                     iconName = "home_personal_daytime"
                     break
                 }
                }
            }
        }
        return iconName
    }
    
    //1. The default SAAS version in China returns a nighttime image named home_ Personal_ Night;
    //2. King's return is home_ Personal_ King (black and white are the same)
    class func getHomePersonNightImage() -> String{
        var iconName = "home_personal_night"
        if let plistpath = Bundle.main.path(forResource: "Info", ofType: "plist"){
            if let dict = NSDictionary.init(contentsOfFile: plistpath){
                if let homeSettingStatus = dict["HomePageStyle"] as? String{
                  switch homeSettingStatus{
                  case "1":
                     iconName = "home_personal_night"
                  case "2":
                     iconName = "home_personal_king"
                  default:
                     iconName = "home_personal_night"
                     break
                 }
                }
            }
        }
        return iconName
    }
    //1. China's default SAAS version returns home_ Banner_ Default;
    //2.King(home_banner_king_default)
    class func getHomeBannerDefaultImage() -> String{
       var iconName = "home_pic_banner_occupationmap"
        if let plistpath = Bundle.main.path(forResource: "Info", ofType: "plist"){
            if let dict = NSDictionary.init(contentsOfFile: plistpath){
                if let homeSettingStatus = dict["HomePageStyle"] as? String{
                    switch homeSettingStatus{
                    case "1":
                        iconName = "home_pic_banner_occupationmap"
                    case "2":
                        iconName = "home_banner_king_default"
                    case "3":
                        iconName = "home_banner_momo_default"
                    default:
                        iconName = "home_pic_banner_occupationmap"
                        break
                    }
                }
            }
        }
        return iconName
    }
    
    //1. The default SAAS version in China returns home;
    //2.King(home_king)
    class func getHomeNoLoginDefaultImage() -> String{
       var iconName = "home"
        if let plistpath = Bundle.main.path(forResource: "Info", ofType: "plist"){
            if let dict = NSDictionary.init(contentsOfFile: plistpath){
                if let homeSettingStatus = dict["HomePageStyle"] as? String{
                  switch homeSettingStatus{
                  case "1":
                     iconName = "home"
                  case "2":
                     iconName = "home_king"
                  default:
                     iconName = "home"
                     break
                 }
                }
            }
        }
        return iconName
    }
    
    class func appdDefaultDarkTheme() -> Bool{
        if let plistpath = Bundle.main.path(forResource: "Info", ofType: "plist"){
            if let dict = NSDictionary.init(contentsOfFile: plistpath){
                if let isDark = dict["appDarkTheme"] as? String{
                    return isDark == "1"
                }
            }
        }
        return false
    }
    
    class func appdCompanyID() -> String{
        if let plistpath = Bundle.main.path(forResource: "Info", ofType: "plist"){
            if let dict = NSDictionary.init(contentsOfFile: plistpath){
                if let appCID = dict["appCompanyID"] as? String{
                    return appCID
                }
            }
        }
        return ""
    }
    
}

