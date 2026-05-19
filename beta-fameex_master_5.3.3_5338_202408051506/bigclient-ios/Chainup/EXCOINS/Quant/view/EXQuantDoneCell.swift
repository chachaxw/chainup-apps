//
//  EXQuantDoneCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/7.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXQuantDoneCell: UITableViewCell {
    
    typealias QuantExpandCallback = (Bool) -> ()
    var expandCallback:QuantExpandCallback?
    
    lazy var expandBar:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = UIColor.ThemeView.bg
        btn.addTarget(self, action: #selector(expandCellAction(sender:)), for: .touchUpInside)
        btn.isSelected = false
        return btn
    }()
    
    lazy var contentBuyBg:UIView = {
        let btn = UIView()
        btn.backgroundColor = UIColor.ThemeView.bg
//        btn.backgroundColor = UIColor.green
        btn.clipsToBounds = true
        return btn
    }()
    
    lazy var bottomLine:UIView = {
        let btn = UIView()
        btn.backgroundColor = UIColor.ThemeView.seperator
//        btn.backgroundColor = UIColor.green
        return btn
    }()
    
    lazy var contentSellBg:UIView = {
        let btn = UIView()
        btn.backgroundColor = UIColor.ThemeView.bg
//        btn.backgroundColor = UIColor.red
        btn.clipsToBounds = true
        return btn
    }()
    
    lazy var timeL:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.font  = UIFont.ThemeFont.BodyMedium
        l.textColor = UIColor.ThemeLabel.colorMedium
        return l
    }()
    
    lazy var profitsL:UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.font  = UIFont.ThemeFont.BodyMedium
        l.textColor = UIColor.ThemeLabel.colorMedium
        return l
    }()
    
    lazy var arrowIcon:UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage.themeImageNamed(imageName: "transaction_triangle_down")
        return icon 
    }()
    
    lazy var buyTitle:UILabel = {
        let t = UILabel.init()
        t.text = "contract_action_buy".localized()
        t.font  = UIFont.ThemeFont.SecondaryBold
        t.textColor = UIColor.ThemekLine.up
        return t
    }()
    
    lazy var buyTimeL:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.font  = UIFont.ThemeFont.BodyMedium
        l.textColor = UIColor.ThemeLabel.colorMedium
        return l
    }()
    
    lazy var sellTitle:UILabel = {
        let t = UILabel.init()
        t.text = "contract_action_sell".localized()
        t.font  = UIFont.ThemeFont.SecondaryBold
        t.textColor = UIColor.ThemekLine.down
        return t
    }()
    
    lazy var sellTimeL:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.font  = UIFont.ThemeFont.BodyMedium
        l.textColor = UIColor.ThemeLabel.colorMedium
        return l
    }()
    
    lazy var buyArea:EXThreeColumnView = {
        let rowA = EXThreeColumnView()
        return rowA
    }()
    
    lazy var sellArea:EXThreeColumnView = {
        let rowB = EXThreeColumnView()
        return rowB
    }()
    
    var modelItem:EXOrderedGridListItem = EXOrderedGridListItem()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        self.contentView.addSubview(expandBar)
        expandBar.addSubViews([timeL,profitsL,arrowIcon])

        expandBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(42)
        }
        timeL.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT)
            make.centerY.equalToSuperview()
        }
        
        profitsL.snp.makeConstraints { (make) in
            make.right.equalTo(arrowIcon.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        
        arrowIcon.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-MARGIN_LEFT)
            make.centerY.equalToSuperview()
        }
        self.contentView.addSubview(contentBuyBg)
        self.contentView.addSubview(contentSellBg)
        self.contentView.addSubview(bottomLine)
        
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
            make.left.equalTo(MARGIN_LEFT)
            make.right.equalTo(-MARGIN_LEFT)
        }

        contentBuyBg.snp.makeConstraints { (make) in
            make.top.equalTo(expandBar.snp.bottom).offset(2)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(70)
        }
        
        contentSellBg.snp.makeConstraints { (make) in
            make.top.equalTo(contentBuyBg.snp.bottom).offset(14)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(70)
        }
        
        contentBuyBg.addSubview(buyTitle)
        contentBuyBg.addSubview(buyTimeL)
        contentBuyBg.addSubview(buyArea)
        contentSellBg.addSubview(sellTitle)
        contentSellBg.addSubview(sellTimeL)
        contentSellBg.addSubview(sellArea)
        buyTitle.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT)
            make.top.equalToSuperview()
            make.height.equalTo(18)
        }
        
        buyTimeL.snp.makeConstraints { (make) in
            make.left.equalTo(buyTitle.snp.right).offset(10)
            make.centerY.equalTo(buyTitle)
            make.right.lessThanOrEqualToSuperview().offset(-MARGIN_LEFT)
        }
        
        buyArea.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT)
            make.top.equalTo(buyTitle.snp.bottom).offset(14)
            make.height.equalTo(35)
            make.width.equalTo(SCREEN_WIDTH - MARGIN_LEFT_DOUBLE)
        }
        
        sellTitle.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT)
            make.top.equalToSuperview()
            make.height.equalTo(18)
        }
        
        sellTimeL.snp.makeConstraints { (make) in
            make.left.equalTo(sellTitle.snp.right).offset(10)
            make.centerY.equalTo(sellTitle)
            make.right.lessThanOrEqualToSuperview().offset(-MARGIN_LEFT)
        }
        
        sellArea.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT)
            make.top.equalTo(sellTitle.snp.bottom).offset(14)
            make.height.equalTo(35)
            make.width.equalTo(SCREEN_WIDTH - MARGIN_LEFT_DOUBLE)
        }
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
    
    func getStyle()->ExThreeColumnStyle {
        let style = ExThreeColumnStyle()
        style.topLabelFont = UIFont.ThemeFont.MinimumRegular
        style.topLabelColor = UIColor.ThemeLabel.colorMedium
        style.bottomLabelFont = UIFont.ThemeFont.SecondaryMedium
        style.bottomLabelColor = UIColor.ThemeLabel.colorLite
        return style
    }
    
    func bindListItem(model:EXOrderedGridListItem,expand:Bool = false){
        //https://jira.hiotc.pro/browse/CHAINUP-14524
        let coinmap = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(model.symbol)

        let fmtStr = DateTools.strToTimeString(model.buyTime)
        timeL.text = fmtStr

        //Quant_order_waiting_sell "=" Waiting to sell ";
        //Quant_order_closedunotSold "=" Terminated, not sold ";
//        if model.isWaitingSell() {
//            profitsL.textColor = UIColor.ThemeLabel.colorLite
//            profitsL.text = "quant_order_waiting_sell".localized()
//        }else if model.isNotSold() {
//            profitsL.textColor = UIColor.ThemeLabel.colorDark
//            profitsL.text = "quant_order_closed_notSold".localized()
//        }else if model.isWaitingBuy() {
//            profitsL.textColor = UIColor.ThemeLabel.colorLite
//            profitsL.text = "quant_order_closed_notBuy".localized()
//        }else {
            if model.profit.count > 0 {
                let rstValue = model.profit.decimalString(value: 6,alwaysRounding: true)
                profitsL.textColor = rstValue.getValueColor()
                profitsL.text = rstValue.plusSymbolStr()
            }else {
                profitsL.text = "--"
            }
//        }

        self.modelItem = model
        expandBar.isSelected = expand
        configArrow(expand: model.isExpand)
        if expand {
            contentBuyBg.isHidden = model.buyOrder.isEmptyItem()
            contentSellBg.isHidden = model.sellOrder.isEmptyItem()
            if model.buyOrder.isEmptyItem() {
                contentSellBg.snp.remakeConstraints { (make) in
                    make.top.equalTo(expandBar.snp.bottom).offset(2)
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.height.equalTo(70)
                }
            }else {
                contentSellBg.snp.makeConstraints { (make) in
                    make.top.equalTo(contentBuyBg.snp.bottom).offset(14)
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.height.equalTo(70)
                }
            }
            
            buyTimeL.text = fmtStr
            sellTimeL.text = DateTools.strToTimeString(model.sellOrder.orderCtime)
            var models:[ExThreeColumnDataModel] = []
            let modell = ExThreeColumnDataModel()
            modell.title = "contract_text_dealAverage".localized() + "(\(coinmap.marketName.aliasName()))"
            modell.content = model.buyOrder.avgPrice.decimalString(value: coinmap.priceDecimal())
            modell.style = self.getStyle()
            models.append(modell)
            
            let modelm = ExThreeColumnDataModel()
            modelm.title = "transaction_text_dealNum".localized() + "(\(coinmap.coinName.aliasName()))"
            modelm.content = model.buyOrder.dealVolume.decimalString(value: coinmap.volDecimal())
            modelm.style = self.getStyle()
            models.append(modelm)
            
            let modelr = ExThreeColumnDataModel()
            modelr.title = "sl_str_deal_money".localized() + "(\(coinmap.marketName.aliasName()))"
            modelr.content = model.buyOrder.dealMoney.decimalString(value:6)
            modelr.style = self.getStyle()
            models.append(modelr)
            
            buyArea.bindItems(with: models,ignoreModelCount: true)
            
            var sellModels:[ExThreeColumnDataModel] = []

            let selll = ExThreeColumnDataModel()
            selll.title = "contract_text_dealAverage".localized() + "(\(coinmap.marketName.aliasName()))"
            selll.content = model.sellOrder.avgPrice.decimalString(value: coinmap.priceDecimal())
            selll.style = self.getStyle()
            sellModels.append(selll)
            
            let sellm = ExThreeColumnDataModel()
            sellm.title = "transaction_text_dealNum".localized() + "(\(coinmap.coinName.aliasName()))"
            sellm.content = model.sellOrder.dealVolume.decimalString(value: coinmap.volDecimal())
            sellm.style = self.getStyle()
            sellModels.append(sellm)
            
            let sellr = ExThreeColumnDataModel()
            sellr.title = "sl_str_deal_money".localized() + "(\(coinmap.marketName.aliasName()))"
            sellr.content = model.sellOrder.dealMoney.decimalString(value:6)
            sellr.style = self.getStyle()
            sellModels.append(sellr)
            sellArea.bindItems(with: sellModels)
        }else {
            contentBuyBg.isHidden = true
            contentSellBg.isHidden = true
        }
    }
    
    class func getDoneCellHeightFor(model:EXOrderedGridListItem) -> CGFloat {
        if model.isExpand {
            if model.buyOrder.isEmptyItem() || model.sellOrder.isEmptyItem() {
                return 140
            }
            return 210
        }else {
            return 42
        }
    }
    
    func configArrow(expand:Bool) {
        if expand {
            arrowIcon.image = UIImage.themeImageNamed(imageName: "transaction_triangle_up")
        }else {
            arrowIcon.image = UIImage.themeImageNamed(imageName: "transaction_triangle_down")
        }
    }
    
    @objc func expandCellAction(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        configArrow(expand: sender.isSelected)
        self.expandCallback?(sender.isSelected)
    }

}

