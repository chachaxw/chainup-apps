//
//  EXQuantPendingOrderCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/5.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXQuantProgessView: UIView {

    var margin:CGFloat = 4.0
    
    var progress: CGFloat = 0.0 {

        didSet {
            setProgress()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    func setup() {
        self.backgroundColor = UIColor.ThemeView.bg
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        setProgress()
    }

    func setProgress() {
        var progress = min(self.progress,100)
        if progress < 0.0 {
            progress = CGFloat(fabsf(Float(progress)))
        }
        progress = progress > 1.0 ? progress / 100 : progress
        
        var width = (self.frame.width - margin*2)  * progress
        let height:CGFloat = 5

//        if (width < height) {
//            width = height
//        }
        
        let pathBg = UIBezierPath(roundedRect: CGRect(x: margin, y: 14, width: self.frame.width - margin*2, height: height), cornerRadius: height / 2.0)

        if progress <= 0.0 {
            UIColor.ThemeNav.bg.setFill()
            pathBg.fill()
        }else {
            UIColor.ThemeState.fail.setFill()
            pathBg.fill()
        }


        UIColor.clear.setStroke()
        pathBg.stroke()

        pathBg.close()
        
//        print("==》\(width)")
        let pathRef = UIBezierPath(roundedRect: CGRect(x: margin, y: 14, width: width , height: height), cornerRadius: height / 2.0)

        if progress <= 0.0 {
            UIColor.ThemeNav.bg.setFill()
            pathRef.fill()
        }else {
            UIColor.ThemeState.success.setFill()
            pathRef.fill()
        }


        UIColor.clear.setStroke()
        pathRef.stroke()

        pathRef.close()
        if progress > 0.0 {
            let icon = UIImage.themeImageNamed(imageName: "gridtrading_mark")
            icon.draw(in: CGRect(x: width, y: 4, width: 8, height: 6))
        }

        self.setNeedsDisplay()
    }
}

class EXQuantPendingInfo:UIView {
    
    var info:EXQuantStrategyListItem = EXQuantStrategyListItem()
    var coinMap:CoinMapEntity = CoinMapEntity()
    
    lazy var infoViewRowA: EXThreeColumnView = {
        let rowA = EXThreeColumnView()
        rowA.bottomRight.textAlignment = .center
        return rowA
    }()
    
    lazy var infoViewRowB: EXThreeColumnView = {
        let rowA = EXThreeColumnView()
        rowA.bottomRight.textAlignment = .center
        return rowA
    }()
    
    lazy var symbolTitle:UILabel = {
        let title = UILabel()
        title.font = UIFont.ThemeFont.BodyMedium
        title.textColor = UIColor.ThemeLabel.colorLite
        return title
    }()
    
    lazy var progress:EXQuantProgessView = {
        let progress = EXQuantProgessView()
        return progress
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    func configUI() {
        self.addSubViews([infoViewRowA,infoViewRowB,symbolTitle,progress])
        infoViewRowA.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(36)
        }
        
        infoViewRowB.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(infoViewRowA.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(36)
        }
        
        symbolTitle.snp.makeConstraints { (make) in
            make.top.equalTo(infoViewRowB.snp.bottom).offset(26)
            make.left.equalTo(15)
            make.height.equalTo(18)
        }
        
        progress.snp.makeConstraints { (make) in
            make.left.equalTo(11)
            make.height.equalTo(20)
            make.top.equalTo(symbolTitle.snp.bottom)
            make.right.equalToSuperview().offset(-11)
        }
        
        symbolTitle.isHidden = true
        progress.isHidden = true
    }
    
    
    func bindItems(info:EXQuantStrategyListItem,coinMap:CoinMapEntity) {
        self.info = info
        self.coinMap = coinMap
        var models:[ExThreeColumnDataModel] = []
        let style = ExThreeColumnDataModel.getCommonStyle()
        let modell = ExThreeColumnDataModel()
        modell.title = "quant_order_pending_freeze".localized() + "(\(coinMap.marketName.aliasName()))"
        if info.freezQuoteAmount.isEmpty {
            info.freezQuoteAmount = "0"
        }
        if info.freezBaseAmount.isEmpty{
            info.freezBaseAmount = "0"
        }
        modell.content = info.freezQuoteAmount.decimalString(value: coinMap.priceDecimal())
        modell.style = style
        models.append(modell)
        let modelm = ExThreeColumnDataModel()
        modelm.title = "quant_order_pending_freeze".localized() + "(\(coinMap.coinName.aliasName()))"
        modelm.content = info.freezBaseAmount.decimalString(value: coinMap.volDecimal())
        modelm.style = style
        models.append(modelm)
        
        let modelr = ExThreeColumnDataModel()
        modelr.title = "quant_order_pending_dailycount".localized()
        let timeForAday = info.yesterdayProfitTimes.count > 0 ? info.yesterdayProfitTimes : "0"
        modelr.content = timeForAday + " " + "otc_other_times".localized()
        modelr.style = style
        models.append(modelr)
        
        infoViewRowA.bindItems(with: models,ignoreModelCount: true)
        
        //Quant_stop_high_price "=" Stop Profit Price ";
        //Quant_stop_low_price "=" Stop Loss Price ";
        var modelsB:[ExThreeColumnDataModel] = []
        let modellb = ExThreeColumnDataModel()
        modellb.title = "quant_stop_high_price".localized()
        if let stopHigh = info.configParamMap?.stopHighPrice,stopHigh.count > 0 {
            modellb.content = stopHigh == "0" ? "quant_order_setting_off".localized() : stopHigh
        }else {
            modellb.content = "quant_order_setting_off".localized()
        }
        modellb.style = style
        modelsB.append(modellb)
        let modelmb = ExThreeColumnDataModel()
        modelmb.title = "quant_stop_low_price".localized()
        if let stopLow = info.configParamMap?.stopLowPrice,stopLow.count > 0 {
            modelmb.content = stopLow == "0" ? "quant_order_setting_off".localized() : stopLow
        }else {
            modelmb.content = "quant_order_setting_off".localized()
        }
        modelmb.style = style
        modelsB.append(modelmb)
        
        let modelrb = ExThreeColumnDataModel()
        modelrb.title = "quant_order_pending_totalcount".localized()
        let timeForAll = info.totalProfitTimes.count > 0 ? info.totalProfitTimes : "0"

        modelrb.content = timeForAll + " " + "otc_other_times".localized()
        modelrb.style = style
        modelsB.append(modelrb)
        
        infoViewRowB.bindItems(with: modelsB,ignoreModelCount: true)
        symbolTitle.text = coinMap.showName
    }
    
    func updatePrice(closeP:String,buyOne:String,sellOne:String) {
        symbolTitle.isHidden = false
        progress.isHidden = false
        let rst = closeP.decimalString(value: coinMap.priceDecimal())
        symbolTitle.text = coinMap.showName + "=\(rst)"
        if buyOne.count > 0, sellOne.count > 0 {
            let numberA = rst.stringBySubtracting(sub: buyOne, decimal: -1)
            let numberB = sellOne.stringBySubtracting(sub: buyOne, decimal: -1)
            let rst = numberA.stringByDividing(divide: numberB, decimal: 2, roundDown: true).StringToFloat()
            //Current price=buy for a while, result is 0. progress should be 0
            if numberA.isEquals("0") {
                self.progress.progress = 0.00001
            }else {
                self.progress.progress = rst
            }
        }else if buyOne.count > 0,sellOne.count == 0 {
            self.progress.progress = 1
        }else if buyOne.count == 0,sellOne.count > 0 {
            self.progress.progress = 0.00001
        }else {
            self.progress.progress = 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXQuantPendingHeader: UIView {
    
    lazy var numberL:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.font  = UIFont.ThemeFont.MinimumRegular
        l.textColor = UIColor.ThemeLabel.colorDark
        return l
    }()
    
    lazy var numberR:UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.font  = UIFont.ThemeFont.MinimumRegular
        l.textColor = UIColor.ThemeLabel.colorDark
        return l
    }()
    
    lazy var buyLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.textColor = UIColor.ThemeLabel.colorDark
        l.font  = UIFont.ThemeFont.MinimumRegular
        return l
    }()
    
    lazy var sellLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.textColor = UIColor.ThemeLabel.colorDark
        l.font  = UIFont.ThemeFont.MinimumRegular
        return l
    }()
    
    lazy var distanceLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = UIColor.ThemeLabel.colorDark
        l.font  = UIFont.ThemeFont.MinimumRegular
        l.text = "quant_order_pending_dealDistance".localized()
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    func configUI() {
        self.addSubViews([numberL,numberR,distanceLabel,buyLabel,sellLabel])
        
        let beginBuyX = SCREEN_WIDTH * 0.146
        
        numberL.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalToSuperview()
        }
        
        numberR.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.top.equalToSuperview()
        }
        
        distanceLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        buyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(beginBuyX)
            make.top.equalToSuperview()
            make.right.lessThanOrEqualTo(sellLabel.snp.left).offset(-5)
        }
        
        sellLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-beginBuyX)
            make.top.equalToSuperview()
        }
    }
    
    func bindTitle(buyT:String,buyP:String,sellP:String,sellT:String) {
        numberL.text = buyT
        numberR.text = sellT
        buyLabel.text = buyP
        sellLabel.text = sellP
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class EXQuantPendingOrderCell: UITableViewCell {

    lazy var numberL:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.font  = UIFont.ThemeFont.SecondaryMedium
        l.textColor = UIColor.ThemeLabel.colorLite
        return l
    }()
    
    lazy var numberR:UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.font  = UIFont.ThemeFont.SecondaryMedium
        l.textColor = UIColor.ThemeLabel.colorLite
        return l
    }()
    
    lazy var buyLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.textColor = UIColor.ThemekLine.up
        l.font  = UIFont.ThemeFont.SecondaryMedium
        return l
    }()
    
    lazy var sellLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.textColor = UIColor.ThemekLine.down
        l.font  = UIFont.ThemeFont.SecondaryMedium
        return l
    }()
    
    lazy var distanceBuy:UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = UIColor.ThemekLine.up
        l.font  = UIFont.ThemeFont.SecondaryMedium
        return l
    }()
    
    lazy var distanceSell:UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = UIColor.ThemekLine.down
        l.font  = UIFont.ThemeFont.SecondaryMedium
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        configUI()
    }
    
    func configUI() {
        self.contentView.addSubViews([numberL,buyLabel,distanceBuy,distanceSell,sellLabel,numberR])
        let beginBuyX = SCREEN_WIDTH * 0.146
        
        numberL.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalToSuperview()
        }
        
        numberR.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.top.equalToSuperview()
        }
        
        distanceBuy.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.centerX).offset(-9)
            make.top.equalToSuperview()
        }
        
        distanceSell.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(9)
            make.top.equalToSuperview()
        }
        
        buyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(beginBuyX)
            make.top.equalToSuperview()
            make.right.lessThanOrEqualTo(sellLabel.snp.left).offset(-5)
        }
        
        sellLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-beginBuyX)
            make.top.equalToSuperview()
        }
    }
    
    func bind(buy:String,sell:String,idx:String,cprice:String) {
        buyLabel.text = buy
        if buy.count > 0 {
            numberL.text = idx
            if cprice.count > 0 {
                let numberA = buy.stringByDividing(divide: cprice, decimal: -1, roundDown: true)
                var rst = "1".stringBySubtracting(sub: numberA, decimal: -1).stringByMultiplying(multiple: "100", decimal: 2,holdZero: true,useRoundPlain: false)
                if rst.contains("-") {
                    rst = "\(rst)%"
                }else {
                    rst = "-\(rst)%"
                }
                distanceBuy.text = "\(rst)"
            }
        }else {
            numberL.text = ""
            distanceBuy.text = ""
        }
        sellLabel.text = sell
        if sell.count > 0 {
            numberR.text = idx
            if cprice.count > 0 {
                let rst = sell.stringByDividing(divide: cprice, decimal: -1, roundDown: true).stringBySubtracting(sub: "1", decimal: -1).stringByMultiplying(multiple: "100", decimal: 2,holdZero: true,useRoundPlain: false)
                if rst.contains("-") {
                    distanceSell.text = "\(rst)%"
                }else {
                    distanceSell.text = "+\(rst)%"
                }
            }
        }else {
            numberR.text = ""
            distanceSell.text = ""
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setPercentage()
    }
    
    func setPercentage() {
        
    }
}

