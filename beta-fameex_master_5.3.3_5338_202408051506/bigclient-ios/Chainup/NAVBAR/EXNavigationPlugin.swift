//
//  EXNavigationPlugin.swift
//  Chainup
//
//  Created by liuxuan on 2020/3/25.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
import JXSegmentedView

// 自定义navbar协议
@objc protocol NavigationPlugin {
    var navigation: EXNavigation { get }
    @objc optional func largeTitleValueChanged(height:CGFloat)
}


class EXNavigation: NavCustomView {
    var style:Int = 0
    var scroll:UIScrollView?
    weak var presenter: (UIViewController & NavigationPlugin)!
    var largeTitleStyle :Bool = true
    var customBack :Bool = false
    var fullHeight:CGFloat = NAV_SCREEN_HEIGHT + 62
    var rightItems:[UIButton] = []
    var rightItemCallback:((Int)->())?
    var customBackCallback:(()->())?

    var filter:EXFilterView?
    
    var badgeViews = [Int:UIView]()
    
    var isLastNavigationStyle:Bool = false {
        didSet {
            self.backView.backgroundColor = isLastNavigationStyle ? UIColor.ThemeView.bg : UIColor.ThemeNav.bg
        }
    }

    private var _navtype = NavType.normal
    var navtype : NavType {
        get { _navtype }
        set {
            let navtype:NavType = (newValue == .list) ? .listtitle : newValue
            switch navtype {
            case .list:
                self.snp.remakeConstraints { (make) in
                    make.top.left.right.equalToSuperview()
                    make.height.equalTo(fullHeight)
                }
                self.middleTitle.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.popBtn.snp.bottom).offset(24)
                    make.height.equalTo(33)
                    make.left.equalToSuperview().offset(15)
                    make.width.lessThanOrEqualTo(SCREEN_WIDTH - 100)
                }
                self.presenter.largeTitleValueChanged?(height:NAV_SCREEN_HEIGHT + 62 )
                self.middleTitle.font = UIFont.ThemeFont.H1Bold
            case .listtitle:
                self.middleTitle.snp.remakeConstraints { (make) in
                    make.centerY.equalTo(self.popBtn)
                    make.height.equalTo(33)
                    make.centerX.equalToSuperview()
                    make.width.lessThanOrEqualTo(SCREEN_WIDTH - 100)
                }
                self.snp.remakeConstraints { (make) in
                    make.top.left.right.equalToSuperview()
                    make.height.equalTo(NAV_SCREEN_HEIGHT)
                }
                self.presenter.largeTitleValueChanged?(height:NAV_SCREEN_HEIGHT )
                self.middleTitle.font = UIFont.ThemeFont.H3Bold
            case .notitle:
                self.self.middleTitle.isHidden = true
            case .nopopback:
                self.middleTitle.snp.remakeConstraints { (make) in
                    make.centerY.equalTo(self.popBtn)
                    make.height.equalTo(33)
                    make.left.equalToSuperview().offset(15)
                    make.width.lessThanOrEqualTo(SCREEN_WIDTH - 100)
                }
                self.self.popBtn.isHidden = true
            default:
                break
            }
        }
    }
    
    required init(style:Int = 0,
                  title:String = "",
                  font:CGFloat = 18.0,
                  color:UIColor = UIColor.ThemeLabel.colorLite,
                  affectScroll:UIScrollView?,
                  presenter: (UIViewController & NavigationPlugin)!,
                  useLargeTitleNavigation:Bool = true,
                  customHandleBack:Bool = false) {
        
        super.init(frame: CGRect.zero)
        self.style = style
        self.scroll = affectScroll
        self.largeTitleStyle = useLargeTitleNavigation
        customBack = customHandleBack
        self.middleTitle.extSetText(title, textColor: color, fontSize: font)
        self.presenter = presenter
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func config() {
        self.clickPopBtnBlock = {[weak self] () in
            guard let mySelf = self else{return}
            mySelf.back()
        }
        
//        if let effectsScroll = scroll  {
//            effectsScroll.rx.contentOffset
//                .subscribe(onNext: { [weak self] point  in
//                    guard let mySelf = self else{return}
//                    let y = point.y
////                    print(y)
//                    if mySelf.navtype == .list{
//                        if y > 0{
//                            mySelf.navtype = .listtitle
//                        }
//                    }else if mySelf.navtype == .listtitle{
//                        if y < 0{
//                            mySelf.navtype = .list
//                        }
//                    }
//                }).disposed(by: self.disposeBag)
//        }
        presenter.view.addSubview(self)
        self.navtype = .listtitle
    }
    
    func setdefaultType(type:NavType){
        self.navtype = type
    }
    
    func setTitle(title:String) {
        self.middleTitle.text = title
    }
    
    func setCustomView(_ customView:UIView) {
        self.setdefaultType(type: .nopopback)
        self.setTitle(title: "")
        self.backView.addSubview(customView)
        customView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func configRightItems(_ itemtitles:[String],
                          isImageName:Bool = true,
                          btnColor:UIColor = UIColor.ThemeLabel.colorMedium,
                          isKline:Bool = false) {
        for item in rightItems {
            item.removeFromSuperview()
        }
        var lastRightBtn:UIButton?
        for (idx,itemtitle) in itemtitles.enumerated().reversed() {
            let btn = UIButton.init(type: .custom)
            if isImageName {
                btn.setImage(UIImage.themeImageNamed(imageName: itemtitle,kline: isKline), for: .normal)
                btn.setImage(UIImage.themeImageNamed(imageName: itemtitle,kline: isKline), for: .highlighted)
            }else {
                btn.titleLabel?.textAlignment = .right
                btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
                btn.setTitleColor(btnColor, for: .normal)
                btn.setTitle(itemtitle, for: .normal)
            }
            btn.tag = idx
            btn.addTarget(self, action: #selector(onRightItemClicked(sender:)), for: .touchUpInside)
            self.addSubview(btn)
            rightItems.append(btn)
            
            var width:CGFloat = 0
            
            if isImageName {
                width = 38
                btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
            }else {
                width = itemtitle.textSizeWithFont(UIFont.ThemeFont.BodyMedium, width: CGFloat.greatestFiniteMagnitude).width + 5
            }
            
            if let lastOne = lastRightBtn {
                btn.snp.makeConstraints { (make) in
                    make.centerY.equalTo(lastOne.snp.centerY)
                    make.width.equalTo(width)
                    make.height.equalTo(38)
                    make.right.equalTo(lastOne.snp.left)
                }
            }else {
                btn.snp.makeConstraints { (make) in
                    make.centerY.equalTo(popBtn.snp.centerY)
                    make.width.equalTo(width)
                    make.height.equalTo(38)
                    make.right.equalToSuperview().offset(isImageName ? 0 : -12)
                }
            }
            lastRightBtn = btn
        }
    }
    
    /// 目前仅保证图片类型button在c2c交易页面的样式正确
    func addBadge(for index:Int, color:UIColor) {
        if self.rightItems.count <= index || index < 0 {
            return
        }
        self.removeBadge(for: index)
        //
        let button = self.rightItems[index]
        button.layoutIfNeeded()
        var contentRect = CGRect.zero
        if let imageView = button.imageView, !imageView.isHidden {
            contentRect = imageView.frame
        }else if let label = button.titleLabel, !label.isHidden {
            #if DEBUG
            assert(false, "文字类型暂未测试，请注意自测")
            #endif
            contentRect = label.frame
        }else {
            return
        }
        let badgeSize = CGSize(width: 7, height: 7)
        
        let badge = UIView()
        let x = contentRect.maxX
        let y = max(2, contentRect.minY - badgeSize.height)
        badge.frame = CGRect(x: x, y: y, width: badgeSize.width, height: badgeSize.height)
        badge.backgroundColor = color
        badge.layer.cornerRadius = badgeSize.width / 2
        button.addSubview(badge)
        badgeViews[index] = badge
    }
    func removeBadge(for index:Int) {
        guard let badge = badgeViews[index] else { return }
        badge.removeFromSuperview()
        badgeViews[index] = nil
    }
    
    @objc func onRightItemClicked(sender:UIButton) {
        self.rightItemCallback?(sender.tag)
    }
    
    func bindFilter(filter:EXFilterView) {
        self.filter = filter
    }
    
    func setScanClearNavi() {
        self.backgroundColor = UIColor.clear
        self.backView.backgroundColor = UIColor.clear
        self.popBtn.setImage(nil, for: .normal)
        self.popBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
        self.popBtn.setTitleColor(UIColor.ThemeLabel.white, for: .normal)
        popBtn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        popBtn.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(34 + NAV_TOP)
            make.height.equalTo(16)
        }
        for btn in rightItems {
            btn.setTitleColor(UIColor.ThemeLabel.white, for: .normal)
        }
    }
    
    func updateLeftBtn(title:String = "",icon:String = "",titleColor:UIColor = UIColor.ThemeLabel.colorLite) {
        if title.count > 0 {
            self.popBtn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
            self.popBtn.setImage(nil, for: .normal)
            self.popBtn.setTitle(title, for: .normal)
            self.popBtn.setTitleColor(titleColor, for: .normal)
            popBtn.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(15)
                make.top.equalToSuperview().offset(34 + NAV_TOP)
                make.height.equalTo(16)
            }
        }else if icon.count > 0 {
            self.popBtn.setTitle("", for: .normal)
            self.popBtn.setImage(UIImage.themeImageNamed(imageName: icon), for: .normal)
            popBtn.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(15)
                make.top.equalToSuperview().offset(34 + NAV_TOP)
            }
        }
    }
    
    func showLeftBtn() {
        self.popBtn.isHidden = false
    }
    
    func hideLeftBtn() {
        self.popBtn.isHidden = true
    }
    
    func hideRightItems() {
        for btn in rightItems {
            btn.isHidden = true
        }
    }
    
    func showRightBtnItems() {
        for btn in rightItems {
            btn.isHidden = false
        }
    }
    
    func back(){
        self.filter?.dismissFilter()
        if customBack {
            //self.presenter = nil
            customBackCallback?()
            return
        }
        self.removeFromSuperview()
        presenter.navigationController?.popViewController(animated: true)
        //self.presenter = nil
    }
}

enum HubNavType {
    case trade //币币交易
    case lever //杠杆交易
    case fiat //法币交易
    case quant //网格交易
}

extension HubNavType : CustomStringConvertible {
    var description: String {
        switch self {
            case .trade: return "mainTab_text_transaction".localized()
            case .quant: return "quant_grid_title".localized()
            case .lever: return "contract_action_lever".localized()
            case .fiat: return "mainTab_text_otc".localized()
        }
    }
}

// 自定义navbar协议
@objc protocol HubNavigationPlugin {
    var navigation: EXHubNavigation { get }
    @objc optional func menuBarValueChanged(height:CGFloat)
}

let tradeHubSegmentHeight:CGFloat = 28

class EXHubNavigation:NavCustomView {
    weak var presenter: (UIViewController & HubNavigationPlugin)!
    var hubType:HubNavType = .trade
    var coinMapNavi = EXTradeHeaderView()
    var titleBarBg  = UIView()
    private(set) var visibleHeight:CGFloat = 0
    lazy var menubarDataSource: JXSegmentedDotDataSource = {
        let dataSource = JXSegmentedDotDataSource()
        dataSource.itemWidth = ((Device_W - 36) / CGFloat(segmentTypes.count)).rounded(.towardZero)
        dataSource.titles = segmentTypes.map({ $0.description })
        dataSource.isTitleMaskEnabled = true
        dataSource.itemSpacing = 0
        dataSource.titleNormalFont = .Ex.medium(14)
        dataSource.titleNormalColor = .Ex.text2
        dataSource.titleSelectedColor = .Ex.text1
        dataSource.dotStates = segmentTypes.map({ _ in false })
        dataSource.dotSize = CGSize(width: 7, height: 7)
        dataSource.dotOffset = CGPoint(x: 3.5, y: 0)
        return dataSource
    }()
    //
    lazy var menubar: JXSegmentedView = {
        ///
        let indicator = JXSegmentedIndicatorBackgroundView()
        indicator.indicatorHeight = 23
        indicator.indicatorWidthIncrement = -1
        indicator.indicatorCornerRadius = 4
        indicator.indicatorColor = .Ex.fill3
        ///
        let menubar = JXSegmentedView()
        menubar.indicators = [indicator]
        menubar.delegate = self
        menubar.dataSource = menubarDataSource
        menubar.contentEdgeInsetLeft = 2
        menubar.contentEdgeInsetRight = 2
        menubar.layer.borderWidth = 1
        menubar.layer.borderColor = UIColor.Ex.fill3.cgColor
        menubar.layer.cornerRadius = 4
        menubar.layer.masksToBounds = true
        return menubar
    }()
    
    var onSegmentCallback:((Int)->())?
    lazy var segmentTypes: [HubNavType] = {
        var types:[HubNavType] = [.trade]
        if EXAppConfigManager.sharedInstance.didOpenQuant() {
            types.append(.quant)
        }
        if EXAppConfigManager.sharedInstance.didOpenLever() {
            types.append(.lever)
        }
        if EXAppConfigManager.sharedInstance.didOpenFiat() {
            types.append(.fiat)
        }
        return types
    }()
    var currentIdx:Int = 0
    
    lazy var naviContainer:UIStackView = {
        let container = UIStackView()
        container.axis = .vertical
        return container
    }()
    
    lazy var bottomLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .Ex.fill4
        return lineView
    }()
    
    required init(presenter: (UIViewController & HubNavigationPlugin)!,
                  type:HubNavType,
                  coinMapSymbol:String) {
        super.init(frame: CGRect.zero)
        self.popBtn.isHidden = true
        self.presenter = presenter
        self.hubType = type
        config()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func configTitles() {
        titleBarBg.addSubview(menubar)
        menubar.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(tradeHubSegmentHeight)
            make.center.equalToSuperview()
        }
        backgroundColor = .Ex.fill1
        backView.backgroundColor = .clear
        naviContainer.addArrangedSubview(titleBarBg)
    }
    
    func config() {
        presenter.view.addSubview(self)
        self.addSubview(naviContainer)
        naviContainer.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        if segmentTypes.count > 1 {
            self.presenter.menuBarValueChanged?(height: EXNavBarHeight + 44)
            configTitles()

            naviContainer.addArrangedSubview(coinMapNavi)
            titleBarBg.snp.makeConstraints { (make) in
                make.height.equalTo(44)
            }
            coinMapNavi.snp.makeConstraints { (make) in
                make.height.equalTo(44)
            }
            //262 88 + 43
            updateVisibleHeight(height: EXNavBarHeight + 44)
        }else {
            //88
            self.presenter.menuBarValueChanged?(height: EXNavBarHeight)
            coinMapNavi.snp.makeConstraints { (make) in
                make.height.equalTo(44)
            }
            naviContainer.addArrangedSubview(coinMapNavi)
            updateVisibleHeight(height: EXNavBarHeight)
        }
        //
        addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func updateCoinMap(entity:CoinMapEntity,tick:TickItem?) {
        if self.hubType == .trade {
            coinMapNavi.bindMenu(name: entity.name.aliasCoinMapName(), tag:"", rate: tick)
        }else if self.hubType == .lever {
            coinMapNavi.bindMenu(name: entity.name.aliasCoinMapName() + " " + entity.multiple + "X" , tag:"", rate: tick)
        }else if self.hubType == .quant {
            coinMapNavi.bindMenu(name: entity.name.aliasCoinMapName(), tag:"", rate: tick)
        }
    }
    
    func hide() {
            self.titleBarBg.alpha = 0
            updateVisibleHeight(height: EXNavBarHeight)
    }
    
    func show() {
            self.titleBarBg.alpha = 1
            updateVisibleHeight(height: EXNavBarHeight + 44)
    }
    func updateVisibleHeight(height:CGFloat) {
        visibleHeight = height
        self.snp.remakeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(visibleHeight)
        }
    }
    
    func addBadge(for navType:HubNavType, color:UIColor) {
        guard let index = segmentTypes.firstIndex(of: navType) else { return }
        menubarDataSource.dotStates[index] = true
        menubar.reloadData()
    }
    func removeBadge(for navType:HubNavType) {
        guard let index = segmentTypes.firstIndex(of: navType) else { return }
        menubarDataSource.dotStates[index] = false
        menubar.reloadData()
    }
}

extension EXHubNavigation:JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt selectedIndex: Int) {
        if segmentTypes.count > selectedIndex {
            let type = segmentTypes[selectedIndex]
            if type == .lever {
                if !UserDefaults.standard.bool(forKey: "EXLeverageAlertView") && EXAppConfigManager.sharedInstance.getLeverProtocolURL().count > 0 {
                    let alertView = EXLeverageAlertView.show()
                    alertView?.confirmBlock = { [weak self] in
                        guard let `self` = self else { return }
                        self.changeIdx(idx: selectedIndex)
                    }
                    alertView?.cancleBlock = { [weak self] in
                        guard let `self` = self else { return }
                        self.menubar.selectItemAt(index: self.currentIdx)
                    }
                    return
                }else {
                    changeIdx(idx: selectedIndex)
                }
            }else {
                changeIdx(idx: selectedIndex)
            }
        }
    }
    
    func changeIdx(idx:Int) {
        currentIdx = idx
        menubar.selectItemAt(index: idx)
        self.onSegmentCallback?(idx)
    }
    
    
}

