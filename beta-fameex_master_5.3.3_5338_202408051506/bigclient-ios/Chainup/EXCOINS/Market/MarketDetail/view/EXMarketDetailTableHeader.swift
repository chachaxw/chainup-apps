//
//  EXMarketDetailTableHeader.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/19.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

enum MarketDetailActionType {
    case fullscreen
}

class EXMarketDetailTableHeader: NibBaseView {
    
    @IBOutlet var klineView: EXKLineView!
    let scaleDrop = EXScaleDropView()
    let algorithmDrop = EXAlgorithmDropView()
    var symbol = ""
    var entity:CoinMapEntity =  CoinMapEntity()
    {
        didSet{
            self.showNetWorth(entity.etfOpen == "1")
            if symbol != entity.symbol{
                symbol = entity.symbol
            }
        }
    }
    @IBOutlet var zoomBtn: UIButton!
    
    let scalePublish : PublishSubject<String> = PublishSubject.init()
    let masterType : PublishSubject<MasterAlgorithmType> = PublishSubject.init()
    let assistantType : PublishSubject<AssistantAlgorithmType> = PublishSubject.init()

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var rmbLabel: UILabel!
    @IBOutlet var changeTitle: UILabel!
    @IBOutlet var changeValue: UILabel!
    @IBOutlet var timeChangeTitle: UILabel!
    @IBOutlet var timeValue: UILabel!
    @IBOutlet var hTitle: UILabel!
    @IBOutlet var hValue: UILabel!
    @IBOutlet var ltitle: UILabel!
    @IBOutlet var lvalue: UILabel!
    @IBOutlet var etfRateTitle: UILabel!
    @IBOutlet var etfRateValue: UILabel!
    @IBOutlet var networthTitle: UILabel!
    @IBOutlet var networthValue: UILabel!
    @IBOutlet var leftContainerHeight: NSLayoutConstraint!
    @IBOutlet var rightContainerHeight: NSLayoutConstraint!
    
    @IBOutlet var scaleChangeControl: EXTriangleIndicator!
    @IBOutlet var indexChangeControl: EXTriangleIndicator!
    
    typealias MarketDetailAction = (MarketDetailActionType) -> ()
    var tableHeaderAction : MarketDetailAction?
    var menuModel = EXMenuSelectionModel.init() {
        didSet {
            scaleChangeControl.setTitle(content:menuModel.scaleKey.localized())
            klineView.updateMasterAlgorithm(to: menuModel.masterType)
            klineView.updateAssistantAlgorithm(to: menuModel.assitantType)
            scaleDrop.menuModel = menuModel
            algorithmDrop.menuModel = menuModel
        }
    }

    func bindDecimal(price:String,volume:String) {
        klineView.priceDecimal = price
        klineView.volumeDecimal = volume
    }
    
    override func onCreate() {
        self.configTopHeaderUI()
        scaleChangeControl.textNormalColor = UIColor.ThemeLabel.colorLite
        scaleChangeControl.textHighLightColor = UIColor.ThemeLabel.colorLite
        indexChangeControl.textNormalColor = UIColor.ThemeLabel.colorLite
        indexChangeControl.textHighLightColor = UIColor.ThemeLabel.colorLite
        scaleChangeControl.setTitle(content:"30" + "noun_date_minute".localized())
        indexChangeControl.setTitle(content:"kline_text_scale".localized())
        klineView.chartsView.backgroundColor = UIColor.ThemeView.bg
        zoomBtn.setImage(UIImage.themeImageNamed(imageName: "quotes_zoom"), for: .normal)
        priceLabel.font = self.themeHNBoldFont(size: 28)
        rmbLabel.font = self.themeHNFont(size: 14)
        rmbLabel.textColor = UIColor.ThemeLabel.colorMedium
        
    }
    
    func configTopHeaderUI() {
        
        changeTitle.secondaryRegular()
        changeTitle.textColor = UIColor.ThemeLabel.colorMedium

        changeValue.secondaryRegular()

        timeChangeTitle.secondaryRegular()
        timeChangeTitle.textColor = UIColor.ThemeLabel.colorMedium

        timeValue.secondaryRegular()
        timeValue.textColor = UIColor.ThemeLabel.colorLite

        hTitle.secondaryRegular()
        hTitle.textColor = UIColor.ThemeLabel.colorMedium

        hValue.secondaryRegular()
        hValue.textColor = UIColor.ThemeLabel.colorLite

        ltitle.secondaryRegular()
        ltitle.textColor = UIColor.ThemeLabel.colorMedium

        lvalue.secondaryRegular()
        lvalue.textColor = UIColor.ThemeLabel.colorLite

        changeTitle.text = "common_text_priceLimit".localized()
        timeChangeTitle.text = "common_text_dayVolume".localized()
        hTitle.text = "kline_text_high".localized()
        ltitle.text = "kline_text_low".localized()
//        networthTitle.text = "etf_text_networth".localized()
//        etfRateTitle.text = "etf_fund_rate".localized()
        
        etfRateTitle.secondaryRegular()
        etfRateTitle.textColor = UIColor.ThemeLabel.colorMedium
        
        etfRateValue.secondaryRegular()
        etfRateValue.textColor = UIColor.ThemeLabel.colorLite
        
        networthTitle.secondaryRegular()
        networthTitle.textColor = UIColor.ThemeLabel.colorMedium
        
        networthValue.secondaryRegular()
        networthValue.textColor = UIColor.ThemeLabel.colorLite

    }
    
    //Whether to display net value
    func showNetWorth(_ b : Bool) {
        leftContainerHeight.constant = b ? 56 : 34
        rightContainerHeight.constant = b ? 56 : 34

        etfRateTitle.isHidden = !b
        etfRateValue.isHidden = !b
        networthTitle.isHidden = !b
        networthValue.isHidden = !b
        if b {
            networthTitle.text = "etf_text_networth".localized()
            etfRateTitle.text = "etf_fund_rate".localized()
        }else {
            networthTitle.text = ""
            etfRateTitle.text = ""
        }
    }
    
    func setNetWorth(_ netValueModel : EXETFNetValueModel){
        if netValueModel.price.count > 0 {
            networthValue.text = netValueModel.price
        }else {
            networthValue.text = "--"
        }
        
        let rate =  EXAppMarketManager.sharedInstance.getFundRate(entity.symbol)
        if rate.count > 0 {
            etfRateValue.text = rate + "%"
        }else {
            etfRateValue.text = "--"
        }
    }
    
    @IBAction func fullScreenAction(_ sender: Any) {
        self.tableHeaderAction?(.fullscreen)
    }
    
    @IBAction func scaleAction(_ sender: UITapGestureRecognizer) {
        self.dismissDropView()
        self.addSubview(scaleDrop)
        scaleDrop.scaleDidChage = {[weak self] key in
            self?.scaleChangeControl.setTitle(content: key.localized())
            self?.klineView.chartSerieSwitchToLineMode(on: (key == EXKlineWsVm.keyLine))
            self?.dismissDropView()
            self?.scalePublish.onNext(key)
        }
        
        scaleChangeControl.isChecked = true 
        scaleDrop.snp.makeConstraints { (make) in
            make.top.equalTo(klineView.snp.top)
            make.left.equalTo(klineView.snp.left)
            make.right.equalTo(klineView.snp.right)
            make.height.equalTo(EXScaleDropView.getHeight())
        }
    }
    
    @IBAction func indexAction(_ sender: UITapGestureRecognizer) {
        self.dismissDropView()
        self.addSubview(algorithmDrop)
        indexChangeControl.isChecked = true
        algorithmDrop.masterTypeChange = {[weak self] type in
            self?.masterType.onNext(type)
            self?.klineView.updateMasterAlgorithm(to: type)
        }
        algorithmDrop.assistantTypeChange = {[weak self] type in
            self?.assistantType.onNext(type)
            self?.klineView.updateAssistantAlgorithm(to: type)
        }
        algorithmDrop.snp.makeConstraints { (make) in
            make.top.equalTo(klineView.snp.top)
            make.left.equalTo(klineView.snp.left)
            make.right.equalTo(klineView.snp.right)
            make.height.equalTo(122)
        }
    }
    
    func updatePrice(withItem item:TickItem?, priceDecimal:String,volumeDecimal:String) {
        
        if let tickItem = item {
            let color =  tickItem.riseorfail ? UIColor.ThemekLine.up : UIColor.ThemekLine.down
            hValue.text = tickItem.high.formatAmountUseDecimal(priceDecimal)
            lvalue.text = tickItem.low.formatAmountUseDecimal(priceDecimal)
            timeValue.text = tickItem.vol.formatAmountUseDecimal(volumeDecimal)
            if tickItem.rose != "--" {
                changeValue.text = tickItem.rose + "%"
                changeValue.textColor = color
            }
            priceLabel.text = tickItem.close.formatAmountUseDecimal(priceDecimal)
            priceLabel.textColor = color
            let array = self.entity.name.components(separatedBy: "/")
            if array.count == 2 {
                let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(array[1])
                if let rmb = NSString.init(string: String(describing: tickItem.close)).multiplyingBy1(t.1, decimals: t.2){
                    rmbLabel.text = "≈\(t.0)" + rmb
                }
            }
        }else {
            let color =  UIColor.ThemeLabel.colorMedium
            hValue.text = "--"
            lvalue.text = "--"
            timeValue.text = "--"
            changeValue.text = "--"
            priceLabel.text = "--"
            changeValue.textColor = color
            priceLabel.textColor = color
            rmbLabel.text = "--"
        }
     
    }
    
    func dismissDropView () {
        scaleChangeControl.isChecked = false
        indexChangeControl.isChecked = false
        scaleDrop.removeFromSuperview()
        algorithmDrop.removeFromSuperview()
    }
}

