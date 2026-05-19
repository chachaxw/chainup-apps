//
//  TradeOrderAreaH.swift
//  Chainup
//
//  Created by 劉軒 on 2023/10/31.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import JXSegmentedView


class TradeOrderAreaH: EXTradeAreaBase {
    
    var entrustEntity:EXCurrentEntrustArr = EXCurrentEntrustArr() {
        didSet {
            orderBuyArea.entrustEntity = entrustEntity
            orderSellArea.entrustEntity = entrustEntity
        }
    }//Current delegation
    
    
    var transferBlock: EXComVoidBlock?
    
    let orderwayTypes:[EXTradeOrderWay] = [.limit, .market]
    
    lazy var menubarDataSource: JXSegmentedTitleDataSource = {
        let d = JXSegmentedTitleDataSource()
        d.titleNormalFont = .Ex.medium(14)
        d.titleSelectedFont = .Ex.medium(14)
        d.titleNormalColor = .Ex.text2
        d.titleSelectedColor = .Ex.text1
        d.isItemSpacingAverageEnabled = false
        d.itemWidthIncrement = 8
        d.itemSpacing = 16
        d.titles = orderwayTypes.map( { $0.description })
        return d
    }()
    //
  
    lazy var menubar: JXSegmentedView = {
        let v = JXSegmentedView()
        v.contentEdgeInsetLeft = 0
        v.dataSource = menubarDataSource
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 22
        indicator.indicatorColor = .Ex.main1
        indicator.indicatorHeight = 4
        indicator.indicatorCornerRadius = 0
        indicator.indicatorPosition = .bottom
        v.indicators = [indicator]
        v.delegate = self
        return v
    }()
    
    lazy var separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill4
        return v
    }()
    
    lazy var orderBuyArea :TradeCommonOrderArea = {
        let common = TradeCommonOrderArea.init(entity: self.entity, orderType: self.orderType, layoutType: .horizontal,action:.buy)
        common.transferBlock = {[weak self] in
            guard let self else { return }
            self.transferBlock?()
        }
        return common
    }()
    
    lazy var orderSellArea :TradeCommonOrderArea = {
        let common = TradeCommonOrderArea.init(entity: self.entity, orderType: self.orderType, layoutType: .horizontal,action:.sell)
        common.transferBlock = {[weak self] in
            guard let self else { return }
            self.transferBlock?()
        }
        return common
    }()
    
    lazy var loginBtn:EXButton = {
        let v = EXButton(type: .custom)
        v.titleLabel?.font = .Ex.medium(14)
        v.setTitle("login_action_login".localized(), for: .normal)
        v.addTarget(self, action: #selector(login), for: .touchUpInside)
        return v
    }()
    
    func configOrderBtn() {
        loginBtn.isHidden = !XUserDefault.isOffLine()
        orderBuyArea.configBtnTitle()
        orderSellArea.configBtnTitle()
    }
    
    override func onCreate() {
        orderBuyArea.orderCreateBtn.addTarget(self, action: #selector(createBtnTapped(sender:)), for: .touchUpInside)
        orderSellArea.orderCreateBtn.addTarget(self, action: #selector(createBtnTapped(sender:)), for: .touchUpInside)
        configOrderBtn()
        ///
        addSubViews([menubar, separatorView, orderBuyArea, orderSellArea, loginBtn])
        ///
        menubar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(43)
        }
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(menubar.snp.bottom).offset(0.5)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        orderBuyArea.snp.makeConstraints { (make) in
            make.top.equalTo(separatorView.snp.bottom).offset(12)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            
        }
        orderSellArea.snp.makeConstraints { (make) in
            make.left.equalTo(orderBuyArea.snp.right).offset(8)
            make.right.equalToSuperview()
            make.width.height.centerY.equalTo(orderBuyArea)
        }

        loginBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        orderBuyArea.reloadFiedls()
        orderSellArea.reloadFiedls()
       
   
    }
    
    override func onOrderWayChangend() {
        super.onOrderWayChangend()
        if self.orderWay == .limit {
            self.orderBuyArea.priceMask.isHidden = true
            self.orderSellArea.priceMask.isHidden = true
            self.orderBuyArea.totalTitle.isHidden = false
            self.orderBuyArea.totalValue.isHidden = false
            self.orderSellArea.totalTitle.isHidden = false
            self.orderSellArea.totalValue.isHidden = false
            self.orderBuyArea.rmbLabel.isHidden = false
            self.orderSellArea.rmbLabel.isHidden = false
            
            self.orderBuyArea.amountField.isHidden = false
            self.orderSellArea.amountField.isHidden = false
            
        }else if self.orderWay == .market {
            self.orderBuyArea.priceMask.isHidden = false
            self.orderSellArea.priceMask.isHidden = false
            self.orderBuyArea.totalTitle.isHidden = true
            self.orderBuyArea.totalValue.isHidden = true
            self.orderSellArea.totalTitle.isHidden = true
            self.orderSellArea.totalValue.isHidden = true
            self.orderBuyArea.rmbLabel.isHidden = true
            self.orderSellArea.rmbLabel.isHidden = true
            
            self.orderBuyArea.amountField.isHidden = true
            self.orderSellArea.amountField.isHidden = true
        }
        orderBuyArea.orderWay  = self.orderWay
        orderSellArea.orderWay = self.orderWay
        orderBuyArea.reloadFiedls()
        orderSellArea.reloadFiedls()
        if let index = orderwayTypes.firstIndex(of: orderWay) {
            menubar.selectItemAt(index: index)
        }
    }
    
}


extension TradeOrderAreaH : JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        onOrderWayChangedBlock?(orderwayTypes[index])
    }
    func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
        return segmentedView.selectedIndex != index
    }
}

//MARK: Actions

extension TradeOrderAreaH {
    
    func reload(_ entity:CoinMapEntity) {
        self.entity = entity
        orderBuyArea.updateEntity(entity: entity)
        orderSellArea.updateEntity(entity: entity)
    }
    
    @objc func createBtnTapped(sender:UIButton) {
        if XUserDefault.isOffLine() {
            BusinessTools.modalLoginVC()
            return
        }
        if orderType == .leverage {
            if EXAppConfigManager.sharedInstance.getKycConfigModel("4"){
                if EXOTCSafetyCheckVm.manager.checkKycRequire(self.yy_viewController ?? UIViewController(), type: "1") == false{
                        return
                }
            }
        }else {
            if EXAppConfigManager.sharedInstance.getKycConfigModel("3"){
                if EXOTCSafetyCheckVm.manager.checkKycRequire(self.yy_viewController ?? UIViewController(), type: "1") == false{
                        return
                }
            }
        }
        var actionElement:OrderCreateElement?
        if sender == orderBuyArea.orderCreateBtn {
            actionElement = OrderCreateElement.init(side:"BUY", type: orderWay == .limit ? "1" : "2", volume: orderBuyArea.volumeField.input.text ?? "0", price: orderWay == .limit ? orderBuyArea.priceField.input.text ?? "" : "0")
        }else if sender == orderSellArea.orderCreateBtn {
            actionElement = OrderCreateElement.init(side:"SELL", type: orderWay == .limit ? "1" : "2", volume: orderSellArea.volumeField.input.text ?? "0", price: orderWay == .limit ? orderSellArea.priceField.input.text ?? "" : "0")
        }
        guard let element = actionElement else {return}
        onOrderCreateBlock?(element)
    }
    
    @objc func login() {
        BusinessTools.modalLoginVC()
    }
    
 
}

