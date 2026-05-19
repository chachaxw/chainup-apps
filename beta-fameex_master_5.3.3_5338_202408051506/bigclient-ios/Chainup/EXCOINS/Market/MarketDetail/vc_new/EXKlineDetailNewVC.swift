//
//  EXKlineDetailNewVC.swift
//  Chainup
//
//  Created by youbin on 2023/6/14.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import Swap
class EXKlineDetailNewVC: BaseVC, NavigationPlugin {
    var sharebtn = UIButton()
    var collectBtn = UIButton()
    lazy var viewModel: EXKlineDetailNewViewModel = {
        let vm = EXKlineDetailNewViewModel()
        return vm
    }()
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil, presenter: self)
        return nav
    }()
    
    lazy var detailNewView: EXKlineDetailNewView = {
        let v = EXKlineDetailNewView(viewModel: self.viewModel)
        v.extUseAutoLayout()
        return v
    }()
    
    //Navigation Bar Section
    var customNaviItem = EXNaviDrawerView()
    var drawerHub:EXDrawerHub?
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        if EXThemeManager.isNight() == true || EXThemeManager.current == EXThemeManager.dayKlinenight {
            return .lightContent
        }else{
            return .default
        }
    }
    
    convenience init(entity: CoinMapEntity) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel.resetEntity(entity, .coin)
    }
 
    convenience init(entity: CoinMapEntity, kDetailType: KLineAccountType) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel.resetEntity(entity, kDetailType)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        bindViewModel()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.getHistoryKline()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.destorySocket()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: create UI
extension EXKlineDetailNewVC {
    
    func setupView() {
        view.backgroundColor = UIColor.ThemekLine.viewBg
        view.addSubview(detailNewView)
        detailNewView.snp.makeConstraints { make in
            make.top.equalTo(NAV_SCREEN_HEIGHT)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        handleNavigation()
    }
    
    func bindViewModel() {
        
        handleNotifi()
    }
    
}


//MARK: Navigation Bar Related Sections
extension EXKlineDetailNewVC {
    func handleNavigation() {
        navigation.isLastNavigationStyle = true
        navigation.backgroundColor = UIColor.ThemekLine.viewBg
        navigation.setdefaultType(type: .listtitle)
        navigation.popBtn.setImage(UIImage.exs_themeImageNamed(imageName:"public_return"), for: .normal)
        if self.viewModel.kDetailType == .coin || self.viewModel.kDetailType == .lever || self.viewModel.kDetailType == .quant {
            updateRightItems()
            navigation.rightItemCallback = { [weak self] tag in
                guard let `self` = self else { return }
                self.handleRightAction(tag)
            }
        }
        let custom = EXNaviDrawerView()
        custom.backgroundColor = UIColor.ThemekLine.viewBg
        custom.titleLabel.textColor = UIColor.ThemekLine.labcolorLite
        navigation.addSubview(custom)
        
        if let _entity = self.viewModel.entity {
            if self.viewModel.kDetailType == .lever {
                custom.bind(_entity.name.aliasCoinMapName() + " " + _entity.multiple + "X")
                custom.showTag(_entity.name)
            } else {
                custom.bind(_entity.name.aliasCoinMapName())
                custom.showTag(_entity.name)
            }
        }
        
        custom.tapBtn.addTarget(self, action: #selector(customBtnClick), for: .touchUpInside)
        custom.snp.makeConstraints { (make) in
            make.left.equalTo(navigation.popBtn.snp.right).offset(15)
            make.centerY.equalTo(navigation.popBtn)
            make.height.equalTo(38)
        }
        customNaviItem = custom
        configNavRigitItem()
    }
    
    
    
    func handleRightAction(_ tag : Int){
        if tag == 0{
            let view = EXSKlineShareView()
            view.vc = self
            if let img = self.view.screenShotwithFrame(CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)) {
                view.setImg(img)
                view.show()
            }
        }else if tag == 1{
            guard let _entity = self.viewModel.entity else { return }
            self.light()
            self.viewModel.userSymbolsVm.handleFavorite(actionType: self.isCollect() ? .singleDelete : .singleAdd ,
                                                        coinMaps: [_entity],
                                         callback:{[weak self] success in
                                            guard let `self` = self else {return}
                                            self.updateRightItems()
                                         })
        }
    }
    
    func configNavRigitItem(){
        self.navigation.configRightItems(["public_icon_share","public_favorites"])
        sharebtn = self.navigation.rightItems[1]
        collectBtn = self.navigation.rightItems[0]
       
        let shareImage = UIImage.exs_themeImageNamed(imageName: "public_icon_share")
        sharebtn.setImage(shareImage, for: .normal)
        sharebtn.setImage(shareImage, for: .highlighted)
       
        let selectedImag = UIImage.svg_themeImageNamed(imageName: "public_favorites")
        let notSelectedImag = UIImage.exs_themeImageNamed(imageName: "public_notfavorited")
        collectBtn.setImage(notSelectedImag, for: .normal)
        collectBtn.setImage(selectedImag, for: .selected)
        collectBtn.isSelected = self.isCollect()
    }
    func updateRightItems() {
         collectBtn.isSelected = self.isCollect()
    }
    
    func isCollect() ->Bool {
        var isCollect: Bool = false
        if let _entity = self.viewModel.entity {
            isCollect = XUserDefault.whetherCollectionCoinMap(_entity.symbol)
        }
        return isCollect
    }
    
    
    //MARK: Selection of currency in the navigation bar
    @objc func customBtnClick(){
        guard let _entity = self.viewModel.entity else { return }
        self.view.isUserInteractionEnabled = false
        let vc = EXDrawerVC()
        if self.drawerHub == nil {
            if self.viewModel.kDetailType == .coin{
                drawerHub = EXDrawerHub.init(type: .trade,symbol: _entity.symbol,fromKline: true)
            } else if self.viewModel.kDetailType == .quant {
                drawerHub = EXDrawerHub.init(type: .quant,symbol: _entity.symbol,fromKline: true)
            }else if self.viewModel.kDetailType == .lever {
                drawerHub = EXDrawerHub.init(type: .lever,symbol: _entity.symbol,fromKline: true)
            }
        }
        guard self.drawerHub != nil else { return }
        
        drawerHub?.symbol = _entity.symbol
        vc.addView(drawerHub!)
        vc.pullBlock = {[weak self] in
            self?.drawerHub?.cancelAllSubCoins()
            self?.view.isUserInteractionEnabled = true
            UIApplication.shared.keyWindow?.endEditing(true)
        }
        
        drawerHub?.clickCellBlock = {[weak self](entity) in
            guard let `self` = self else{return}
            self.reloadDetailWithCoinPairName(entity.name)
            vc.pullAnimation()
        }
        drawerHub?.reloadSubCoins()
    }
    
    
    //Coins - Optional Return
    func reloadDetailWithCoinPairName(_ name:String) {
        guard let _entity = self.viewModel.entity else { return }
        if _entity.name == name { return }
       
//        self.viewModel.hasLoadedAllKline = false
        let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(name)
        self.viewModel.resetEntity(entity)
    
        if self.viewModel.kDetailType == .lever {
            customNaviItem.bind(entity.name.aliasCoinMapName() + " " + entity.multiple + "X")
        }else {
            customNaviItem.bind(entity.name.aliasCoinMapName())
        }
        customNaviItem.showTag(entity.name)
        updateRightItems()
    }
}



//MARKL: NOTIFICATION
extension EXKlineDetailNewVC {
    
    func handleNotifi() {
        _ = NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .take(until: self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(false)
            })
        
        _ = NotificationCenter.default.rx
            .notification(UIApplication.willResignActiveNotification)
            .take(until: self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(true)
            })
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: NOTI_WS_RECONNECTED))
            .take(until: self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                guard let `self` = self else { return }
                self.viewModel.reconnectSocket()
            })
    }
    
    func homeBtnAction(_ enterBackground:Bool) {
        //Pay attention to the current controller
        guard let top = AppService.topViewController() else {return}
        if top == self {
            if enterBackground {
                self.viewModel.cancelSocket()
            }else {
                self.viewModel.reconnectSocket()
                getHistoriesKline()
            }
        }
    }
    
    func trackActionOn() {
       
//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(handleInterfaceData), object: nil)
//        self.perform(#selector(handleInterfaceData), with: nil, afterDelay: 3)
    }
    
    func getHistoriesKline() {
        trackActionOn()
    }
}

