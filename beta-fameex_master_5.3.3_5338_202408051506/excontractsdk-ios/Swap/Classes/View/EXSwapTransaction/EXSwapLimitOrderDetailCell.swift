//
//  EXSwapLimtOrderDetailCell.swift
//  Chainup
//
//  Created by ZYJ on 2023/5/18.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXSwapLimitOrderDetailCell: UITableViewCell {
    
    
    static func cellHeight(model: EXContractOrderModel?) -> CGFloat {
        
        guard let tempOrderModel = model else {
            return EXSwapLimitOrderNewDetailView.viewHeight + 96
        }
        if let type = tempOrderModel.getSourceType() {
            if type == .forceReducePosition {
                return  EXSwapLimitOrderNewDetailView.viewHeight + 116 + 36
            }
            return EXSwapLimitOrderNewDetailView.viewHeight + 116
        }
        return EXSwapLimitOrderNewDetailView.viewHeight + 96
    }
    
    
    var orderModel: EXContractOrderModel? {
        didSet{
            nameLabel.text = orderModel?.showName()
            dealTypeView.text = orderModel?.statusDisplay
            mainView.orderModel = orderModel
            
            guard let tempOrderModel = self.orderModel else {
                return
            }
            if let type = tempOrderModel.getSourceType() {
                forcereduceBtn.isHidden = false
                if let label = self.forcereduceBtn.subviews.first as? UILabel {
                    label.text = type.display ?? ""
                }
                var show = false
                if type == .ADL || type == .forceReducePosition {
                    show = true
                }
                if let icon = self.forcereduceBtn.subviews.last {
                    icon.isHidden = !show
                }
            }else{
                forcereduceBtn.isHidden = true
                mainView.snp.remakeConstraints { make in
                    make.top.equalTo(dealTypeView.snp.bottom).offset(32)
                    make.left.equalToSuperview().offset(16)
                    make.right.equalToSuperview().offset(-16)
                    make.bottom.equalToSuperview()
                }
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.ext_SetCell()
        configSubView()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mainView.exs_roundCorners(corners: .allCorners, radius: 5)
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configSubView(){
        contentView.exs_addSubViews([nameLabel,dealTypeView,mainView,forcereduceBtn])
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(22)
            make.height.equalTo(24)
            make.centerX.equalToSuperview()
        }
        
        dealTypeView.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.height.equalTo(16)
            make.centerX.equalToSuperview()
        }
        forcereduceBtn.snp.makeConstraints { (make) in
            make.top.equalTo(dealTypeView.snp.bottom).offset(7)
            make.height.equalTo(16)
            make.centerX.equalToSuperview()
        }
        mainView.snp.makeConstraints { make in
            make.top.equalTo(forcereduceBtn.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
    }
    
    
    //MARK: lazy
    /// 合约名称 English: /Contract Name
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.getFont(size: 20, aweight:.bold), textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        return label
    }()
    /// 成交类型(已成交/未成交/部分成交) English: /Transaction type (completed/not completed/partially completed)
    lazy var dealTypeView: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        return label
    }()
    
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
            make.left.equalTo(label.snp.right) //.offset(4)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        detail.addTarget(self, action: #selector(clickDetailButton), for: .touchUpInside)
        detail.isHidden = true
        return detail
    }()
    
    lazy var mainView:EXSwapLimitOrderNewDetailView = {
        let v = EXSwapLimitOrderNewDetailView()
       // v.exs_roundCorners(corners: .allCorners, radius: 5)
        return v
    }()
    
    
    
    /// 强平 English: /Qiangping
    @objc func clickDetailButton() {
        guard let tempOrderModel = self.orderModel else {
            return
        }
        if let type = tempOrderModel.getSourceType(), type == .forceReducePosition {
            showForceDetailAlert(model: tempOrderModel)
            return
        }
        if let type = tempOrderModel.getSourceType(), type == .ADL {
            showADLDetailAlert()
        }
    }

    private func showADLDetailAlert() {
        let alert = EXCommonAlert()
        alert.configAlert(title: "cp_order_adl1".ex_localized(),msgCommonPart:  "cp_order_adl2".ex_localized(), msgActionPart:"cp_adl_introduce".ex_localized() ,onlyOneBtnTitle: "cp_extra_text28".ex_localized(), bottomOnlyOneBtn: true) {  type in
            if type == .textAction {
                let url  = EXSTools.getAdlUrl()
                let title = ""
                EXSwapPlatformSDK.shared.goToH5?(url,title,self.yy_viewController,nil)
            }else{
                EXAlert.dismiss()
            }
        }
        EXAlert.showAlert(alertView: alert)
    }
    
    /// 显示强平明细 English: /Display Strong Ping Details
    private func showForceDetailAlert(model: EXContractOrderModel) {
        let alert = EXCommonAlert()
        let content = model.getNewliqPositionMsg()
        alert.configAlert(title: "cp_extra_text80".ex_localized(), message: content,bottomOnlyOneBtn: true) { _ in
            
        }
        EXAlert.showAlert(alertView: alert)
    
    }
    
    
}


/// 历史委托详情cell English: /Historical commission details cell
class EXSwapLimitOrderNewDetailView: EXCOCustomBaseView {
    
    override class var viewHeight: CGFloat{
        return 304
    }
    /// 订单数据 English: /Order data
    var orderModel: EXContractOrderModel? {
        didSet{
            guard let m = orderModel else{
                return
            }
            self.updateView(model:m)
        }
    }
    
    
    override func setSubView(){
        self.backgroundColor = UIColor.ThemeView.newbg
        self.exs_addSubViews([
            sideTypeView,
            forcePriceView,
            priceView,
            volumeView,
            profitandlossView,
            withDrawView,
            typeView,
            timeLabelView,
            idLabelView
        ]
        )
        self.initLayout()
    }
   
    
    
    //MARK: lazy
    ///列表从上到下 English: /List from top to bottom
    /// 多-空类型 English: /Multiple empty type

    //MARK:
    lazy var sideTypeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.setLeftText("cp_order_direction_label".ex_localized())
        return view
    }()
    
    lazy var forcePriceView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.isHidden = true
        view.showTipBtnInLeft = true
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
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
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.setLeftText("cp_overview_text6".ex_localized())
        view.clickMiddleBtnBlock = { [weak self] in
            guard let `self` = self else { return }
            self.showAlertInfo(type: 1)
        }
        return view
    }()

    /// 委托数量 --（非市价用）   成交数量 / 委托数量  /// 市价 显示是（ 成交数量/委托价值） English: /The market price display is (transaction quantity/commission value)
    lazy var volumeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.ext_UseAutoLayout()
        return view
    }()
    
    ///盈亏记录 English: /Profit and loss records
    lazy var profitandlossView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.setLeftText("cp_order_text54".ex_localized())
        return view
    }()
   
    
    /// 手续费 English: /Handling fees
    lazy var withDrawView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.setLeftText("cp_position_text2".ex_localized())
        view.clickMiddleBtnBlock = { [weak self] in
            self?.feeTip()
        }
        return view
    }()
    
    //类型 English: type
    lazy var typeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.ext_UseAutoLayout()
        view.setLeftText("cp_order_text93".ex_localized())
        view.clickMiddleBtnBlock = { [weak self] in
            self?.clickDetailButton()
        }
        return view
    }()
    
    //时间 English: time
    lazy var timeLabelView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.ext_UseAutoLayout()
        view.setLeftText("cp_contract_data_text20".ex_localized())
        return view
    }()
    //ID
    lazy var idLabelView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.ext_UseAutoLayout()
        view.setLeftText("ID")
        view.showTipBtn = true
        view.rightButton.setImage(UIImage.exs_themeImageNamed(imageName: "trade_icon_compared"), for: .normal)
        view.rightButton.setImage(UIImage.exs_themeImageNamed(imageName: "trade_icon_compared"), for: .selected)
        view.clickMiddleBtnBlock = { [weak self] in
            UIPasteboard.general.string =  self?.orderModel?.orderId ?? ""
            EXAlert.showSuccess(msg: "common_tip_copySuccess".ex_localized())
        }
        return view
    }()
   
   
   
    
    private func initLayout() {
        sideTypeView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()//.offset(horMargin)
            make.right.equalToSuperview()//.offset(-horMargin)
            make.height.equalTo(16)
            make.top.equalToSuperview().offset(18)
        }
        
        forcePriceView.snp.makeConstraints { (make) in
            make.top.equalTo(sideTypeView.snp.bottom).offset(20)
            make.left.right.height.equalTo(sideTypeView)
        }
        priceView.snp.makeConstraints { (make) in
            make.top.equalTo(sideTypeView.snp.bottom).offset(20)
            make.left.right.height.equalTo(sideTypeView)
        }
        volumeView.snp.makeConstraints { (make) in
            make.top.equalTo(priceView.snp.bottom).offset(20)
            make.left.right.height.equalTo(sideTypeView)
        }
        profitandlossView.snp.makeConstraints { (make) in
            make.top.equalTo(volumeView.snp.bottom).offset(20)
            make.left.right.height.equalTo(sideTypeView)
        }
        withDrawView.snp.makeConstraints { (make) in
            make.top.equalTo(profitandlossView.snp.bottom).offset(20)
            make.left.right.height.equalTo(sideTypeView)
        }
        typeView.snp.makeConstraints { (make) in
            make.top.equalTo(withDrawView.snp.bottom).offset(20)
            make.left.right.height.equalTo(sideTypeView)
        }
        timeLabelView.snp.makeConstraints { (make) in
            make.top.equalTo(typeView.snp.bottom).offset(20)
            make.left.right.height.equalTo(sideTypeView)
        }
        idLabelView.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabelView.snp.bottom).offset(20)
            make.left.right.height.equalTo(sideTypeView)
        }
    }
}


// MARK: - Update Data

extension EXSwapLimitOrderNewDetailView {
    /*
     1.委托详情文案调整：     English: 1. Commission details text adjustment:
     均价/价格:   Avg./Price                                   cp_overview_text47 = "均价" /cp_overview_text6 English: Avg./Price cp_ Overview_ Text47="Average Price"/cp_ Overview_ Text6
     限价：成交/数量（ETH）或 成交/数量（张） Filled/Size             "cp_order_text60"="成交"; /"cp_overview_text8" English: Price Limit: Transaction/Quantity (ETH) or Transaction/Quantity (sheet) Filled/Size "cpreorder_text60"="Transaction"/ "Cp-overview_text8"
     市价：成交（ETH)/价值（USDT）或 成交（张)/价值（USDT）Filled/Size    cp_order_text60/cp_order_text102 English: Market price: Transaction (ETH)/Value (USDT) or Transaction (Zhang)/Value (USDT) Filled/Size cp_ Order_ Text60/cp_ Order_ Text102

     2.委托详情数据显示规则： English: 2. Rules for displaying commission details data:
     成交均价、价格：若没有数据则显示为"--"，若数据为0，则正常显示为0 English: Average transaction price and price: If there is no data, it will be displayed as "--". If the data is 0, it will be displayed as 0 normally
     强平委托：成交均价、价格 无论有没有返回数值都显示为“--” English: Strong Ping Entrustment: The average transaction price and price are displayed as "--" regardless of whether there is a return value
     未成交委托：成交均价 显示为"--"，成交数量显示为：0（精度按照数量精度），手续费显示为“--”（精度按照数量精度） English: Untrusted commission: The average transaction price is displayed as "--", the transaction quantity is displayed as "0" (precision based on quantity precision), and the handling fee is displayed as "--" (precision based on quantity precision)
     0 初始,1新订单，2完全成交，3 部分成交，4 己撤销，5 待撤销，6异常 English: 0 initial, 1 new order, 2 complete transactions, 3 partial transactions, 4 revoked, 5 pending revocation, 6 abnormal
     订单 English: order form
 }
     
     */
    func updateView(model: EXContractOrderModel) {
        let isLiquidate = model.isLiquidate()
        //方向 English: direction
        self.sideTypeView.rightLabel.text = model.side.display
        self.sideTypeView.rightLabel.textColor = model.side.textColor
        self.timeLabelView.rightLabel.text = EXSDateTools.strToTimeString(model.created_at)
        if model.avg_px.isEmpty {
            model.avg_px = "--"
        }
        if model.px.isEmpty {
            model.px = "--"
        }
        if model.orderStatus == 5 {//"待撤销"   未成交委托： English: "Pending Cancellation" Unsettled Entrustments:
            model.avg_px = "--"
            model.px = "--"
            model.cum_qty = "0"
            model.feeValue = "--"
        }
        
        //价格--  成交价/委托价 English: Price - transaction price/commission price
        var priceshow = ""
        var priceTitle = "cp_overview_text47".ex_localized() + "/" + "cp_overview_text6".ex_localized()
        if isLiquidate { //强平 English: Qiangping
            let newPrice = model.takeOverPrice.toPricePrecision(withContractID: model.instrument_id)
            priceshow =  newPrice + "/" + newPrice//"--/--"
            self.priceView.showTipBtnInLeft = true
            model.feeValue = "--"
        }else if let type = model.typeEnum, type == .market  { //市价-- English: Market price--
            priceshow = model.avg_px + "/" + "cp_overview_text53".ex_localized() //市价文案 English: Market price copy
        } else { //限价 English: Price limit
            priceshow = model.avg_px + "/" + (model.px).toPricePrecision(withContractID: model.instrument_id)
        }
        self.forcePriceView.isHidden = !isLiquidate
        if isLiquidate {
            priceView.snp.updateConstraints { (make) in
                make.top.equalTo(sideTypeView.snp.bottom).offset(20 + 36)
            }
        }
        
        self.forcePriceView.rightLabel.text = model.forcedPrice.toPricePrecision(withContractID: model.instrument_id)
        self.priceView.leftLabel.text = priceTitle
        self.priceView.rightLabel.attributedText = priceshow.specailShow()
        
        //成交（ETH)/价值（USDT）或 成交（张)/价值（USDT） English: Transaction (ETH)/Value (USDT) or Transaction (Zhang)/Value (USDT)
        priceTitle = "cp_order_text60".ex_localized() + "/" + "cp_order_text102".ex_localized()

        //数量--  成交量/委托量 English: Quantity - trading volume/commission volume
       // 限价：成交/数量（ETH）或 成交/数量（张） Filled/Size     "cp_order_text60"="成交"/"cp_overview_text8" English: Price Limit: Transaction/Quantity (ETH) or Transaction/Quantity (sheet) Filled/Size "cpreorder_text60"="Transaction"/"cp-overview_text8"
        var volumTitle = "cp_order_text60".ex_localized() + "/" + "cp_overview_text8".ex_localized() + "(\(model.ex_contractInfo?.volumeUnit ?? ""))"
        var volumShow = model.cumQtyDisplay + "/" + model.qtyDisplay
        if model.isOpen() , let type = model.typeEnum, type == .market {
            // 市价：成交（ETH)/价值（USDT）或 成交（张)/价值（USDT）Filled/Size English: Market price: Completed/Size (ETH)/Value (USDT) or Completed/Value (USDT)
            volumTitle = "cp_order_text60".ex_localized() +  "(\(model.ex_contractInfo?.volumeUnit ?? ""))" + "/" + "cp_order_text102".ex_localized() + "(" + (model.ex_contractInfo?.openValueUnit ?? "") + ")"
            volumShow =  model.cumQtyDisplay + "/" + (model.qty).marketPriceVolPrecision(withContract:model.instrument_id) //(model.qty).toValuePrecision(withContract:model.instrument_id)
        }
        self.volumeView.leftLabel.text = volumTitle
        self.volumeView.rightLabel.attributedText = volumShow.specailShow()
        
        typeView.setRightText(model.typeEnum?.display ?? "" )
        //MARK: fix 叹号位置需调整 English: MARK: Fix exclamation mark position needs to be adjusted
//        typeView.showTipBtn = model.isLiquidate()
        
        profitandlossView.setLeftText("cp_order_text8".ex_localized() + "(" + (model.ex_contractInfo?.margin_coin ?? "") + ")")
        profitandlossView.rightLabel.setUpAndDownText(orderModel?.realizedAmount.toValuePrecision( withContract: model.instrument_id) ?? "")
        var fee = model.tradeFee
        if model.isAdd {
            fee = "+" + fee
        }
        withDrawView.showTipBtn = model.isCompensate
        withDrawView.rightLabel.text =  fee
        idLabelView.rightLabel.text =  model.id
        
    }
    

    /// 强平 English: /Qiangping
    @objc func clickDetailButton() {
        guard let tempOrderModel = self.orderModel else {
            return
        }
        
        let detailType = tempOrderModel.typeEnum
        if detailType != nil {
            EXSNormalAlert.alertShow(model: tempOrderModel, detailType: detailType!)
        }
    }
    
   
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

    ///Qiangping
    @objc func feeTip() {
        let alert = EXCommonAlert()
        alert.configAlert(title: "fee_tips".ex_localized(), message: nil, bottomOnlyOneBtn: true, alertCallBack: {_ in })
        EXAlert.showAlert(alertView: alert)
    }

}


