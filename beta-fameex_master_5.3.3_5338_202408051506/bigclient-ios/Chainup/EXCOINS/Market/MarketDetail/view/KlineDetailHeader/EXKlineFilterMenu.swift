//
//  EXKlineFilterMenu.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/13.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import Swap
enum KLineFilterMenuAction {
    case changeScale//Change the timeline of the K line
    case moreScale //Show more timelines
    case switchDepth //Switch depth map
    case showIndex //Display indicators
    case zoom //Zoom in to landscape
}

typealias MenuActionCallback = (KLineFilterMenuAction, UIButton,String)->Void

class EXKlineFilterMenu: UIView {
    
    var actionCallback:MenuActionCallback?
    var menuScaleBtns:[UIButton] = [] //All K line timeline buttons
    var menuMoreBtns:[UIButton] = []  //More Timelines+Indicators, Expandable Filter Button
    var gap:CGFloat = 10
    var selectedBtn:UIButton?
    var menuModel:EXMenuSelectionModel = EXMenuSelectionModel()
    let insetMargin:CGFloat = 5// ((UIDevice.current.screenType == UIDevice.ScreenType.iPhones_5_5s_5c_SE) ? 4 : 10)
    var isSwap = false
    //Indicator button
    lazy var indexMenu:EXTriangleIndicator = {
        let menu = EXTriangleIndicator.init()
        menu.backgroundColor = UIColor.ThemekLine.viewBg
        menu.setTitleColor(UIColor.ThemekLine.labcolorMedium, for: .normal)
        menu.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .selected)
        menu.setTitle(content: "kline_text_scale".localized())
        menu.addTarget(self, action: #selector(btnSelcted(sender:)), for: .touchUpInside)
        menu.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetMargin, bottom: 0, right: insetMargin + 10)
        return menu
    }()
    
    //More buttons
    lazy var moreMenu:EXTriangleIndicator = {
        let menu = EXTriangleIndicator.init()
        menu.backgroundColor = UIColor.ThemekLine.viewBg
        menu.setTitleColor(UIColor.ThemekLine.labcolorMedium, for: .normal)
        menu.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .selected)
        menu.addTarget(self, action: #selector(btnSelcted(sender:)), for: .touchUpInside)
        menu.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetMargin, bottom: 0, right: insetMargin+10)
        return menu
    }()
    
    //Depth button
    lazy var depthMenu:UIButton = {
        let menu = UIButton.init(type: .custom)
        menu.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
        menu.setTitle("kline_action_depth".localized(), for: .normal)
        menu.setTitleColor(UIColor.ThemekLine.labcolorMedium, for: .normal)
        menu.setTitleColor(UIColor.ThemekLine.labcolorHighlight, for: .selected)
        menu.addTarget(self, action: #selector(btnSelcted(sender:)), for: .touchUpInside)
        menu.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetMargin, bottom: 0, right: insetMargin)
        return menu
    }()
    
    //Landscape button
    lazy var scaleBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.addTarget(self, action: #selector(zoomAction(sender:)), for: .touchUpInside)
        btn.setBackgroundImage(UIImage.exs_themeImageNamed(imageName:"public_fullscreen"), for: .normal)
//        btn.setImage(UIImage.themeImageNamed(imageName:"quotes_zoom"), for: .normal)
        return btn
    }()
    
    
    lazy var indicator:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemekLine.viewHighlight
        view.layer.cornerRadius = 1
        return view
    }()
    
    lazy var bg:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemekLine.viewBg
        return view
    }()
    
    lazy var bottomLine:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemekLine.viewSeperator
        return view
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemekLine.viewBg
        
        
    }
    
    lazy var titleMenuContainer:UIStackView = {
        let titleMenu = UIStackView.init()
        titleMenu.axis = .horizontal
        titleMenu.backgroundColor = UIColor.ThemekLine.viewBg
        return titleMenu
    }()

    
    func caculateGap() {
        //Width of the right button, indicator+depth map
        var rightViewWidth:CGFloat = 0
        
        var depth = "kline_action_depth".localized()
        var scale = "kline_text_scale".localized()
        
        rightViewWidth += depth.textSizeWithFont(UIFont.ThemeFont.SecondaryRegular, width: CGFloat.greatestFiniteMagnitude).width
        rightViewWidth += scale.textSizeWithFont(UIFont.ThemeFont.SecondaryRegular, width: CGFloat.greatestFiniteMagnitude).width
        rightViewWidth += insetMargin*4 + 10 //Inset and metric buttons for depth and metric buttons
        rightViewWidth += 5 //5 of the right margin
        
        //The width of the left button
        let leftWidth = SCREEN_WIDTH - rightViewWidth
        var btnWidth:CGFloat = 8 //Fixed 10 reserved for more buttons
        for scale in scalses() {
            btnWidth += scale.localized().textSizeWithFont(UIFont.ThemeFont.SecondaryRegular, width: CGFloat.greatestFiniteMagnitude).width
        }
        let allgapWidth = leftWidth - btnWidth
        if allgapWidth <= 0 {
            self.gap = 0
        }else {
            let result = allgapWidth/6
            self.gap = result > 20 ? 20 : result
        }
    }
    
    func configMenus() {
        caculateGap()
        addSubview(bg)
        bg.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        if isSwap {
            addSubview(scaleBtn)
            scaleBtn.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(13)
            }
        }
        addSubview(titleMenuContainer)
        addSubview(indexMenu)
        addSubview(depthMenu)
        addSubview(indicator)
        addSubview(bottomLine)
        
        bottomLine.snp.makeConstraints { (make) in
            make.height.equalTo(1/UIScreen.main.scale)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(0)
        }

        indicator.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.width.equalTo(20)
            make.bottom.equalToSuperview()
            make.centerX.equalTo(0)
        }
        
        titleMenuContainer.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        if isSwap {
            indexMenu.snp.makeConstraints { (make) in
                make.right.equalTo(scaleBtn.snp.left).offset(-5)
                make.height.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }else{
            indexMenu.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-5)
                make.height.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }
        
        
        depthMenu.snp.makeConstraints { (make) in
            make.right.equalTo(indexMenu.snp.left)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
//        if isSwap{
//            UserDefaults.standard.set(nil, forKey: klineScaleKey)
////            if let scaleKey = df.string(forKey: klineScaleKey)
//        }
        let showMoreTitle = "common_action_showMore".localized()
//        if !scalses().contains(menuModel.scaleKey) {
//            showMoreTitle = menuModel.scaleKey
//        }
//        let others = EXAppConfigManager.sharedInstance.getOtherKlineScale()
//        if !others.contains(menuModel.scaleKey) { //If the bottom also does not include this item
//            menuModel.scaleKey = "15min"
//        }
        menuScaleBtns.removeAll()
        for (idx,scale) in scalses().enumerated() {
            let btnTitle = EXAppConfigManager.sharedInstance.getkeyTitle(scale: scale, isSwap: false)
            if scale == showMoreTitle {
                moreMenu.setTitle(content: showMoreTitle)
                titleMenuContainer.addArrangedSubview(moreMenu)
                menuMoreBtns.append(moreMenu)
            }else {
                let btn:UIButton = UIButton.init(type: .custom)
                btn.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
                btn.setTitle(btnTitle, for: .normal)
                btn.tag = idx
                btn.setTitleColor(UIColor.ThemekLine.labcolorMedium, for: .normal)
                btn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .selected)
                btn.addTarget(self, action: #selector(btnSelcted(sender:)), for: .touchUpInside)
                btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: self.gap/2, bottom: 0, right: self.gap/2)
                titleMenuContainer.addArrangedSubview(btn)
                menuScaleBtns.append(btn)
            }
        }
        menuScaleBtns.append(depthMenu)
        menuMoreBtns.append(indexMenu)
        self.selectDefaultScaleType(type: menuModel.scaleKey)
        
    }
    
    func selectDefaultScaleType(type:String) {
        let convenienceScales = EXAppConfigManager.sharedInstance.getConvenienceKlineScale(isSwap: self.isSwap)
        
        for btn in menuScaleBtns {
            btn.isSelected = false
        }
    
        if let dftIdx = convenienceScales.firstIndex(of: type),dftIdx < menuScaleBtns.count {
            let btn = menuScaleBtns[dftIdx]
            btn.isSelected = true
            self.selectedBtn = btn
        }else {
            moreMenu.isSelected = true
            let btnTitle = EXAppConfigManager.sharedInstance.getkeyTitle(scale: type, isSwap: self.isSwap)
            moreMenu.setTitle(content: btnTitle)
            self.selectedBtn = moreMenu
        }
        self.configIndicator(sender: self.selectedBtn!)
    }
    
    func scalses() -> [String] {
        var convenienceScales = EXAppConfigManager.sharedInstance.getConvenienceKlineScale(isSwap: self.isSwap)
      //  swapMenuArray(array: &convenienceScales)
        let showMoreTitle = "common_action_showMore".localized()
        convenienceScales.append(showMoreTitle)
        return convenienceScales
    }
    
    func configIndicator(sender:UIButton) {
        layoutIfNeeded()
        var offset:CGFloat = 5
        if sender == indexMenu || sender == depthMenu {
            offset = 0
        }
        var btnRect = sender.frame
        let labelRect = sender.titleLabel!.frame
        let centerX = btnRect.minX + labelRect.minX + offset
        let labelWidth = sender.titleLabel?.text?.textSizeWithFont(UIFont.ThemeFont.SecondaryRegular, width: CGFloat.greatestFiniteMagnitude).width
        UIView.animate(withDuration: 0.25) {
            self.indicator.snp.remakeConstraints({ make in
                make.height.equalTo(2)
                make.width.equalTo(labelWidth ?? labelRect.width)
                make.bottom.equalToSuperview()
                make.left.equalTo(centerX)
            })
            self.layoutIfNeeded()
        }
    }
    
    @objc func btnSelcted(sender:UIButton) {
        
        if sender == moreMenu {
            self.actionCallback?(.moreScale,sender,"")
            sender.isSelected = !sender.isSelected
            indexMenu.isSelected = false
        }else if sender == indexMenu {
            self.actionCallback?(.showIndex,sender,"")
            sender.isSelected = !sender.isSelected
            if self.selectedBtn != moreMenu {
                moreMenu.isSelected = false
            }
        } else {
            resetMoreMenuIfNeeded()
            configIndicator(sender: sender)
            if sender == self.selectedBtn {
                return
            }
            for menu in menuScaleBtns {
                menu.isSelected = (menu == sender)
            }
            for menu in menuMoreBtns {
                menu.isSelected = false
            }
            if sender == depthMenu {
                self.actionCallback?(.switchDepth,sender,"")
            }else {
                self.actionCallback?(.changeScale,sender,scalses()[sender.tag])
            }
            self.selectedBtn = sender
        }
    }
    
    @objc func zoomAction(sender:UIButton) {
        self.actionCallback?(.zoom,sender,"")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
}

extension EXKlineFilterMenu {
    
    func resetMoreMenuIfNeeded() {
        let showMoreTitle = "common_action_showMore".localized()
        self.moreMenu.setTitle(content: showMoreTitle)
    }
    
    func moreMenuSelected(key:String) {
        for menu in menuScaleBtns {
            menu.isSelected = false
        }
        self.selectDefaultScaleType(type: key)
    }
}

extension EXKlineFilterMenu {
    //Details of new contract market
    func updateSwapLoad(){
        isSwap = true
/*Contract copy*/
        configMenus()
    }
    func swapMenuArray( array:inout [String]) {
        if isSwap {
            array = ["15min", "60min","4h", "1day"]
        }
    }
    
}


