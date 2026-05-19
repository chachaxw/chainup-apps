//
//  EXQuantOrderListCell.swift
//  Chainup
//
//  Created by wangdong on 2023/1/29.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXQuantOrderListCell: UITableViewCell {
    
    var item:EXQuantStrategyListItem?
    typealias QuantBtnCallback = (String) -> ()
    var closeQuantCallback:QuantBtnCallback?
    var detailQuantCallback:QuantBtnCallback?
    
    
    lazy var symbolLabel: UILabel = {
        let lable = UILabel()
        lable.textColor = .Ex.text1
        lable.font = .Ex.medium(16)
        return lable
    }()
    
    lazy var statusLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.medium(14)
        lable.textColor = UIColor.ThemeLabel.colorMedium
        return lable
    }()
    
    
    lazy var gridProfitLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.regular(12)
        lable.textColor = .Ex.text2
        return lable
    }()
    
    lazy var gridProfitValueLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.medium(16)
        lable.textColor = .Ex.text1
        return lable
    }()
    
    lazy var annualizedYieldLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.regular(12)
        lable.textColor = .Ex.text2
        lable.text = "quant_annualized_yield".localized()
        return lable
    }()
    
    lazy var annualizedYieldValueLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.medium(16)
        lable.textColor = .Ex.text1
        return lable
    }()
    
    lazy var positionProfitLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.regular(12)
        lable.textColor = .Ex.text2
        return lable
    }()
    
    lazy var positionProfitValueLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.medium(16)
        lable.textColor = .Ex.text1
        return lable
    }()

    
    lazy var priceSectionLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.regular(12)
        lable.textColor = .Ex.text2
        lable.text = "quant_price_section".localized()
        return lable
    }()
    
    lazy var priceSectionValueLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.medium(14)
        lable.textColor = .Ex.text1
        return lable
    }()
    
    lazy var gridTypeLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.regular(12)
        lable.textColor = .Ex.text2
        lable.text = "quant_grid_type".localized()
        return lable
    }()
    
    lazy var gridTypeValueLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.medium(14)
        lable.textColor = .Ex.text1
        return lable
    }()
    
    lazy var initialAmountLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.regular(12)
        lable.textColor = .Ex.text2
        lable.text = "quant_initial_quote_amount".localized()
        return lable
    }()
    
    lazy var initialValueAmountLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.medium(14)
        lable.textColor = .Ex.text1
        return lable
    }()
    
    lazy var gridAmountLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.regular(12)
        lable.textColor = .Ex.text2
        lable.text = "quant_grid_amount".localized()
        return lable
    }()
    
    lazy var gridAmountValueLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.medium(14)
        lable.textColor = .Ex.text1
        return lable
    }()
    
    lazy var entrustDateLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.regular(12)
        lable.textColor = .Ex.text2
        lable.text = "quant_entrust_date".localized()
        return lable
    }()
    
    lazy var entrustDateValueLabel: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.medium(14)
        lable.textColor = .Ex.text1
        return lable
    }()

    lazy var runtimeLable: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.regular(12)
        lable.textColor = .Ex.text2
        lable.text = "quant_run_time".localized()
        return lable
    }()
    
    lazy var runtimeValueLable: UILabel = {
        let lable = UILabel()
        lable.font = .Ex.medium(14)
        lable.textColor = .Ex.text1
        return lable
    }()
    
    lazy var shareBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .Ex.fill3
        button.setTitleColor(.Ex.text1, for: .normal)
        button.titleLabel?.font = .Ex.medium(14)
        button.setTitle("contract_share_label".localized(), for: .normal)
        button.addTarget(self, action: #selector(shareBtnAction), for: .touchUpInside)
        button.extSetCornerRadius(4)
        return button
    }()
    
    
    lazy var stopQuantBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .Ex.fill3
        button.setTitle("quant_stop_strategy".localized(), for: .normal)
        button.setTitleColor(.Ex.text1, for: .normal)
        button.titleLabel?.font = .Ex.medium(14)
        button.extSetCornerRadius(4)
        button.addTarget(self, action: #selector(closeBtnTouched), for: .touchUpInside)
        return button
    }()
    
    lazy var detailQuantBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .Ex.fill3
        button.titleLabel?.font = .Ex.medium(14)
        button.setTitleColor(.Ex.text1, for: .normal)
        button.setTitle("quant_view_detail".localized(), for: .normal)
        button.extSetCornerRadius(4)
        button.addTarget(self, action: #selector(detailBtnTouched), for: .touchUpInside)
        return button
    }()
   
    lazy var seperate4: UIView = {
        let lable = UIView()
        lable.backgroundColor = .Ex.fill4
        return lable
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }


    
    func setUI()  {
        
        let coinStackView: UIStackView  = horStackView(leftView: symbolLabel, rightView: statusLabel)
        coinStackView.isLayoutMarginsRelativeArrangement = true
        coinStackView.layoutMargins = UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 0)
        addSubview(coinStackView)
        coinStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        

        let contanerStackView = UIStackView()
        contanerStackView.distribution = .equalSpacing
        contanerStackView.addArrangedSubviews(
            [verStackView(topView: gridProfitLabel, bottomView: gridProfitValueLabel),
             verStackView(topView: annualizedYieldLabel, bottomView: annualizedYieldValueLabel),
             verStackView(topView: positionProfitLabel, bottomView: positionProfitValueLabel, alignment: .trailing)])
        
        addSubview(contanerStackView)
        contanerStackView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(coinStackView.snp.bottom).offset(11)
        }
        
    
        
        let priceSectionStackView: UIStackView  = horStackView(leftView: priceSectionLabel, rightView: priceSectionValueLabel)
        priceSectionStackView.isLayoutMarginsRelativeArrangement = true
        priceSectionStackView.layoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        addSubview(priceSectionStackView)
        priceSectionStackView.snp.makeConstraints { make in
            make.top.equalTo(contanerStackView.snp.bottom).offset(11)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        let gridTypeSectionStackView: UIStackView  = horStackView(leftView: gridTypeLabel, rightView: gridTypeValueLabel)
        gridTypeSectionStackView.isLayoutMarginsRelativeArrangement = true
        gridTypeSectionStackView.layoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        addSubview(gridTypeSectionStackView)
        gridTypeSectionStackView.snp.makeConstraints { make in
            make.top.equalTo(priceSectionStackView.snp.bottom)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        let initialSectionStackView: UIStackView  = horStackView(leftView: initialAmountLabel, rightView: initialValueAmountLabel)
        initialSectionStackView.isLayoutMarginsRelativeArrangement = true
        initialSectionStackView.layoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        addSubview(initialSectionStackView)
        initialSectionStackView.snp.makeConstraints { make in
            make.top.equalTo(gridTypeSectionStackView.snp.bottom)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        let gridAmountSectionStackView: UIStackView  = horStackView(leftView: gridAmountLabel, rightView: gridAmountValueLabel)
        gridAmountSectionStackView.isLayoutMarginsRelativeArrangement = true
        gridAmountSectionStackView.layoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        addSubview(gridAmountSectionStackView)
        gridAmountSectionStackView.snp.makeConstraints { make in
            make.top.equalTo(initialSectionStackView.snp.bottom)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        let entrustDateSectionStackView: UIStackView  = horStackView(leftView: entrustDateLabel, rightView: entrustDateValueLabel)
        entrustDateSectionStackView.isLayoutMarginsRelativeArrangement = true
        entrustDateSectionStackView.layoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        addSubview(entrustDateSectionStackView)
        entrustDateSectionStackView.snp.makeConstraints { make in
            make.top.equalTo(gridAmountSectionStackView.snp.bottom)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        let runtimeSectionStackView: UIStackView  = horStackView(leftView: runtimeLable, rightView: runtimeValueLable)
        runtimeSectionStackView.isLayoutMarginsRelativeArrangement = true
        runtimeSectionStackView.layoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        addSubview(runtimeSectionStackView)
        runtimeSectionStackView.snp.makeConstraints { make in
            make.top.equalTo(entrustDateSectionStackView.snp.bottom)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        

        
        let btnStackView = UIStackView()
        btnStackView.distribution = .fillEqually
        btnStackView.spacing = 8
        btnStackView.addArrangedSubviews([shareBtn, stopQuantBtn,detailQuantBtn])
        addSubview(btnStackView)
        btnStackView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(runtimeSectionStackView.snp.bottom).offset(14)
            make.height.equalTo(36)
        }
        
        addSubview(seperate4)
        seperate4.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(btnStackView.snp.bottom).offset(20)
            make.height.equalTo(0.5)
        }
        
        
    }
    
    func verStackView(topView:UIView,bottomView: UIView, alignment:UIStackView.Alignment = .leading) -> UIStackView{
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = alignment
        stackView.addArrangedSubviews([topView,bottomView])
        return stackView
    }
    
    func horStackView(leftView: UIView, rightView: UIView, edgeInsets: UIEdgeInsets =  UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)) -> UIStackView{
        
        let stackView: UIStackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.addArrangedSubviews([leftView,rightView])
        return stackView
    }
}

extension EXQuantOrderListCell {
    
   
    @objc func closeBtnTouched() {
        guard let sid = self.item?.id else { return }
        self.closeQuantCallback?(sid)
    }
    
    @objc func detailBtnTouched() {
        guard let sid = self.item?.id else { return }
        self.detailQuantCallback?(sid)
    }
    
    @objc func shareBtnAction() {
        guard let model = self.item else {
            return
        }
        
        let shareMode = EXQuantShareModel.getQuantShareModel(item:model)
        let alert = EXNewQuantShareAlert()
        alert.bindShareModels(model: shareMode)
        EXAlert.showAlert(alertView: alert)
    }
    
    func bindItems(item:EXQuantStrategyListItem) {
        self.item = item
        let coinmap = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(item.symbol)
        symbolLabel.text = item.symbol.aliasCoinMapName()
        statusLabel.text = item.getStatus()
        
        let rstValue = item.totalProfit.decimalString(value: 6,alwaysRounding: true)
        
        gridProfitValueLabel.textColor = getValueColor(value: rstValue)
        gridProfitValueLabel.text = item.fmtValue(rstValue)

        let yieldRst = item.annualizedYield.decimalString(value: 2,alwaysRounding: true)
        annualizedYieldValueLabel.textColor = getValueColor(value: yieldRst)
        annualizedYieldValueLabel.text = yieldRst + "%"
        
        let positionRst = item.positionProfit.decimalString(value:6,alwaysRounding: true)
        
        positionProfitValueLabel.textColor = getValueColor(value: positionRst)
        positionProfitValueLabel.text = item.fmtValue(positionRst)
        
        entrustDateValueLabel.text = DateTools.strToTimeString(item.ctime)
        
        var endTime = item.endTime
//        if item.strategyStatus == "1" {//running / 3 end
            endTime = DateTools.getMillTimeInterval()//与安卓端保持一致，安卓端取的系统时间
//        }
        runtimeValueLable.text =  DateTools.updateTimeToCurrennTime(timeStamp:NumberHandler.handleDouble(item.startTime), endTimeStamp: NumberHandler.handleDouble(endTime),isPravate: true)
        gridProfitLabel.text = "quant_grid_profit".localized() + "(\(coinmap.marketName.aliasName()))"
        positionProfitLabel.text = "quant_position_profit".localized() + "(\(coinmap.marketName.aliasName()))"

       

        if item.strategyStatus == "1" || item.strategyStatus == "0" {
            stopQuantBtn.isHidden = false
        }else {
            stopQuantBtn.isHidden = true
        }
        if let mapModel = item.configParamMap {
            let lowP = mapModel.lowestPrice.decimalString(value: coinmap.priceDecimal())
            let highP = mapModel.highestPrice.decimalString(value: coinmap.priceDecimal())
            priceSectionValueLabel.text = lowP + "-" + highP

            if mapModel.gridLineType == "1" {
                gridTypeValueLabel.text = "quant_grid_line_type1".localized()
            }else if mapModel.gridLineType == "2" {
                gridTypeValueLabel.text = "quant_grid_line_type2".localized()
            }
            if mapModel.totalBaseAmount.count > 0 {
                initialValueAmountLabel.text = mapModel.totalQuoteAmount.decimalString(value: coinmap.priceDecimal()) + coinmap.marketName.aliasName() + "+" + mapModel.totalBaseAmount.decimalString(value: coinmap.volDecimal()) + coinmap.coinName.aliasName()
            }else {
                initialValueAmountLabel.text = mapModel.totalQuoteAmount.decimalString(value: coinmap.priceDecimal()) + coinmap.marketName.aliasName()
            }
            gridAmountValueLabel.text = mapModel.gridNumber.decimalString(value: 0)
        }
        
        
    }
    
    
    func getValueColor(value: String) ->UIColor {
        if value.isBiggerThan("0") {
            return .Ex.up1
        }else if value.isEquals("0") {
            return .Ex.text1
        }else {
            return .Ex.down1
        }
    }
    
}
