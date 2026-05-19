//
//  EXKlineDepthView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXKlineDepthView: NibBaseView {
    
    var thresholdPrice = 0.15//Price threshold
    
    var depthDatas: [CHKDepthChartItem] = [CHKDepthChartItem]()
    var maxAmount: Float = 0          //Maximum depth
    
    var precision = "0.01"//accuracy
    
    var pricevalue = "0"//Latest price
    
    var entity = CoinMapEntity()
    
    @IBOutlet var leftLabel: DepthViewTitleLabel!
    @IBOutlet var rightLabel: DepthViewTitleLabel!
    
    @IBOutlet var depthView: CHDepthChartView!
    
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemekLine.labcolorMedium
        label.font = UIFont.ThemeFont.MinimumRegular
        label.layoutIfNeeded()
        return label
    }()
    
    override func onCreate() {
        depthView.style = EXKLineDepthStyle.depthStyle()
        depthView.xAxis.referenceStyle = .solid(color: UIColor.ThemekLine.viewSeperator)
        depthView.yAxis.referenceStyle = .solid(color: UIColor.ThemekLine.viewSeperator)

        leftLabel.minimumRegular()
        rightLabel.minimumRegular()
        
        leftLabel.textColor = UIColor.ThemekLine.labcolorMedium
        rightLabel.textColor = UIColor.ThemekLine.labcolorMedium
        leftLabel.text = "contract_text_buyMarket".localized()
        rightLabel.text = "contract_text_sellMarket".localized()
        leftLabel.fillcolor = UIColor.ThemekLine.up
        rightLabel.fillcolor =  UIColor.ThemekLine.down
        leftLabel.textAlignment = .right
        rightLabel.textAlignment = .right
        
        self.addSubview(priceLabel)
        self.bringSubviewToFront(priceLabel)
        priceLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-4)
            make.height.equalTo(18)
        }
    }
    
    func updatedepthData(models:[CHKDepthChartItem],maxAmount:Float , price : String , entity : CoinMapEntity) {
        self.maxAmount = maxAmount
//        self.depthDatas = models
        self.entity = entity
        self.precision = NumberHandler.strToPrecision(entity.price)
        
        self.depthDatas = models
        priceLabel.text = (price as NSString).decimalString1(Int(entity.price) ?? 4)
        self.depthView.reloadData()
    }
}

extension EXKlineDepthView : CHKDepthChartDelegate{
    ///Decimal Digits of Price
    func depthChartOfDecimal(chart: CHDepthChartView) -> Int {
        return Int(self.entity.price) ?? 4
    }
    
    ///Decimal Digits of Quantity
    func depthChartOfVolDecimal(chart: CHDepthChartView) -> Int {
        return 6
    }
    ///Total number of charts
    ///Total=Buyer+Seller
    /// - Parameter chart:
    /// - Returns:
    func numberOfPointsInDepthChart(chart: CHDepthChartView) -> Int {
        return self.depthDatas.count
    }
    
    ///Numerical items displayed for each point
    ///
    /// - Parameters:
    ///   - chart:
    ///   - index:
    /// - Returns:
    func depthChart(chart: CHDepthChartView, valueForPointAtIndex index: Int) -> CHKDepthChartItem {
        return self.depthDatas[index]
    }
    
    ///The y-axis is established with base values
    ///
    /// - Parameter depthChart:
    /// - Returns:
    func baseValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double {
        return 0
    }
    
    func depthChartOfNeedCalculateDepth(chart: CHDepthChartView) -> Bool {
        return false
    }
    func depthChart(chart: CHDepthChartView, labelOnYAxisForValue value: CGFloat) -> String {
        if value == 0 {
            return ""
        }
        let strValue = NumberHandler.dealVolumFormate("\(value)")
//            value.ch_toString(maxF: 1)
        return strValue
    }
    
}

class DepthViewTitleLabel :UILabel {
    
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    @IBInspectable var leftInset: CGFloat = 12.0
    @IBInspectable var rightInset: CGFloat = 0.0
    private let squareWidth:CGFloat = 6
    
    var fillcolor = UIColor.clear{
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath.init(rect: CGRect(x: 0, y:(self.height - squareWidth)/2, width: squareWidth, height: squareWidth))
        self.fillcolor.setFill()
        path.fill()
        super.drawText(in: rect)
    }
    
    override func drawText(in rect: CGRect) {
        let labelInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
        super.drawText(in: rect.inset(by: labelInset))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}



