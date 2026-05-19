//
//  EXSwapCurrentOrderTableViewCell.swift
//  Chainup
//
//  Created by ZYJ on 2023/5/23.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
///Current commission for holding positions

class EXSwapCurrentOrderTableViewCell: UITableViewCell {
    /// 合约类型 English: /Contract type
    var transactionType: EXSwapTransactionType = .current {
        didSet {
            if transactionType == .current {
                self.cancelButton.isHidden = false
            } else {
                self.cancelButton.isHidden = true
            }
        }
    }
    
    /// 订单数据 English: /Order data
    var orderModel: EXContractOrderModel?
    
    /// 点击明细回调 English: /Click on the details callback
    var showDetailCallback: ((EXContractOrderModel, EXSwapMarketOrderType) -> ())?

    /// 撤单回调 English: /Cancellation callback
    var cancelOrderCallback: ((EXContractOrderModel) -> ())?

    
    lazy var progressView: EXCircleProgressView = {
        let v = EXCircleProgressView()
        return v
    }()
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
        let label = UILabel(text: nil, font: UIFont.ThemeFont.MinimumRegular, textColor: .Ex.main4, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.backgroundColor = UIColor.Ex.main3
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    
    ///只减仓 English: /Only reduce positions
    lazy var onlySubTypeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.MinimumRegular, textColor: .Ex.main4, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.text = "cp_order_text54".ex_localized()
        label.backgroundColor = UIColor.Ex.main3
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    /// 取消按钮 English: /Cancel button
    lazy var cancelButton: RepeatButton = {
        let button = RepeatButton(buttonType: .custom, title: "cp_order_text68".ex_localized(), titleFont: UIFont.ThemeFont.BodyBold, titleColor: UIColor.ThemeLabel.colorLite)
        button.backgroundColor = UIColor.ThemeView.card2
        button.layer.cornerRadius = 4
        button.ext_UseAutoLayout()
        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
    
    /// 减仓明细，强平明细 English: /Reduction details
    lazy var detailView: UIControl = {
        let detail = UIControl()
        let label = UILabel(text: "--", font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
        let imageView = UIImageView(image: UIImage.exs_themeImageNamed(imageName: "public_instructions"))
        imageView.contentMode = .scaleAspectFit
        detail.exs_addSubViews([label, imageView])
        
        label.snp.makeConstraints { (make) in
            make.left.top.height.equalToSuperview()
        }
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(label.snp.right).offset(5)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        detail.addTarget(self, action: #selector(clickDetailButton), for: .touchUpInside)
        detail.isHidden = true
        return detail
    }()
    
    lazy var promptView : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_instructions"), for: .normal)
        btn.addTarget(self, action: #selector(clickpromptButton), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    /// 委托价格 English: /Commission price
    lazy var priceView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.setLeftText("cp_overview_text30".ex_localized())
        view.rightLabel.textAlignment = .left
        view.leftLabel.snp_updateConstraints { make in
            make.left.equalTo(0)
        }
        return view
    }()
//    ///只减仓 English: /Only reduce positions
//    lazy var rightTopView: SLSwapHorDetailView = {
//        let view = SLSwapHorDetailView()
//        view.ext_UseAutoLayout()
//
//        view.setLeftText("cp_order_text54".ex_localized())
//        return view
//    }()
    
    /// 委托数量 SLSwapHorDetailView English: /Delegated quantity SLSwapHorDetailView
    lazy var volumeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.ext_UseAutoLayout()
        view.rightLabel.textAlignment = .left
        view.leftLabel.snp_updateConstraints { make in
            make.left.equalTo(0)
        }
        return view
    }()
    
    /// 止盈止损 English: /Stop profit and stop loss
    lazy var stopProfitView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryBold
        view.setLeftText("cp_overview_text12".ex_localized())
        view.rightLabel.textAlignment = .left
        view.leftLabel.snp_updateConstraints { make in
            make.left.equalTo(0)
        }
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
        self.contentView.backgroundColor = UIColor.ThemeView.card1
        self.ext_SetCell()
        self.contentView.exs_addSubViews(
            [dealTypeLabel, nameLabel, timeLabel, cancelButton,
             contractTypeLabel,onlySubTypeLabel,
             progressView,
             volumeView,
             priceView,
             stopProfitView,
             horLineView
            ])
//        promptView,dealAverageView,detailView]
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        let horMargin = 16
        dealTypeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin)
            make.top.equalToSuperview().offset(horMargin)
            make.width.equalTo(44)
            make.height.equalTo(36)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dealTypeLabel.snp.right).offset(8)
            make.height.equalTo(20)
            make.top.equalTo(dealTypeLabel)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-horMargin)
        }
        contractTypeLabel.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.width.equalTo(70)
            make.left.equalTo(nameLabel.snp.left)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        onlySubTypeLabel.snp.makeConstraints { make in
            make.left.equalTo(contractTypeLabel.snp.right).offset(5)
            make.centerY.equalTo(contractTypeLabel)
            make.height.equalTo(16)
            make.width.equalTo(70)
        }
        progressView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin)
            make.width.height.equalTo(46)
            make.top.equalTo(dealTypeLabel.snp.bottom).offset(33)
        }
        
        volumeView.snp.makeConstraints { make in
            make.left.equalTo(progressView.snp.right).offset(8)
            make.top.equalTo(contractTypeLabel.snp.bottom).offset(15)
            make.height.equalTo(16)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.width.equalTo(75)
            make.height.equalTo(34)
            make.right.equalToSuperview().offset(-horMargin)
            make.top.equalToSuperview().offset(72)
            make.left.equalTo(volumeView.snp.right).offset(horMargin)
        }
        
        priceView.snp.makeConstraints { (make) in
            make.top.equalTo(volumeView.snp.bottom).offset(10)
            make.left.right.height.equalTo(volumeView)
        }
       
        stopProfitView.snp.makeConstraints { (make) in
            make.top.equalTo(priceView.snp.bottom).offset(10)
            make.left.right.height.equalTo(volumeView)
        }

        horLineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
}
extension EXSwapCurrentOrderTableViewCell {
    func updateCell(model: EXContractOrderModel) {
        self.orderModel = model
      
        contractTypeLabel.text = model.typeEnum?.display ?? ""
        contractTypeLabel.titleResizeSize()
        self.dealTypeLabel.textColor = model.side.textColor
        self.dealTypeLabel.text = model.side.display1
        self.progressView.textColor = model.side.textColor
        self.nameLabel.text = model.showName()
        self.timeLabel.text = EXSDateTools.strToTimeString(model.created_at)
        if model.typeEnum == .market {
            self.priceView.setRightText(model.typeEnum?.display ?? "")
        }else{
            self.priceView.setRightText((model.px).toPricePrecision( withContractID: model.instrument_id))
        }
        onlySubTypeLabel.isHidden = !model.isOnlySubtract()
        onlySubTypeLabel.titleResizeSize()
        updateVolumeLabel(model: model)
        self.priceView.setLeftText("cp_order_text42".ex_localized())
        stopProfitView.setRightText("\(model.otoOrder.takerProfitTrigger)/\(model.otoOrder.stopLossTrigger)")
        if model.isSpecialType() {
            if let label = self.detailView.subviews.first as? UILabel {
                label.text = model.typeEnum?.display ?? ""
            }
        }
        
    }
    func updateVolumeLabel(model: EXContractOrderModel) {
        let sliderV = model.cumQtyDisplay.bigDiv(model.qtyDisplay)
        let sliderPercent = sliderV.toString(2).bigMul("100")  //+ "%"
       // self.progressView.progress = sliderPercent.StringToFloat()
        //print("sliderV = \(sliderV) sliderPercent=\(sliderPercent) StringToFloat =\(sliderPercent.StringToFloat())")
        self.progressView.setProgress(sliderPercent.StringToFloat())
        self.volumeView.leftLabel.text =  "cp_order_text43".ex_localized() + " (\(model.ex_contractInfo?.volumeUnit ?? ""))"
        
        self.volumeView.rightLabel.text = model.cumQtyDisplay + "/" + model.qtyDisplay

    }
}

extension EXSwapCurrentOrderTableViewCell {
    
    /// 点击明细 English: /Click on details
    @objc func clickDetailButton() {
        guard let tempOrderModel = self.orderModel else {
            return
        }
        let detailType = tempOrderModel.typeEnum
        if detailType != nil {
            self.showDetailCallback?(tempOrderModel, detailType!)
        }
    }
    
    /// 点击撤单 English: /Click to cancel the order
    @objc func clickCancelButton() {
        guard let tempOrderModel = self.orderModel else {
            return
        }
        self.cancelOrderCallback?(tempOrderModel)
    }
    
    /// 点击取消原因 English: /Click to cancel reason
    @objc func clickpromptButton() {
        let tipsStr = ""
        let alert = EXSNormalAlert()
        alert.configSigleAlert(title: "cp_content_text14".ex_localized(), message: tipsStr)
        EXAlert.showAlert(alertView: alert)
    }
}

