//
//  SLSwapHistoryTransactionCell.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/12/31.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
///Plan Delegation List Cell
class EXSwapPlanTransactionCell: UITableViewCell {
    
    /// 合约类型 English: /Contract type
    var transactionType: EXSwapTransactionType = .current {
        didSet {
            if transactionType == .current {
                self.cancelButton.isHidden = false
                self.orderTypeLabel.isHidden = true
                self.valueView.isHidden = true
            } else { //历史委托 English: Historical commission
                self.cancelButton.isHidden = true
                self.orderTypeLabel.isHidden = false
                self.valueView.isHidden = false
                triggerPriceView.snp.updateConstraints { make in
                    make.right.equalToSuperview().offset(0)
                }
                triggerPriceView.rightLabel.textAlignment = .right
                excutivePriceView.snp.updateConstraints { make in
                    make.width.equalTo(triggerPriceView)
                }
                excutivePriceView.rightLabel.textAlignment = .right
                excutiveVolumeView.snp.updateConstraints { make in
                    make.width.equalTo(triggerPriceView)
                }
                excutiveVolumeView.rightLabel.textAlignment = .right
                valueView.snp.remakeConstraints { make in
                    make.edges.equalTo(excutiveVolumeView)
                }
                valueView.rightLabel.textAlignment = .right
                expireTimeView.snp.updateConstraints { make in
                    make.width.equalTo(triggerPriceView)
                }
                expireTimeView.rightLabel.textAlignment = .right
                
            }
        }
    }
    /// 订单数据 English: /Order data
    var orderModel: EXContractOrderModel?
    /// 撤单回调 English: /Cancellation callback
    var cancelOrderCallback: ((EXContractOrderModel) -> ())?
    
    
     //MARK: lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.ext_SetCell()
        self.backgroundColor = UIColor.ThemeView.card1
        self.contentView.backgroundColor = UIColor.ThemeView.card1
      //  self.exs_addSubViews([contractTypeLabel,dealTypeLabel, nameLabel, timeLabel, cancleReason, orderTypeLabel,cancelButton, triggerPriceView, excutivePriceView, excutiveVolumeView, expireTimeView, valueView, triggerTimeView, horLineView])
        self.exs_addSubViews([
            dealTypeLabel,nameLabel,timeLabel,
            contractTypeLabel,onlySubtractView,cancelButton,orderTypeLabel,
            triggerPriceView,
            excutivePriceView,
            excutiveVolumeView,
            valueView,
            expireTimeView,
            horLineView])
        //历史委托使用 English: Historical commissioned use
        //MARK: fix 需要调整 English: MARK: Fix needs to be adjusted
//        self.exs_addSubViews([cancleReason,typeView,orderTypeLabel,cancelButton,valueView])
        self.initLayout()
    }
    
    
    
    //MARK: lazy
    /// 多-空类型 English: /Multiple empty type
    lazy var dealTypeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.BodyBold, textColor: nil, alignment: NSTextAlignment.center)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    
    /// 合约名称 English: /Contract Name
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    /// 创建时间 English: /Creation time
    lazy var timeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    /// 合约类型 English: /Contract type
    lazy var contractTypeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeLabel.colorHighlight, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.backgroundColor = UIColor.Ex.main3
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    /// ///只减仓 English: /Only reduce positions
    lazy var onlySubtractView: UILabel = {
        let label = UILabel(text: "cp_order_text54".ex_localized(), font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeLabel.colorHighlight, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.backgroundColor = UIColor.Ex.main3
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    
    
    /// 撤单 English: /Cancellation of orders
    lazy var cancelButton: RepeatButton = {
        let button = RepeatButton(buttonType: .custom, title: "cp_order_text68".ex_localized(), titleFont: UIFont.ThemeFont.BodyBold, titleColor: UIColor.ThemeLabel.colorLite)
        button.backgroundColor = UIColor.ThemeView.card2
        button.layer.cornerRadius = 4
        button.ext_UseAutoLayout()
        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
    
    
    /// 触发价格 English: /Trigger price
    lazy var triggerPriceView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.rightLabel.textAlignment = .left
        return view
    }()
    /// 委托价格 English: /Commission price
    lazy var excutivePriceView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.rightLabel.textAlignment = .left
        view.setLeftText("cp_overview_text30".ex_localized())
        return view
    }()
    
    /// 委托数量 English: /Number of Commissions
    lazy var excutiveVolumeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.rightLabel.textAlignment = .left
        return view
    }()
    /// 委托价值 English: /Entrusted value
    lazy var valueView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.setLeftText("cp_extra_text9".ex_localized() + " (USDT)")
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.rightLabel.textAlignment = .left
        return view
    }()
    /// 到期时间 English: /Expiration time
    lazy var expireTimeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.setLeftText("cp_order_text67".ex_localized())
        view.rightLabel.textAlignment = .left
        return view
    }()
    /// 横线 English: /Horizontal line
    lazy var horLineView: UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    /// 历史委托 ------ English: /Historical commission------
    lazy var typeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.setLeftText("cp_order_text93".ex_localized())
        return view
    }()
    
    /// 历史委托 - 订单状态 English: /Historical Delegation - Order Status
    lazy var orderTypeLabel: UILabel = {
        let label = UILabel(text: "cp_content_text7".ex_localized(), font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: .right)
        label.isHidden = true
        return label
    }()
    
    /// 历史委托 - 触发时间 English: /Historical Delegation - Trigger Time
    lazy var triggerTimeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.setLeftText("cp_extra_text68".ex_localized())
        return view
    }()
    
    lazy var cancleReason:UIButton = {
        let button = UIButton()
        button.exs_setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        button.setImage(UIImage.exs_themeImageNamed(imageName: "public_instructions"), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(clickReasonButton), for: .touchUpInside)
        return button
        
    }()
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


// MARK: - Data

extension EXSwapPlanTransactionCell {
    func updateCell(model: EXContractOrderModel) {
        self.orderModel = model
        showTriggerTypeLabel(isShow: model.showStopPL)
        contractTypeLabel.text = model.orderDesc
        contractTypeLabel.titleResizeSize()
//        let sizeW = contractTypeLabel.titleResizeSize().width
//        contractTypeLabel.snp.updateConstraints { make in
//            make.width.equalTo(sizeW)
//        }
        self.dealTypeLabel.textColor = model.side.textColor
        self.dealTypeLabel.text = model.side.display
        self.nameLabel.text = model.showName()
        self.timeLabel.text = EXSDateTools.strToTimeString(model.created_at)
        onlySubtractView.isHidden = !model.isOnlySubtract()
        onlySubtractView.titleResizeSize()
        self.triggerPriceView.setRightText(model.triggerPrice.toPricePrecision(withContractID: model.instrument_id))
        if  let type = model.typeEnum, type == .market {
            self.excutivePriceView.setRightText("cp_overview_text53".ex_localized())
        } else {
            if model.timeInForce == "2" { //市价类型 English: Market price type
                self.excutivePriceView.setRightText("cp_overview_text53".ex_localized())
            }else{
                self.excutivePriceView.setRightText((model.px ).toPricePrecision(withContractID: model.instrument_id))
            }
        }
        
        updateVolumeLabel(model: model)
        updatePriceLabel(model: model)
        self.expireTimeView.setRightText(EXSDateTools.strToTimeString(model.expireTime, dateFormat: "MM-dd HH:mm"))
        if self.transactionType == .history {
            self.expireTimeView.setLeftText("cp_extra_text68".ex_localized())
            if let status = EXSwapPlanOrderStatus.init(rawValue: model.orderStatus) {
                if status == .cancel || status == .timeOut {
                    self.expireTimeView.setLeftText("cp_order_text67".ex_localized())
                }
            }
            self.expireTimeView.setRightText(EXSDateTools.strToTimeString(model.mtime, dateFormat: "MM-dd HH:mm"))
            self.orderTypeLabel.text = model.statusDisplay
            
        }
        
    }
    
    func updatePriceLabel(model:EXContractOrderModel) {
        triggerPriceView.setLeftText("cp_overview_text29".ex_localized())
        excutivePriceView.setLeftText("cp_overview_text30".ex_localized())
    }
    
    func updateVolumeLabel(model: EXContractOrderModel) {
        excutiveVolumeView.setLeftText("cp_order_text66".ex_localized() + " (\(model.ex_contractInfo?.volumeUnit ?? ""))")
        if model.isOpen(),let type = model.typeEnum, type == .market {
            //open and market show
            
           let coin = model.ex_contractInfo?.base_coin
            excutiveVolumeView.setLeftText("cp_extra_text9".ex_localized() + " (\(coin ?? ""))")
            self.excutiveVolumeView.isHidden = true
            self.valueView.isHidden = false
            self.valueView.setRightText((model.qty ).marketPriceVolPrecision(withContract:model.instrument_id))
        }else {
            self.excutiveVolumeView.isHidden = false
            self.valueView.isHidden = true
            self.excutiveVolumeView.setRightText(model.qtyDisplay)
        }
    }
    
}

// MARK: - Click Events

extension EXSwapPlanTransactionCell {
    /// 撤单 English: /Cancellation of orders
    @objc func clickCancelButton() {
        guard let tempOrderModel = self.orderModel else {
            return
        }
        self.cancelOrderCallback?(tempOrderModel)
    }
    @objc func clickReasonButton() {
        guard let tempOrderModel = self.orderModel else {
            return
        }
        let alert = EXSNormalAlert()
        alert.configSigleAlert(title: "", message: tempOrderModel.memoDisplay)
        EXAlert.showAlert(alertView: alert)
    }
}
// MARK: - Click Events
extension EXSwapPlanTransactionCell {
    func showTriggerTypeLabel(isShow:Bool) {
        let horMargin = 15
        contractTypeLabel.isHidden = !isShow
    }
    
    private func initLayout() {
        let horMargin = 16
        dealTypeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin)
            make.height.equalTo(16)
            make.top.equalToSuperview().offset(horMargin)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dealTypeLabel.snp.right).offset(5)
            make.height.equalTo(19)
            make.centerY.equalTo(dealTypeLabel)
        }
        
        orderTypeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-horMargin)
            make.height.equalTo(12)
            make.centerY.equalTo(nameLabel)
        }
        
        contractTypeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dealTypeLabel)
            make.height.equalTo(16)
            make.width.equalTo(68)
            make.top.equalTo(dealTypeLabel.snp.bottom).offset(5)
        }
        
        onlySubtractView.snp.makeConstraints { (make) in
            make.left.equalTo(contractTypeLabel.snp.right).offset(5)
            make.height.equalTo(16)
            make.width.equalTo(68)
            make.centerY.equalTo(contractTypeLabel)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.width.equalTo(75)
            make.height.equalTo(34)
            make.right.equalToSuperview().offset(-horMargin)
            make.top.equalToSuperview().offset(72)
        }
        
        //触发价格 English: Trigger price
        triggerPriceView.snp.makeConstraints { (make) in
            make.left.equalToSuperview() //.offset(16)
            make.height.equalTo(18)
            make.right.equalToSuperview().offset(-100)
            make.top.equalTo(contractTypeLabel.snp.bottom).offset(16)
        }
        //委托价格 English: Commission price
        excutivePriceView.snp.makeConstraints { (make) in
            make.left.width.height.equalTo(triggerPriceView)
            make.top.equalTo(triggerPriceView.snp.bottom).offset(10)
        }
        //委托数量 English: Number of Commissions
        excutiveVolumeView.snp.makeConstraints { (make) in
            make.left.equalTo(triggerPriceView)
            make.height.width.equalTo(triggerPriceView)
            make.top.equalTo(excutivePriceView.snp.bottom).offset(10)
        }
//        //委托价值 --历史委托使用 English: Entrustment Value - Historical Entrustment Usage
        valueView.snp.makeConstraints { make in
            make.edges.equalTo(excutiveVolumeView)
        }
        //到期时间 English: Expiration time
        expireTimeView.snp.makeConstraints { (make) in
            make.left.equalTo(triggerPriceView)
            make.height.width.equalTo(triggerPriceView)
            make.top.equalTo(excutiveVolumeView.snp.bottom).offset(10)
        }
        
        horLineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.right.bottom.equalToSuperview()
        }
        
//MARK: fix
//        cancleReason.snp.makeConstraints { (make) in
//            make.right.equalTo(orderTypeLabel.snp.left)
//            make.centerY.equalTo(dealTypeLabel)
//            make.width.equalTo(35)
//            make.height.equalTo(35)
//        }
//        orderTypeLabel.snp.makeConstraints { (make) in
//            make.right.equalTo(-horMargin)
//            make.height.equalTo(32)
//            make.centerY.equalTo(dealTypeLabel)
//        }
//
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-horMargin)
            make.height.equalTo(16)
            make.centerY.equalTo(contractTypeLabel)
        }

        
    }
    
    func updataLayout() {
//        excutivePriceView.snp.remakeConstraints { (make) in
//            make.right.equalToSuperview().offset(-15)
//            make.left.equalTo(triggerPriceView.snp.right).offset(15)
//            make.height.width.equalTo(triggerPriceView)
//            make.top.equalTo(excutiveVolumeView)
//        }
   
    }
}

