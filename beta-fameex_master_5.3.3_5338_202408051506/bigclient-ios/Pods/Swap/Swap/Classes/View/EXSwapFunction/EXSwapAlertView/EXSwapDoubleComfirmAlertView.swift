//
//  EXSwapDoubleComfirmAlertView.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/1/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

//Opening secondary confirmation box
class EXSwapDoubleComfirmAlertView: UIView {
    

    var confirmCallback: (() -> ())?
    var confimModelCallBack:(() -> ())?
    
    var currentModel:EXContractOrderModel?
    
    lazy var typeLabel: UILabel = UILabel(text: "-", font: UIFont.ThemeFont.H3Medium, textColor: UIColor.ThemekLine.up, alignment: .left)
    lazy var nameLabel: UILabel = UILabel(text: "-", font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
    
    let tempHidProOrLoss:Bool = true
    
    lazy var headerbg : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeNav.bg

        return view
    }()
    
    lazy var priceView : SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.bottomLabel.font = UIFont.ThemeFont.BodyBold
        return view
    }()
    
    lazy var volumeView : SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.contentAlignment = .center
        view.bottomLabel.font = UIFont.ThemeFont.BodyBold
        return view
    }()
    
    lazy var leverageView : SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.contentAlignment = .right
        view.bottomLabel.font = UIFont.ThemeFont.BodyBold
        return view
    }()
    
    lazy var tipsLabel: UILabel = UILabel(text: "--", font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.red, alignment: .left)
    
    lazy var priceValueView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.setLeftText("cp_extra_text9".ex_localized())
        return view
    }()
    
    lazy var orderVolumeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        return view
    }()
    ///Contract type
    lazy var contractTypeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeLabel.colorHighlight, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.backgroundColor = UIColor.Ex.main3
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    lazy var stopProfitV: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.setLeftText("cp_overview_text15".ex_localized())
        view.isHidden = true
        return view
    }()
    
    lazy var stopLossV: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.setLeftText("cp_overview_text16".ex_localized())
        view.isHidden =  true
        return view
    }()
    lazy var thirdView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.isHidden = true
//        view.backgroundColor = .red
//        view.setLeftText("withdraw_text_available".ex_localized())
        return view
    }()
    
    lazy var positionSizeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.setLeftText("cp_content_text22".ex_localized())
        return view
    }()
    lazy var tipsBtn : UIButton = {
        let button = UIButton(buttonType: .custom, image: UIImage.exs_themeImageNamed(imageName: "public_icon_uncheck"))
//        button.seletedSvgImageName = "public_icon_check_mark"
        button.setImage(UIImage.svg_themeImageNamed(imageName: "public_icon_check_mark"), for: .selected)
        button.ext_SetAddTarget(self, #selector(clickNextComfirmButton))
        return button
    }()
    
    lazy var nextComfirmLabel: UILabel = UILabel(text: "cp_overview_text31".ex_localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_overview_text56".ex_localized(),titleFont: UIFont.ThemeFont.BodyMedium, titleColor: UIColor.ThemeLabel.colorLite)
        button.ext_setBackgroundColor(backgroundColor: UIColor.ThemeView.card2, state: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
    lazy var containerView : UIStackView = {
        let view = UIStackView()
        view.ext_UseAutoLayout()
        view.axis = .vertical
        view.layoutIfNeeded()
        view.backgroundColor = UIColor.ThemeView.alertBg
        return view
    }()
    private lazy var confirmButton: EXSButton = {
        let button = EXSButton(buttonType: .custom, title: "cp_calculator_text16".ex_localized(), titleFont: UIFont.ThemeFont.BodyMedium, titleColor: UIColor.white)
        button.ext_setBackgroundColor(backgroundColor: UIColor.ThemeBtn.highlight, state: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.ext_SetAddTarget(self, #selector(clickConfirmButton))
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 12
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.tipsLabel.numberOfLines = 0
        self.exs_addSubViews([typeLabel,
                          nameLabel,
                          priceValueView,
                          orderVolumeView,
                          tipsBtn,
                          nextComfirmLabel,
                          cancelButton,
                          confirmButton,containerView,contractTypeLabel])
        containerView.addArrangedSubview(thirdView)
        containerView.addArrangedSubview(stopProfitV)
        containerView.addArrangedSubview(stopLossV)
        
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        typeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(18)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(typeLabel)
            make.top.equalTo(typeLabel.snp.bottom).offset(5)
        }
        contractTypeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(8)
            make.centerY.equalTo(nameLabel)
            make.width.equalTo(35)
            make.height.equalTo(20)
        }
        priceValueView.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(nameLabel.snp.bottom).offset(16)
            make.height.equalTo(30)
        }
        orderVolumeView.snp.makeConstraints { (make) in
            make.left.right.equalTo(priceValueView)
            make.top.equalTo(priceValueView.snp.bottom)
            make.height.equalTo(30)
        }
        thirdView.snp.makeConstraints { (make) in
            
            make.height.equalTo(30)
        }
        containerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(priceValueView)
            make.top.equalTo(orderVolumeView.snp.bottom)
        }
        
        stopProfitV.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }
        stopLossV.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }
        tipsBtn.snp.makeConstraints { (make) in
            make.left.equalTo(typeLabel).offset(-10)

            make.top.equalTo(containerView.snp.bottom).offset(5)
            make.height.width.equalTo(35)
        }
        nextComfirmLabel.snp.makeConstraints { (make) in
            make.left.equalTo(tipsBtn.snp.right).offset(-5)
            make.right.equalTo(priceValueView)
            make.height.equalTo(20)
            make.centerY.equalTo(tipsBtn)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(tipsBtn.snp.bottom)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
            make.bottom.equalTo(-20)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.width.height.centerY.equalTo(confirmButton)
            make.right.equalTo(confirmButton.snp.left).offset(-16)
        }
        tipsLabel.isHidden = true
    }
    
// MARK: - Update
    func config(_ order : EXContractOrderModel) {

        self.currentModel = order
        var category = "cp_overview_text54".ex_localized()
        var color = UIColor.ThemekLine.up

        nameLabel.text = order.showName()
        contractTypeLabel.text = order.position_type.introduce + "\(order.leverage)X "
        contractTypeLabel.titleResizeSize()
        if order.side == .sell_OpenShort ||
            order.side == .sell_CloseLong {
            color = UIColor.ThemekLine.down
        }
        typeLabel.textColor = color
        var open = (order.side == .buy_OpenLong || order.side == .sell_OpenShort)
        if order.exec_px.count > 0 && order.exec_px.greaterThan(BTZERO) {
            if order.category == .planMarket && open   { //Planned market price && open  /
                
                category = "cp_overview_text53".ex_localized()
                thirdView.setRightText(order.qty + " " + (order.ex_contractInfo?.openValueUnit ?? ""))
                orderVolumeView.rightLabel.text = category
                //Entrustment value
                thirdView.setLeftText("cp_extra_text9".ex_localized())
            } else {
                //quantity
                thirdView.setLeftText("cp_overview_text8".ex_localized())
                thirdView.setRightText(order.qtyDisplay + " " + (order.ex_contractInfo?.volumeUnit ?? ""))
                orderVolumeView.rightLabel.text = order.exec_px + " " + (order.ex_contractInfo?.quote_coin ?? "")
            }
            if !order.currentPercent.isEmpty {
                thirdView.rightLabel.text = "\(order.currentPercent.bigMul("100"))" + "%"
            }
            typeLabel.text = order.side.display
            priceValueView.leftLabel.text = "cp_overview_text29".ex_localized()
            priceValueView.rightLabel.text = order.px + " " + (order.ex_contractInfo?.quote_coin ?? "")
          
            thirdView.isHidden = false
            
            orderVolumeView.leftLabel.text = "cp_overview_text30".ex_localized()
            
            leverageView.topLabel.text = "cp_overview_text8".ex_localized() + " " + "cp_overview_text9".ex_localized()
            leverageView.bottomLabel.text = order.qty
            
        } else {
            
            if  order.category == .market {
                category = "cp_overview_text53".ex_localized()
                //MARK: Closing a position is based on quantity/commission value when placing an order
                if order.closePosition {
                    //quantity
                    orderVolumeView.leftLabel.text = "cp_overview_text8".ex_localized()
                    priceValueView.rightLabel.text = category
                    if !order.currentPercent.isEmpty {
                        orderVolumeView.rightLabel.text = "\(order.currentPercent.bigMul("100"))" + "%"
                    }else {
                        
                        orderVolumeView.rightLabel.text = (order.ex_contractInfo?.volumeDisplay(vol: order.qty) ?? "") + " " + (order.ex_contractInfo?.volumeUnit ?? "")
                    }
                }else{
                    category = "cp_overview_text53".ex_localized()
                    //Entrustment value
                    orderVolumeView.leftLabel.text = "cp_extra_text9".ex_localized()
                    priceValueView.rightLabel.text = category
                    if !order.currentPercent.isEmpty {
                        orderVolumeView.rightLabel.text = "\(order.currentPercent.bigMul("100"))" + "%"
                    }else {
                        orderVolumeView.rightLabel.text = order.qty + " " + (order.ex_contractInfo?.openValueUnit ?? "")
                    }
                }
            } else {
                //quantity
                orderVolumeView.leftLabel.text = "cp_overview_text8".ex_localized()
                if !order.currentPercent.isEmpty {
                    orderVolumeView.rightLabel.text = "\(order.currentPercent.bigMul("100"))" + "%"
                }else {
                    if order.openOrderType == .value{ //Limit value opening
                        let amount = EXFormula.valueTobi(value: order.qty, price: order.px, contractModel: order.ex_contractInfo)
                        let unit = order.ex_contractInfo?.base_coin ?? ""

                        orderVolumeView.rightLabel.text = amount + " " + unit
                    }else{
                        orderVolumeView.rightLabel.text = (order.ex_contractInfo?.volumeDisplay(vol: order.qty) ?? "") + " " + (order.ex_contractInfo?.volumeUnit ?? "")
                    }
                   
                }
                
                if order.opponentType != .none {
                    priceValueView.rightLabel.text = order.opponentType.introduce
                }else if order.priceType != .limitPrice {
                    priceValueView.rightLabel.text = order.priceType.introduce
                }else {
                    priceValueView.rightLabel.text = order.px + " " + (order.ex_contractInfo?.quote_coin ?? "")
                }
            }
            
            priceValueView.leftLabel.text = "cp_overview_text6".ex_localized()
            leverageView.topLabel.text = "cp_assets_text5".ex_localized()
            var leverage = "cp_contract_setting_text2".ex_localized()
            if order.position_type == .allType {
                leverage = "cp_contract_setting_text1".ex_localized()
            }
            leverageView.bottomLabel.text = leverage + order.leverage + "X"
            
            var cost = (order.freezAssets).toValuePrecision(withContract: order.instrument_id)
            cost = cost + (order.ex_contractInfo?.margin_coin ?? "")

            thirdView.setLeftText("cp_overview_text11".ex_localized())
            if order.opponentType != .none {
                thirdView.setRightText("--")
            }else {
                thirdView.setRightText(cost)
            }
            if !order.takerProfitTrigger.isEmpty {
                stopProfitV.isHidden = false
                stopProfitV.setRightText(order.takerProfitTrigger + " " + (order.ex_contractInfo?.quote_coin ?? ""))
            }
            
            if !order.stopLossTrigger.isEmpty {
                stopLossV.isHidden = false

                stopLossV.setRightText(order.stopLossTrigger + " " + (order.ex_contractInfo?.quote_coin ?? ""))
            }
            typeLabel.text = order.side.display
        }
        ///Condition sheet
        if order.category == .plan || order.category == .planMarket{
            typeLabel.text = "cp_overview_text55".ex_localized() + " " + order.side.display
            //Trigger Price
            priceValueView.rightLabel.text = order.triggerPrice + " " + (order.ex_contractInfo?.quote_coin ?? "")
           
            if order.category == .planMarket{
                orderVolumeView.rightLabel.text =  "cp_overview_text53".ex_localized()
            }else{
                if order.openOrderType == .value{ //Limit value opening
                    let amount = EXFormula.valueTobi(value: order.qty, price: order.px, contractModel: order.ex_contractInfo)
                    let unit = order.ex_contractInfo?.base_coin ?? ""
                    thirdView.rightLabel.text = amount + " " + unit
                }
            }
            
           
        }
        
        
    }
    
// MARK: - Click Events

    @objc func clickCancelButton() {
        EXAlert.dismiss()
    }
    
    @objc func clickConfirmButton() {
       
        if tipsBtn.isSelected {
            EXStoreData.setComfirmSwapAlertStatus(false)
        }
        
        EXAlert.dismiss()
        self.confimModelCallBack?()
    }
    
 
    
    @objc func clickNextComfirmButton() {
        tipsBtn.isSelected = !tipsBtn.isSelected
    }
}

