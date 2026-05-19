//
//  AppDelegate.swift
//  Swap
//
//  Created by 柴伟东 on 05/07/2022.
//  Copyright (c) 2022 柴伟东. All rights reserved.
//

import UIKit
import Swap
import EXKit
import IQKeyboardManagerSwift
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configSvg()
        configSWapSDK()
        configEXkits()
        self.window = creatWindow()
        return true
    }
    
    func configSvg(){
//        SvgConfigManger.shared.updateThemeColor()
      //  SvgConfigManger.shared.newThemeColor = "#FADE14"
    }
    
    func configSWapSDK(){
        configTableView()
        configKeyboard()
        loadEXSwapSDK()
        initSwapPlatformSDK()
        swapSDKLoadPlatForm()
    }
    
    func configKeyboard(){
        let IQ = IQKeyboardManager.shared
        IQ.enable = true       //控制整个功能是否启用
        IQ.shouldResignOnTouchOutside = true      //控制点击背景是否收起键盘
        IQ.shouldToolbarUsesTextFieldTintColor = false       //控制键盘上的工具条文字颜色是否用户自定义
        IQ.enableAutoToolbar = true      //控制是否显示键盘上的工具条
    }
    func creatWindow() -> UIWindow {

        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let nav = initNavBarV()
        window.backgroundColor = UIColor.ThemeView.bg
        window.rootViewController = nav
        window.makeKeyAndVisible()
        return window
    }
    func initNavBarV() -> UINavigationController {
        let navBar = NavController()
        let log = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: "login")) as! ViewController
        
        log.tabBarItem.title = "登录"
        
        let market = EXCoMarketListContainer()
        market.tabBarItem.title = "行情"
        
        let contract = EXNewContractVc()
        contract.tabBarItem.title = "合约"
      
        let asset = EXSwapAssetListVC()
        asset.tabBarItem.title = "资产"
    
        let tabbar = UITabBarController()
        tabbar.viewControllers  = [log,market,contract,asset]
        navBar.isNavigationBarHidden = true
        navBar.viewControllers = [tabbar]
        
        return navBar
    }
    
    // 监听登录成功
    @objc func swapSDKLoadPlatForm() {
        //止盈止损 
        
        let token = "1312be19dd0da6a155877e0b7d6d9243c5a1bb9655f44ffd9dfa2ad523091494"
        if token.count > 0 {
            let account = EXSwapAccount()
            account.token = token
            EXSwapPlatformSDK.shared.activeAccount = account
            EXSwapPlatformSDK.shared.inviteUrl = "邀请链接"
        }
    }
    
    func initSwapPlatformSDK() {
        EXSwapPlatformSDK.shared.loginCallBack = {
            //弹出登录
        }
        EXSwapPlatformSDK.shared.transferOnClickedCallBack = { (symbol,currentVC) in
           //跳转到划转
        }
        EXSwapPlatformSDK.shared.realNameAuthenticationCallBack = {
            //实名认证
        }
    }
    func loadEXSwapSDK() {
        let base = "http://coappapi.creaverse.top/" //新合约
        let ws = "wss://futuresws0001552.chainsprince.me/kline-api/ws" //新合约ws
        let infoDictionary = Bundle.main.infoDictionary!
        let appDisplayName = infoDictionary["CFBundleDisplayName"] as? String ?? "swap"//程序名称
    
        let config = EXSwapPrivateConfig.shared
        config.base_host = base
        config.ws = ws
        config.appIcon =  UIImage.themeImageNamed(imageName:"personal_shutdown")
        config.sharePage = "www.baidu.com"
        config.appName = appDisplayName
        EXSwapSocketManager.shared.connectServer(url: ws)
        EXContractSDK.ex_start(AppName: appDisplayName, launchOption: config, finish: { (_, _) in
            //登录状态已记录
            self.swapSDKLoadPlatForm()
        })
    }
    
    
    func configEXkits() {
        EXLanguageTools.shareInstance.initUserLanguage()
        
        EXUIDatasource.shared.alertOnlyBtnTitle = "cp_extra_text28".ex_localized()
        EXUIDatasource.shared.cancelTitle = "cp_overview_text56".ex_localized()
        EXUIDatasource.shared.confirmTitle = "cp_calculator_text16".ex_localized()
        EXUIDatasource.shared.refresh_up_Title = "cp_refresh_text4".ex_localized()
        EXUIDatasource.shared.refresh_down_Title = "cp_refresh_text1".ex_localized()
        EXUIDatasource.shared.refresh_trigger = "cp_refresh_text2".ex_localized()
        EXUIDatasource.shared.common_tip_nodata = "cp_loadmore_nodata".ex_localized()
        EXUIDatasource.shared.refresh_refreshing = "cp_loadmore_loading".ex_localized()
        
    }
    
    
}

//添加 屏幕支持的旋转方向：
extension AppDelegate{
     func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIDeviceManger.shared.blockRotation
    }
}

extension AppDelegate{
    func configTableView(){
        if #available(iOS 11.0, *) {
            UITableView.appearance().estimatedRowHeight = 0;
            UITableView.appearance().estimatedSectionFooterHeight = 0;
            UITableView.appearance().estimatedSectionHeaderHeight = 0;
            UITableView.appearance().contentInsetAdjustmentBehavior = .never
        }
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
    }
}
