//
//  TradeOrderArea.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/28.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXTradeDirectionSelector: EXDirectionSelector {
    override func config() {
        super.config()
        icon.image = EXKitBundle.image(named: "public_arrow_down")
        iconSize = CGSize(width: 10, height: 10)
        hideBorder()
        backgroundColor = .Ex.special2
        corneradius = 4
    }
}

class TradeOrderTypeSelector: EXTradeDirectionSelector {
    var tipsButton:UIButton!
    override func config() {
        super.config()
        tipsButton = UIButton(type: .custom)
        tipsButton.backgroundColor = .clear
        tipsButton.setImage(UIImage.themeImageNamed(imageName: "public_hint").reSizeImage(reSize: .init(width: 12, height: 12)), for: .normal)
        addSubview(tipsButton)
        tipsButton.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
        tipsButton.isHidden = true
        textAlignment = .center
    }
}


class TradeOrderArea :EXTradeAreaBase {

    var entrustEntity:EXCurrentEntrustArr = EXCurrentEntrustArr() {
        didSet {
            orderCommonArea.entrustEntity = entrustEntity
        }
    }//Current delegation

    lazy var orderBuyBtn:UIButton = {
        let btnBuy = UIButton.init(type: .custom)
        btnBuy.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btnBuy.setTitle("contract_action_buy".localized(), for: .normal)
        btnBuy.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btnBuy.setTitleColor(UIColor.white, for: .selected)
        btnBuy.setBackgroundImage(UIImage.themeImageNamed(imageName: "coins_exchange_buy_grey"), for: .normal)
        if EXKLineManager.isGreen() {
            btnBuy.setBackgroundImage(UIImage.themeImageNamed(imageName: "coins_exchange_buy_green"), for: .selected)
        }else {
            btnBuy.setBackgroundImage(UIImage.themeImageNamed(imageName: "coins_exchange_buy_red"), for: .selected)
        }
        btnBuy.addTarget(self, action: #selector(onOrderActionChanged(_:)), for: .touchUpInside)
        btnBuy.isSelected = true
        return btnBuy
    }()
    
    lazy var orderSellBtn:UIButton = {
        let btnSell = UIButton.init(type: .custom)
        btnSell.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btnSell.setTitle("contract_action_sell".localized(), for: .normal)
        btnSell.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btnSell.setTitleColor(UIColor.white, for: .selected)
        btnSell.isSelected = false
        btnSell.setBackgroundImage(UIImage.themeImageNamed(imageName: "coins_exchange_sell_grey"), for: .normal)
        if EXKLineManager.isGreen() {
            btnSell.setBackgroundImage(UIImage.themeImageNamed(imageName: "coins_exchange_sell_red"), for: .selected)
        }else {
            btnSell.setBackgroundImage(UIImage.themeImageNamed(imageName: "coins_exchange_sell_green"), for: .selected)
        }
        btnSell.addTarget(self, action: #selector(onOrderActionChanged(_:)), for: .touchUpInside)
        return btnSell
    }()
    
    lazy var orderCommonArea:TradeCommonOrderArea = {
        let common = TradeCommonOrderArea.init(entity: self.entity, orderType: self.orderType, layoutType: .vertical,action: .buy)
        return common
    }()
    
    //Market price limit button
    lazy var orderTypeBtn : TradeOrderTypeSelector = {
        let btn = TradeOrderTypeSelector()
        btn.titleLabel.text = "contract_action_limitPrice".localized()
        btn.addTarget(self, action: #selector(orderTyeBtnClick(sender:)), for: .touchUpInside)
        btn.tipsButton.addTarget(self, action: #selector(orderTypeTipsBtnClick(sender:)), for: .touchUpInside)
        return btn
    }()
    
    override func onCreate() {
        configOrderAreaUI()
        orderCommonArea.reloadFiedls()
    }

    func configOrderAreaUI() {
        
        let buyBtnHeight = 30
        let orderTypeHeight = 26
        //Buying and selling switch button
        self.addSubview(orderBuyBtn)
        self.addSubview(orderSellBtn)
        //Limit/Market Price
        self.addSubview(orderTypeBtn)
        self.addSubview(orderCommonArea)
        orderCommonArea.orderCreateBtn.addTarget(self, action: #selector(createBtnTapped), for: .touchUpInside)
        orderCommonArea.snp.makeConstraints { (make) in
            make.top.equalTo(orderTypeBtn.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(362)
            make.bottom.equalToSuperview()
        }
        
        orderBuyBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(buyBtnHeight)
            make.right.equalTo(orderSellBtn.snp.left)
            make.width.equalTo(orderSellBtn.snp.width)
        }
        
        orderSellBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(orderBuyBtn)
            make.left.equalTo(orderBuyBtn.snp.right)
            make.width.equalTo(orderSellBtn.snp.width)
        }
        
        orderTypeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(orderBuyBtn.snp.bottom).offset(12)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(orderTypeHeight)
        }
        
        orderCommonArea.heighCallBack = {[weak self] height in
            guard let self else { return }
            self.orderCommonArea.snp.updateConstraints { $0.height.equalTo(height) }
        }
    }
    
    override func onOrderWayChangend() {
        if self.orderWay == .limit {
            self.orderTypeBtn.titleLabel.text = "contract_action_limitPrice".localized()
            self.orderCommonArea.amountField.isHidden = false
            self.orderCommonArea.totalTitle.isHidden = false
            self.orderCommonArea.totalValue.isHidden = false
            self.orderCommonArea.rmbLabel.isHidden = false
            self.orderCommonArea.priceMask.isHidden = true
        }else if self.orderWay == .market {
            self.orderWay = .market
            self.orderTypeBtn.titleLabel.text = "contract_action_marketPrice".localized()
            self.orderCommonArea.amountField.isHidden = true
            self.orderCommonArea.totalTitle.isHidden = true
            self.orderCommonArea.totalValue.isHidden = true
            self.orderCommonArea.rmbLabel.isHidden = true
            self.orderCommonArea.priceMask.isHidden = false
        }
        orderCommonArea.orderWay = self.orderWay
        orderCommonArea.reloadFiedls()
    }
}

//MARK: Actions
extension TradeOrderArea {
    
    func reload(_ entity:CoinMapEntity) {
        self.entity = entity

        orderCommonArea.updateEntity(entity: entity)
    }
    
    @objc func onOrderActionChanged(_ sender:UIButton) {
        self.endEditing(true)
        if sender == orderBuyBtn {
            if orderBuyBtn.isSelected  {
                return
            }
            orderAction = .buy
            sender.isSelected = true
            orderSellBtn.isSelected = false
            
        }else if sender == orderSellBtn {
            if orderSellBtn.isSelected {
               return
            }
            orderAction = .sell
            sender.isSelected = true
            orderBuyBtn.isSelected = false
        }
        orderCommonArea.orderAction = self.orderAction
        orderCommonArea.configBtnTitle()
        orderCommonArea.reloadFiedls()
        orderCommonArea.caculateAvailableValue()
        orderCommonArea.caculateTradeVolume()
        self.clickOrderActionBlock?(self.orderAction)
    }
    
    @objc func createBtnTapped() {
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
        
        let element = OrderCreateElement.init(side: orderAction == .buy ? "BUY" : "SELL", type: orderWay == .limit ? "1" : "2", volume: orderCommonArea.volumeField.input.text ?? "0", price: orderWay == .limit ? orderCommonArea.priceField.input.text ?? "" : "0")
        onOrderCreateBlock?(element)
    }
    
    @objc func orderTyeBtnClick(sender:UIButton) {
        self.onOrderWayBlock?(sender)
    }
    @objc func orderTypeTipsBtnClick(sender:UIButton) {
        self.onOrderWayTipsBlock?(sender)
        EXAlert.showSheet(sheetView: EXOrderWayIntroAlertSheetView(orderWay: self.orderWay,orderAction: self.orderAction))
    }
}

//MARK: Caculations
extension TradeOrderArea {
 
}

