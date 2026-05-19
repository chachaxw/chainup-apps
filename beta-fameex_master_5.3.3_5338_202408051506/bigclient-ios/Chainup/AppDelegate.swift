//
//  AppDelegate.swift
//  AppProject
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import Alamofire
import IQKeyboardManagerSwift

import RxSwift
import RxCocoa

//import Firebase
//import FirebaseMessaging
import EXKit
import SwiftEventBus
import Swap
import Firebase
#if DEBUG
//import DoraemonKit
#endif
/// info.plist channelId: 0: AppStore 1: TestFlight 9: Enterprise
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navController : UINavigationController?
    var loadSwapSDK = false
    var reStart = false
    var reloadSwapSDKTime = 0.0
    let gcmMessageIDKey = "gcm.message_id"
    
   let disposeBag = DisposeBag()
    
    func configEXkits() {
        EXUIDatasource.shared.isDarkConfig = EXHomeViewModel.appdDefaultDarkTheme()
        EXAppLaunchConfig.upDateEXKitConfig()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //TODO: Network Update Contract sdk
        SwiftyFitsize.reference(width: 375, height: 812, isIPhoneXSeriesHeight: false, iPadFitMultiple: 0.6)
        configTableView()
        UITextField.awake()
        EXTracking.shared.setup()
        XUserDefault.clearLocalLanguageDefaultsData(contract: false)
        EXNetworkDoctor.sharedManager.configNetWork()
        
        EXNetworkReachabilityManager.sharedManager.startListen()
        EXWebSocket.marketService.connectServer()

        let IQ = IQKeyboardManager.shared
        IQ.enable = true       //Control whether the entire function is enabled
        IQ.shouldResignOnTouchOutside = true      //Control whether clicking on the background collapses the keyboard
        IQ.shouldToolbarUsesTextFieldTintColor = false       //Controls whether the text color of the toolbar on the keyboard is user-defined
        IQ.enableAutoToolbar = true      //Control whether to display the toolbar on the keyboard
        IQ.toolbarDoneBarButtonItemText = "finish".localized()
        IQ.toolbarTintColor = .Ex.main4
        IQ.placeholderColor = .Ex.text2
        Router.default.setupAppNavigation(appNavigation: EXPushAppNavigation())
        
        UITextField.appearance().tintColor = UIColor.ThemeView.highlight
        self.window?.backgroundColor  = UIColor.ThemeView.bg
        UserInfoEntity.getTmpDict()
        SwiftEventBus.onMainThread(self, name: EXReachabilityKey.onNetworkConnected) {[weak self] (result) in
            self?.prePareContractSDK()
        }
        EXIPLimitManger.shared.work()
        //fetchAppConfig success will initWindow
        self.window = initWindow()
        configEXkits()
//#if DEBUG
//        HiDebugManager.sharedManager.startListeningShake()
////        DoraemonManager.shareInstance().install()
//#endif
        if let _ = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"){
            FirebaseApp.configure()
//            EXPushMsgHandler.shared.register()
        }
        
        //Delay 10 seconds to upload logs
#if DEBUG
//        self.perform(#selector(inputLogInfo), with: nil, afterDelay: 10)
#endif
        
        if let _ = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"){
//            FirebaseApp.configure()
//            EXPushMsgHandler.shared.register()
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if isContractOpen() {
            EXSwapSocketManager.shared.disconnectServer()
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        BusinessTools.checkVersion()
        //Reopen the app to re-establish the contract websocket connection
        if isContractOpen() {
            if reStart == true {
                EXSwapSocketManager.shared.connectServer(url: EXNetworkDoctor.sharedManager.getNewContractWs())
            }
            reStart = true
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //Every time the app process is terminated, the token needs to be cleaned up
        //        XUserDefault.removeKey(key: XUserDefault.token)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //         print(url.scheme ?? "333333")
        dealGameJump(urlStr: url.absoluteString)
        return true
    }
    
}

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
//        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
        
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
}

extension AppDelegate {
    
    func prePareContractSDK() {
        if EXSwapPlatformSDK.shared.lauchSuccess {
            return //One contract initialization is sufficient
        }
        if EXAppConfigManager.sharedInstance.didOpenContract() {
            XUserDefault.clearLocalLanguageDefaultsData()
            initContractSDK()
        }
    }
    @objc func swapSDKLoadPlatForm() {
        
        if let token = XUserDefault.getToken(), token.count > 0 {
            let account = EXSwapAccount()
            account.token = token
            EXSwapPlatformSDK.shared.activeAccount = account
            EXSwapPlatformSDK.shared.inviteUrl = UserInfoEntity.sharedInstance().inviteUrl
        }
    }
    public func changeHosts() {
        if EXAppConfigManager.sharedInstance.didOpenContract() {
            EXSwapSocketManager.shared.disconnectServer()
            EXSwapSocketManager.shared.connectServer(url: EXNetworkDoctor.sharedManager.getNewContractWs())
            initContractSDK()
        }
    }
    
    public func isContractOpen() ->Bool {
        if EXAppConfigManager.sharedInstance.didOpenContract() {
            return true
        }
        return false
    }
    func initContractSDK() {
        
        //Successfully monitored login
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(swapSDKLoadPlatForm),
                                               name: NSNotification.Name(rawValue: "EXLoginSuccess"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshLogout),
                                               name: NSNotification.Name(rawValue: "Logout_notification_name"),
                                               object: nil)
        
        initSwapPlatformSDK()
        connectContractSDK()
    }
    func initSwapPlatformSDK() {
        EXSwapPlatformSDK.shared.goToH5 = { (url,title,currentVC,type) in
            var newTitle = title
            var newUrl = url
            if let t = type, t == .coProfitRecord {
                newUrl = EXNetworkDoctor.getContractProfitUrl()
            }
            let vc = WebVC()
            if let t = newTitle, t.count > 0 {
                vc.customTitle = t
            }
            vc.loadUrl(newUrl)
            currentVC?.navigationController?.pushViewController(vc, animated: true)
        }
        
        EXSwapPlatformSDK.shared.loginCallBack = {
            BusinessTools.modalLoginVC()
        }
        //Line switching callback
        EXSwapPlatformSDK.shared.changeHostLineCall = {
            EXSSwapChangeHostManager.sharedManager.changeHostLine()
        }
        //Ws line switching callback
        EXSwapPlatformSDK.shared.changeWsHostLineCall = {
            EXSSwapChangeHostManager.sharedManager.changeWsHostline()
        }
        //Update to contracted language pack
        EXSwapPlatformSDK.shared.upDateEXKitConfigCallBack = {
            EXAppLaunchConfig.upDateEXKitConfig()
        }
        //Obtain Exchange Rate
        EXSwapPlatformSDK.shared.getFiatCoinSymbolBack = {
            let symbol = EXAppMarketManager.sharedInstance.getFiatCoinSymbol()
            EXSwapPrivateConfig.shared.fiatCoinSymbol = symbol
            EXSwapPrivateConfig.shared.coinInfo  = EXAppMarketManager.sharedInstance.getCoinExchangeRate(symbol)
        }
        //Transfer callback
        EXSwapPlatformSDK.shared.transferOnClickedCallBack = { (symbol,currentVC) in
            EXAccountBalanceManager.manager.updateContractAccountBalance()
            let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
            transfer.isPopRoot = true
            transfer.symbol = symbol
            transfer.transferFlow = .contractToExchagne
            transfer.onTrasferSuccessCallback = { (ftype,ttype) in
            }
            currentVC.navigationController?.pushViewController(transfer, animated: true)
        }
        //Real name authentication
        EXSwapPlatformSDK.shared.realNameAuthenticationCallBack = {
            let realName = EXIDAuthenticViewController()
            AppService.topViewController().navigationController?.pushViewController(realName, animated: true)
        }
 
        
    }
    func connectContractSDK() {
        
        let config = EXSwapPrivateConfig.shared
        config.isPrivate = true
        config.base_host = EXNetworkDoctor.sharedManager.getNewContractAPI()
        config.ws = EXNetworkDoctor.sharedManager.getNewContractWs()
        config.appIcon = EXKitStanders.getAppicon() ?? UIImage()
        EXSwapSocketManager.shared.connectServer(url: EXNetworkDoctor.sharedManager.getNewContractWs())
        EXContractSDK.ex_start(AppName: EXKitStanders.getAppName(), launchOption: config) { (_, _) in
            self.swapSDKLoadPlatForm()
            EXSwapPlatformSDK.shared.lauchSuccess = true
        }
    }
    @objc func refreshLogout() {
        EXContractSDK.alreadLogout()
        EXSwapPlatformSDK.shared.activeAccount = nil
    }
    
    //Game app jumps over for authorization
    //比如：NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"gameJump://GameId=% @&gameName=% @&gameScheme=% @&gameToken=% @ ", @" 123 ", @" Game ", @" app1 ", @" 232323 "];
    //GameId: game ID (for backend interface), gameScheme: unique identifier of the game app, gameToken: token (for backend interface), gameName: game name
    func dealGameJump(urlStr : String) {
        if urlStr.hasPrefix("gameJump://") {
            let str = urlStr.replacingOccurrences(of: "gameJump://", with: "")
            let paraArr = str.components(separatedBy: "&")
            var paraDic : [String : String] = [:]
            for item in paraArr {
                let keyArr = item.components(separatedBy: "=")
                if keyArr.count == 2{
                    let key = keyArr[0]
                    let value = keyArr[1]
                    paraDic[key] = value
                }
            }
            //Store parameters passed from the game
            EXGameJumpManager.shareInstance.paraDic = paraDic
            print(paraDic)
            //If not logged in, log in and display the authorization page
            if XUserDefault.getToken() == nil{
                BusinessTools.modalLoginVC()
            }else {
                EXGameJumpManager.shareInstance.presentAuthorVc()
            }
        }else {
            EXGameJumpManager.shareInstance.paraDic = nil
        }
    }
//    @objc func inputLogInfo(){
//        NetworkInputLog.inputLogInfo()
//    }
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
//Add screen supported rotation direction:
extension AppDelegate{
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        return UIDeviceManger.shared.blockRotation
    }
}

/*
Integration of contract private libraries in development projects
 0. configTableView
1. Please refer to the callback implementation for details
Callback implementation in initSwapPlatformSDK

2. Some configuration items required in the contract
 
2.1 Sharing
 EXSwapPrivateConfig.shared.sharePage =  EXAppConfigManager.sharedInstance.getSharingPage
2.2 After successful route switching, the latest route needs to be recorded
Process update routes in the method func updateSwapDomain
 EXSwapPrivateConfig.shared.ws =  self.wsContractV2
 EXSwapPrivateConfig.shared.base_host =  self.contractApiV2
 
2.3 Update to contract updateConfigToContract() after obtaining configuration information
2.4 Update precision information EXSwapPrivateConfig.shared.coinPrecision Map after obtaining market currency pair information
 */

