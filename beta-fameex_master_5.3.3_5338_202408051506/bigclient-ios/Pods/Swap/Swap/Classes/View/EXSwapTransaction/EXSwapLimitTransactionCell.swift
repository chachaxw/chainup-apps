//
//  EXSwapLimitTransactionCell.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/12/21.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
enum EXContractTransactionDetailType: Int {
    case force
    case reduce
}
//MARK:  历史委托列表 cell English: MARK: Historical delegation list cell
class EXSwapLimitTransactionCell: UITableViewCell {
    
    /// 合约类型 English: /Contract type
    var transactionType: EXSwapTransactionType = .current {
        didSet {
            if transactionType == .current {
                self.cancelButton.isHidden = false
                self.dealTypeView.isHidden = true
            } else {
                self.cancelButton.isHidden = true
                self.dealTypeView.isHidden = false
            }
        }
    }
    
    /// 订单数据 English: /Order data
    var orderModel: EXContractOrderModel?
    
    /// 点击明细回调 English: /Click on the details callback
    var showDetailCallback: ((EXContractOrderModel, EXSwapMarketOrderType) -> ())?

    
    //MARK: lazy
    /// 多-空类型 English: /Multiple empty type
    lazy var dealTypeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.HeadBold, textColor: nil, alignment: NSTextAlignment.center)
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
        let label = UILabel(text: nil, font: UIFont.ThemeFont.MinimumRegular, textColor: .Ex.main4, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.backgroundColor = UIColor.Ex.main3
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.isHidden = true 
        return label
    }()
    
   
//    lazy var stopPLModuleContainerView : UIStackView = {
//        let view = UIStackView()
//        view.ext_UseAutoLayout()
//        view.axis = .vertical
//        view.layoutIfNeeded()
//        view.backgroundColor = UIColor.ThemeView.bg
//        return view
//    }()
    
    /// 取消按钮 English: /Cancel button
    lazy var cancelButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_order_text68".ex_localized(), titleFont: UIFont.ThemeFont.BodyBold, titleColor: UIColor.ThemeBtn.highlight)
        button.backgroundColor = UIColor.ThemeNav.bg
        button.layer.cornerRadius = 1.5
        button.ext_UseAutoLayout()
//        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
    
    /// 成交类型(已成交/未成交/部分成交) English: /Transaction type (completed/not completed/partially completed)
    lazy var dealTypeView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        let label = UILabel(text: "cp_order_text60".ex_localized(), font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: .right)
        let imgContainer = UIView()
        let imageView = UIImageView(image: UIImage.exs_themeImageNamed(imageName: "contract_positions_thedropdown"))
        imageView.contentMode = .scaleAspectFit
        view.addArrangedSubview(label)
        view.addArrangedSubview(imgContainer)
        imgContainer.addSubview(imageView)
        imgContainer.snp.makeConstraints { (make) in
            make.width.equalTo(14)
        }
        imageView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        view.isHidden = true
        return view
    }()
    
    ///强平的显示，可查看点击详情 English: /The display of Qiangping allows you to view click details
    lazy var forcereduceBtn: UIControl = {
        let detail = UIControl()
        let label = UILabel(text: "--", font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
        let imageView = UIImageView(image: UIImage.exs_themeImageNamed(imageName: "public_instructions"))
        imageView.contentMode = .scaleAspectFit
        detail.exs_addSubViews([label, imageView])
        label.snp.makeConstraints { (make) in
            make.left.top.height.equalToSuperview()
        }
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(label.snp.right)//.offset(4)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        detail.addTarget(self, action: #selector(clickDetailButton), for: .touchUpInside)
        detail.isHidden = true
        return detail
    }()
    
//    lazy var promptView : UIButton = {
//        let btn = UIButton()
//        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_instructions"), for: .normal)
//        btn.addTarget(self, action: #selector(clickpromptButton), for: .touchUpInside)
//        btn.isHidden = true
//        return btn
//    }()
    
    
    
    lazy var forcePriceView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.showTipBtnInLeft = true
        view.ext_UseAutoLayout()
        view.isHidden = true
        view.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        view.setLeftText("cp_calculator_text20".ex_localized())
        view.clickMiddleBtnBlock = { [weak self] in
            guard let `self` = self else { return }
            self.showAlertInfo(type: 0)
        }
        return view
    }()
    
    ///  成交均价 / 委托价格 English: /Average transaction price/commission price
    lazy var priceView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        view.setLeftText("cp_overview_text6".ex_localized())
        view.clickMiddleBtnBlock = { [weak self] in
            guard let `self` = self else { return }
            if self.orderModel?.isLiquidate() ?? false {
                self.showAlertInfo(type: 1)
            }
        }
        return view
    }()
//    /// 委托价值 ----市价用 English: /Entrusted value - market value
//    lazy var valueView: SLSwapHorDetailView = {
//        let view = SLSwapHorDetailView()
//        view.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
//        view.ext_UseAutoLayout()
//        return view
//    }()
    /// 委托数量 --（非市价用）   成交数量 / 委托数量  /// 市价 显示是（ 成交数量/委托价值） English: /The market price display is (transaction quantity/commission value)
    lazy var volumeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        view.ext_UseAutoLayout()
        return view
    }()
    
    ///盈亏记录 English: /Profit and loss records
    lazy var profitandlossView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        view.setLeftText("cp_order_text54".ex_localized())
        return view
    }()
   
//    /// 成交数量 / 委托数量  /// 市价 显示是（ 成交数量/委托价值） English: /The market price display is (transaction quantity/commission value)
//    lazy var dealVolumeView : SLSwapHorDetailView = {
//        let view = SLSwapHorDetailView()
//        view.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
//        view.ext_UseAutoLayout()
//        return view
//    }()
    
    
    
  
//    /// 成交均价 English: /Average transaction price
//    lazy var dealAverageView: SLSwapHorDetailView = {
//        let view = SLSwapHorDetailView()
//        view.ext_UseAutoLayout()
//        view.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
//        view.setLeftText("cp_order_text58".ex_localized())
//        return view
//    }()
//    /// "止盈触发价"; English: /"Stop profit trigger price";
//    lazy var stopProfitView: SLSwapHorDetailView = {
//        let view = SLSwapHorDetailView()
//        view.ext_UseAutoLayout()
//        view.setLeftText("cp_overview_text15".ex_localized())
//        return view
//    }()
//    /// "止损触发价" English: /"Stop loss trigger price"
//    lazy var stopLossV: SLSwapHorDetailView = {
//        let view = SLSwapHorDetailView()
//        view.ext_UseAutoLayout()
//        view.setLeftText("cp_overview_text16".ex_localized())
//        return view
//    }()
    
    //类型 English: type
    
    lazy var typeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        view.ext_UseAutoLayout()
        view.setLeftText("cp_order_text93".ex_localized())
        return view
    }()
    
    
    /// 横线 English: /Horizontal line
    lazy var horLineView: UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()

    lazy var stopPLPlaceholderView:UIView = {
       return UIView()
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.ext_SetCell()
        self.backgroundColor = UIColor.ThemeView.card1
        self.contentView.backgroundColor = UIColor.ThemeView.card1
//        stopPLModuleContainerView.addArrangedSubview(stopPLPlaceholderView)
//        stopPLPlaceholderView.exs_addSubViews([stopProfitView,stopLossV])
        self.contentView.exs_addSubViews([dealTypeLabel, nameLabel, timeLabel, dealTypeView, volumeView, forcePriceView, priceView, horLineView,profitandlossView,typeView,forcereduceBtn,contractTypeLabel])
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        let horMargin = 16
        dealTypeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(horMargin)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dealTypeLabel.snp.right).offset(5)
            make.height.equalTo(20)
            make.centerY.equalTo(dealTypeLabel)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dealTypeLabel)
            make.height.equalTo(12)
            make.centerY.equalTo(contractTypeLabel)
        }
        
        contractTypeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(timeLabel.snp.right).offset(8)
            make.height.equalTo(16)
            make.width.equalTo(68)
            make.top.equalTo(dealTypeLabel.snp.bottom).offset(5)
        }
        //完全成交 English: Complete transaction
        dealTypeView.snp.makeConstraints { (make) in
            make.right.equalTo(-horMargin)
            make.height.equalTo(32)
            make.width.equalTo(100)
            make.centerY.equalTo(dealTypeLabel)
        }
        //强制减仓 English: Compulsory reduction of positions
        forcereduceBtn.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(18)
        }
        
       
        //价格 English: price
        priceView.snp.makeConstraints { (make) in
            make.left.equalToSuperview() //.offset(16)
            make.right.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom).offset(43)
            make.height.equalTo(16)
        }
        
        //价格 English: price
        forcePriceView.snp.makeConstraints { (make) in
            make.left.equalToSuperview() //.offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(16)
            make.bottom.equalTo(priceView.snp.top).offset(-10)
            
        }
        
        //数量 English: quantity
        volumeView.snp.makeConstraints { (make) in
            make.top.equalTo(priceView.snp.bottom).offset(10)
            make.left.height.width.equalTo(priceView)
        }
        //盈亏 English: Profit and loss
        profitandlossView.snp.makeConstraints { (make) in
            make.top.equalTo(volumeView.snp.bottom).offset(10)
            make.left.height.width.equalTo(priceView)
        }
        //类型 English: type
        typeView.snp.makeConstraints { (make) in
            make.top.equalTo(profitandlossView.snp.bottom).offset(10)
            make.left.height.width.equalTo(priceView)
        }

        horLineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
       
//        //成交均价 English: Average transaction price
//        dealAverageView.snp.makeConstraints { (make) in
//            make.top.equalTo(profitandlossView.snp.bottom).offset(10)
//            make.left.height.width.equalTo(priceView)
//        }
//        //成交数量 English: Transaction quantity
//        dealVolumeView.snp.makeConstraints { (make) in
//            make.top.equalTo(dealAverageView.snp.bottom).offset(10)
//            make.left.height.width.equalTo(priceView)
//        }
//
        
        ///没用的 English: /Useless
//        stopPLModuleContainerView.snp.makeConstraints { (make) in
//            make.left.equalTo(priceView)
//            make.right.equalTo(profitandlossView)
//            make.top.equalTo(dealVolumeView.snp.bottom).offset(12)
//        }
//        stopProfitView.snp.makeConstraints { (make) in
//            make.left.top.bottom.equalToSuperview()
//            make.width.equalTo(priceView).offset(15)
//        }
//        stopLossV.snp.makeConstraints { (make) in
//            make.top.bottom.equalToSuperview()
//            make.left.equalTo(stopProfitView.snp.right)
//            make.width.equalTo(stopProfitView)
//        }
//        stopPLPlaceholderView.snp.makeConstraints { (make) in
//            make.height.equalTo(priceView)
//        }
      
        
//        valueView.snp.makeConstraints { (make) in
//            make.edges.equalTo(volumeView)
//        }
       
      
    }
}


// MARK: - Update Data

extension EXSwapLimitTransactionCell {
    func updateCell(model: EXContractOrderModel) {
        self.orderModel = model
        let isLiquidate = model.isLiquidate()
        forcereduceBtn.isHidden = !model.isSpecialType()
        if isLiquidate{
            priceView.showTipBtnInLeft = true
        }else{
            priceView.showTipBtnInLeft = false
        }
        forcePriceView.isHidden = !isLiquidate
        forcePriceView.rightLabel.text = model.forcedPrice.toPricePrecision(withContractID: model.instrument_id)
        if forcereduceBtn.isHidden{
            priceView.snp.updateConstraints { make in
                make.top.equalTo(timeLabel.snp.bottom).offset(16)
            }
        }else{
            var height: CGFloat = 43
            if isLiquidate{
                height += 26
            }
            priceView.snp.updateConstraints { make in
                make.top.equalTo(timeLabel.snp.bottom).offset(height)
            }
        }
//        forcereduceBtn.isHidden = !model.isSpecialType()
//        typeView.rightLabel.isHidden = model.isSpecialType()
//        
//        if forcereduceBtn.isHidden{
//            priceView.snp.updateConstraints { make in
//                make.top.equalTo(timeLabel.snp.bottom).offset(16)
//            }
//        }else{
//            priceView.snp.updateConstraints { make in
//                make.top.equalTo(timeLabel.snp.bottom).offset(43)
//            }
//        }
        
        
//        stopPLPlaceholderView.isHidden = model.shouldHiddenOtoOrderDetailView
//        stopProfitView.setRightText(model.otoOrder.takerProfitTrigger)
//        stopLossV.setRightText(model.otoOrder.stopLossTrigger)
        //订单类型不用显示 English: Order type does not need to be displayed
//        contractTypeLabel.text = model.orderDesc
//        contractTypeLabel.titleResizeSize()
        self.dealTypeLabel.textColor = model.side.textColor
        self.dealTypeLabel.text = model.side.display
        self.nameLabel.text = model.showName()
        self.timeLabel.text = EXSDateTools.strToTimeString(model.created_at)
        //价格--  成交价/委托价 English: Price - transaction price/commission price
        var priceshow = ""
        if isLiquidate {
            let newPrice = model.takeOverPrice.toPricePrecision(withContractID: model.instrument_id)
            priceshow =  newPrice + "/" + newPrice//"--/--"
        }else if let type = model.typeEnum, type == .market  {
            priceshow = model.avg_px + "/" + "cp_overview_text53".ex_localized() //市价文案 English: Market price copy
        } else {
            priceshow = model.avg_px + "/" + (model.px).toPricePrecision(withContractID: model.instrument_id)
        }
        self.priceView.rightLabel.attributedText = priceshow.specailShow()
        
        //数量--  成交量/委托量 English: Quantity - trading volume/commission volume
        var volumShow = model.cumQtyDisplay + "/" + model.qtyDisplay
        var volumTitle = "cp_overview_text8".ex_localized() + " (\(model.ex_contractInfo?.volumeUnit ?? ""))"
        if model.isOpen() , let type = model.typeEnum, type == .market {
            //数量/委托价值-- 成交量/委托价值   //contract_text_value English: Contract_ Text_ Value
            volumTitle = volumTitle + "/" + "cp_order_text102".ex_localized() + "(" + (model.ex_contractInfo?.openValueUnit ?? "") + ")"
            volumShow =  model.cumQtyDisplay + "/" + (model.qty).marketPriceVolPrecision(withContract:model.instrument_id)
        }
        self.volumeView.leftLabel.text = volumTitle
        self.volumeView.rightLabel.attributedText = volumShow.specailShow()
        
       // updateVolumeLabel(model: model)
      //  valueView.setLeftText("cp_extra_text9".ex_localized() + "(" + (model.ex_contractInfo?.openValueUnit ?? "") + ")")
//        if isLiquidate {
//            self.dealAverageView.setRightText("--")
//        }else {
//
//            self.dealAverageView.setRightText((model.avg_px ))
//        }
//        self.priceView.setLeftText("cp_overview_text30".ex_localized() + "(" + (model.ex_contractInfo?.quote_coin ?? "") + ")")
//        self.dealAverageView.setLeftText("cp_order_text58".ex_localized() + "(" + (model.ex_contractInfo?.quote_coin ?? "") + ")")

        typeView.setRightText(model.typeEnum?.display ?? "" )
        
        if model.isSpecialType() {
            if let label = self.forcereduceBtn.subviews.first as? UILabel {
                label.text = model.getSourceType()?.display ?? ""
            }
            if let icon = self.forcereduceBtn.subviews.last {
                icon.isHidden = true
                if model.isADl() {
                    icon.isHidden = false
                }
                
                
            }
        }
        
        if transactionType == .history {
            profitandlossView.setLeftText("cp_order_text8".ex_localized() + "(" + (model.ex_contractInfo?.margin_coin ?? "") + ")")
            profitandlossView.rightLabel.setUpAndDownText(orderModel?.realizedAmount.toValuePrecision( withContract: model.instrument_id) ?? "")
        }else {
            profitandlossView.setRightText(model.isOnlySubtract() ? "cp_extra_text3".ex_localized() : "cp_extra_text2".ex_localized())
        }
        
        if let label = self.dealTypeView.subviews.first as? UILabel {
            label.text = model.statusDisplay
        }
//        if let icon = self.dealTypeView.subviews.last {
//            icon.isHidden = !model.isLiquidate()
//        }
    }
    
//    func updateVolumeLabel(model: EXContractOrderModel) {
//
//        volumeView.setLeftText("cp_order_text66".ex_localized() + " (\(model.ex_contractInfo?.volumeUnit ?? ""))")
//        dealVolumeView.setLeftText("cp_extra_text8".ex_localized() + " (\(model.ex_contractInfo?.volumeUnit ?? ""))")
//
//        self.dealVolumeView.setRightText(model.cumQtyDisplay)
//
//        if model.isOpen() , let type = model.typeEnum, type == .market {
//            self.volumeView.isHidden = true
//        }else {
//            self.volumeView.isHidden = false
//            self.volumeView.setRightText(model.qtyDisplay)
//        }
//    }
}


// MARK: - Click Events

extension EXSwapLimitTransactionCell {
    
    /// 强平 English: /Qiangping
    @objc func clickDetailButton() {
        guard let tempOrderModel = self.orderModel else {
            return
        }
        if tempOrderModel.isADl(){
            self.showDetailCallback?(tempOrderModel, tempOrderModel.getSourceType() ?? .forceReducePosition)
        }
    }
    
    /// 强平 English: /Qiangping
    @objc func showAlertInfo(type: Int) {
        var msg = "order_history_bankr_price".ex_localized()
        if type == 0 {
            msg = "order_history_liq_price".ex_localized()
        }
        let alert = EXCommonAlert()
        alert.configAlert(title: msg,onlyOneBtnTitle: "cp_extra_text28".ex_localized(), bottomOnlyOneBtn: true) {  type in
            if type == .textAction {
              
            }else{
                EXAlert.dismiss()
            }
        }
        EXAlert.showAlert(alertView: alert)
    }

}


