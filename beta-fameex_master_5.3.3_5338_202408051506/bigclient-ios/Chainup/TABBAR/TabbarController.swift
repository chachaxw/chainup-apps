//
//  TabbarController.swift
//  AppProject
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import CYLTabBarController
import Tiercel
import Lottie
import EXKit
import Swap
import IQKeyboardManagerSwift


class TabbarController: CYLTabBarController {
    
    var animationView: LottieAnimationView?
    var supportLottie:Bool = true
    
    override  public func viewDidLoad() {
        super.viewDidLoad()
        let appmodules = EXAppConfigManager.sharedInstance.appModules
        let onlineIcon = EXAppConfigManager.sharedInstance.getAppTabIcon()
        
        if onlineIcon.allIcons().count == appmodules.count*3 {
            supportLottie = false
        }
        
        customizeTabbar()
      
        self.delegate = self
        NotificationCenter.default.addObserver(forName: SessionManager.didCompleteNotification, object: nil, queue: nil) { (notification) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.updateiconIfNeeded()
            }
        }
        
#if DEBUG
        return
#endif
        EXAppConfigManager.sharedInstance.limitVisit.subscribe(onNext: { visit in
            guard visit.visitStatus == .forbid else {
                return
            }
            guard visit.countryNames.count > 0 else {
                return
            }
            let alert = EXLimitUserAlert()
            alert.setForbidCountry(visit.countryNames)
            EXAlert.showAlert(alertView: alert, offset: 0)
        }).disposed(by: self.disposeBag)
    }
    
    func customizeTabbar() {
        
        let title = [NSAttributedString.Key.foregroundColor:UIColor.ThemeLabel.colorMedium,
                     NSAttributedString.Key.font:UIFont.ThemeFont.MinimumRegular]
        let selectedTitle = [NSAttributedString.Key.foregroundColor:UIColor.ThemeLabel.colorHighlight,
                             NSAttributedString.Key.font:UIFont.ThemeFont.MinimumRegular]
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarItemAppearance.init()
            appearance.normal.titleTextAttributes = title
            appearance.selected.titleTextAttributes = selectedTitle
            let tabbarAppearance = UITabBarAppearance.init()
            tabbarAppearance.backgroundColor = UIColor.ThemeTab.bg
            tabbarAppearance.stackedLayoutAppearance = appearance
            tabbarAppearance.shadowColor = UIColor.ThemeView.seperator
            self.tabBar.standardAppearance = tabbarAppearance
            if #available(iOS 15.0, *) {
                self.tabBar.scrollEdgeAppearance = tabbarAppearance
            }
            self.tabBar.isTranslucent = false
        }else {
            self.tabBar.isTranslucent = false
            UITabBarItem.appearance().setTitleTextAttributes(title, for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes(selectedTitle, for: .selected)
            UITabBar.appearance().backgroundImage = UIImage.getImageWithColor(color: UIColor.ThemeTab.bg, size: CGSize(width: SCREEN_WIDTH, height: TABBAR_HEIGHT))
            UITabBar.appearance().shadowImage = UIImage.getImageWithColor(color: UIColor.ThemeView.seperator, size: CGSize(width: SCREEN_WIDTH, height: 0.5))
            
        }
    }
    
    //    func handleRedPoint() {
    //        if EXAppConfigManager.sharedInstance.didOpenContract(),
    //           EXAppConfigManager.sharedInstance.getContractVersion() == .new {
    //            let index = getVCIndex(EXContractVc())
    //            let vc = self.viewControllers[index]
    //            vc.cyl_badgeBackgroundColor = UIColor.ThemeState.fail
    //            vc.cyl_badge.borderW = 1
    //            vc.cyl_badge.layer.borderColor = UIColor.white.cgColor
    //            vc.cyl_showBadge()
    //        }
    //    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(  animated)
        //        handleRedPoint()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override var shouldAutorotate: Bool{
        return false
    }
    
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let gen = UIImpactFeedbackGenerator.init(style: .light)
        gen.prepare()
        gen.impactOccurred()
    }
    
    func updateiconIfNeeded() {
        let tabbarConfig = TabbarModelConfig.init()
        let appmodules = EXAppConfigManager.sharedInstance.appModules
        if let items = self.tabBar.items {
            if items.count == appmodules.count {
                for (idx,item) in items.enumerated() {
                    let type = appmodules[idx]
                    if type == .home {
                        item.title = tabbarConfig.homeTitle()
                        item.image = tabbarConfig.getHomeIcon(highLight: false)
                        item.selectedImage = tabbarConfig.getHomeIcon(highLight: true)
                    }else if type == .fiat {
                        item.title = tabbarConfig.fiatTitle()
                        item.image = tabbarConfig.getFiatIcon(highLight: false)
                        item.selectedImage = tabbarConfig.getFiatIcon(highLight: true)
                    }else if type == .market {
                        item.title = tabbarConfig.marketTitle()
                        item.image = tabbarConfig.getMarketIcon(highLight: false)
                        item.selectedImage = tabbarConfig.getMarketIcon(highLight: true)
                    }else if type == .contract {
                        item.title = tabbarConfig.coTitle()
                        item.image = tabbarConfig.getCoIcon(highLight: false)
                        item.selectedImage = tabbarConfig.getCoIcon(highLight: true)
                    }else if type == .assets {
                        item.title = tabbarConfig.assetTitle()
                        item.image = tabbarConfig.getAssetsIcon(highLight: false)
                        item.selectedImage = tabbarConfig.getAssetsIcon(highLight: true)
                    }else if type == .transaction {
                        item.title = tabbarConfig.exTitle()
                        item.image = tabbarConfig.getTxIcon(highLight: false)
                        item.selectedImage = tabbarConfig.getTxIcon(highLight: true)
                    }
                }
            }
        }
    }
    
}

extension UITabBarController{
    
    @objc func getAllTabVC() -> [UIViewController]{
        if self.viewControllers != nil{
            return self.viewControllers!
        }
        return []
    }
    
    //    func selectIndexWith(_ vc : UIViewController){
    //        let index = getVCIndex(vc)
    //        selectIndex(index)
    //    }
    
    func selectIndex(_ index : Int , showLogin : Bool = true){
        self.selectedIndex = index
    }
    
    func getTabbarVC(_ index : Int) -> UIViewController{
        if let count = viewControllers?.count , let vc = viewControllers{
            if count > index{
                return vc[index]
            }else if count > 0{
                return vc[0]
            }
        }
        return UIViewController()
    }
    
    func getCurrentTabbarVC() -> UIViewController{
        let index = self.selectedIndex
        let vc = getTabbarVC(index)
        return vc
    }
}

extension TabbarController  {
    
    override func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is EXAssetsVc {
            if XUserDefault.isOffLine() {
                BusinessTools.modalLoginVC()
                return false
            }else {
                return true
            }
        }
        return true
    }
    
}

extension TabbarController {
    
    override func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is EXNewContractVc {
            EXSwapPlatformSDK.updateContractLan()//
        }else{
            EXAppLaunchConfig.upDateEXKitConfig()
        }
        if supportLottie {
            setupAnimation(tabBarController, viewController)
        }
    }
    
    private func getAnimationViewAtTabBarIndex(_ index: Int, _ frame: CGRect)-> LottieAnimationView? {
        let appmodules = EXAppConfigManager.sharedInstance.appModules
        if appmodules.count > index {
            let type = appmodules[index]
            var animeName = ""
            switch type {
            case .home:
                animeName = "home"
            case .market:
                animeName = "market"
            case .contract:
                animeName = "contract"
            case .transaction:
                animeName = "trade"
            case .assets:
                animeName = "asset"
            default:
                animeName = ""
            }
            if animeName.count > 0 {
                let view = LottieAnimationView(name: animeName)
                view.updateTabbarItemColorValue()
                view.frame = frame
                view.contentMode = .scaleAspectFill
                view.animationSpeed = 1
                return view
            }
        }
        return nil
    }
    
    private func setupAnimation(_ tabBarVC: UITabBarController, _ viewController: UIViewController){
        
        if animationView != nil {
            animationView!.stop()
        }
        let s_idx = self.selectedIndex
        var tabBarSwappableImageViews = [UIImageView]()
        
        for tempView in self.tabBar.subviews {
            
            if tempView.isKind(of: NSClassFromString("UITabBarButton")!) {
                
                for tempImgV in tempView.subviews {
                    if tempImgV.isKind(of: NSClassFromString("UITabBarButtonLabel")!) {
                        
                    }else if tempImgV.isKind(of: NSClassFromString("UITabBarSwappableImageView")!) {
                        tabBarSwappableImageViews.append(tempImgV as! UIImageView)
                    }
                }
            }
        }
        
        let currentTabBarSwappableImageView = tabBarSwappableImageViews[s_idx]
        var frame = currentTabBarSwappableImageView.frame
        frame.origin.x = 0
        frame.origin.y = 0
        if let animation = getAnimationViewAtTabBarIndex(s_idx, frame) {
            self.animationView = animation
            self.animationView!.center = currentTabBarSwappableImageView.center
            self.animationView?.animationSpeed = 1.8
            currentTabBarSwappableImageView.superview?.addSubview( animation)
            currentTabBarSwappableImageView.isHidden = true
            animation.play(fromProgress: 0, toProgress: 1) { (finished) in
                currentTabBarSwappableImageView.isHidden = false
                animation.removeFromSuperview()
            }
        }
        
    }
}

extension TabbarController{
    
    func reloadTabbar(){
        let lastAppModules = EXAppConfigManager.sharedInstance.lastAppModules
        let newModels =  EXAppConfigManager.sharedInstance.appModules
        let hasChange = (lastAppModules != newModels)
        if hasChange == false {
            return
        }
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "finish".localized()
        EXAppConfigManager.sharedInstance.lastAppModules = newModels

        //[.home,.market,.transaction,.assets]
        var defaultVcs  = self.children //only keep home ,remove other
//        print("defaultVcs = \(defaultVcs.count)")
        for _ in 0..<defaultVcs.count-1 {
            defaultVcs.removeLast()
        }
        var newVcs = TabbarModelConfig.getTabBarChildControllers() //only remve home,keep other
        newVcs.removeFirst()
        for newVc in newVcs {
            defaultVcs.append(newVc)
        }
        self.setViewControllers(defaultVcs, animated: true)
//        print("update Tabbar = \(self.children)")
        self.updateiconIfNeeded()
        
    }
    
    func updateTabbarLan(){
       

        //[.home,.market,.transaction,.assets]
        var defaultVcs  = self.children //only keep home ,remove other
//        print("defaultVcs = \(defaultVcs.count)")
        defaultVcs.removeFirst()
        let home = EXHomepageVc()
        defaultVcs.insert(home, at: 0)
        self.setViewControllers(defaultVcs, animated: true)
//        print("update Tabbar = \(self.children)")
        self.updateiconIfNeeded()
        
    }
   
}
