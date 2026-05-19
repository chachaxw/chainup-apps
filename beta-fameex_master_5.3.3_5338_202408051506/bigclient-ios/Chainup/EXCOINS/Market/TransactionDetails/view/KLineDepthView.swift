//
//  KLineDepthView.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/15.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class KLineDepthView: UIView {
    
    var depthDatas: [CHKDepthChartItem] = [CHKDepthChartItem]()
    
    var maxAmount: Float = 0          //Maximum depth
    
    ///Depth Chart Style
    lazy var depthStyle: CHKLineChartStyle = {
        
        let style = CHKLineChartStyle()
        //font size
        style.labelFont = UIFont.systemFont(ofSize: 10)
        //Zone Border Color
        style.lineColor = UIColor(white: 0.7, alpha: 1)
        //background color 
        style.backgroundColor = UIColor.ThemekLine.viewBg
        //Text color
        style.textColor = UIColor(white: 0.5, alpha: 1)
        //The inner margin of the entire chart
        style.padding = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        //Is the Y-axis embedded
        style.isInnerYAxis = true
        //The Y-axis is displayed on the right
        style.showYAxisLabel = .right
        //Boundary width
        style.borderWidth = (0, 0, 0.5, 0)
        
        style.bidChartOnDirection = .left
        
        style.enableTap = true
        //The color of the buyer's deep layer UIColor (hex: 0xAD6569) UIColor (hex: 0x469777)
        style.bidColor = (UIColor.ThemekLine.up,UIColor.ThemekLine.up.withAlphaComponent(0.15), 1)
        //        style.askColor = (UIColor(hex:0xAD6569), UIColor(hex:0xAD6569), 1)
        //The color of the buyer's deep layer
        style.askColor = (UIColor.ThemekLine.down, UIColor.ThemekLine.down.withAlphaComponent(0.15), 1)
        //        style.bidColor = (UIColor(hex:0x469777), UIColor(hex:0x469777), 1)
        
        return style
        
    }()
    
    //Depth map
    lazy var depthView : CHDepthChartView = {
        let view = CHDepthChartView()
        view.extUseAutoLayout()
        view.delegate = self
        view.style = self.depthStyle
        view.yAxis.referenceStyle = .none
        return view
    }()
    
    //no data
    lazy var noDataLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetText(LanguageTools.getString(key: "loading"), textColor: UIColor.ThemekLine.labcolorLite, fontSize: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = UIColor.ThemekLine.viewBg
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var hline : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemekLine.labcolorMedium
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ThemekLine.viewBg
        addSubViews([depthView,hline,noDataLabel])
        addConstraints()
//        getDataByFile()
    }
    
    func addConstraints() {
//        titleLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(10)
//            make.right.top.equalToSuperview()
//            make.height.equalTo(54)
//        }
        noDataLabel.snp.makeConstraints { (make ) in
            make.edges.equalToSuperview()
        }
        depthView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(210)
            make.top.equalToSuperview()
        }
        hline.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.right)
            make.height.equalTo(210)
            make.top.equalToSuperview()
            make.width.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension KLineDepthView : CHKDepthChartDelegate{
    
    ///Decimal Digits of Price
    func depthChartOfDecimal(chart: CHDepthChartView) -> Int {
        return 4
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
    
    
    ///The increment of each segment after the y-axis is established with the base value
    ///
    /// - Parameter depthChart:
    /// - Returns:
    func incrementValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double {
        
        //Calculate a friendly effect for displaying 5 auxiliary lines
        var step = self.maxAmount / 5
        
        var j = 0
        while step / 10 > 1 {
            j += 1
            step = step / 10
        }
        
        //exponentiation 
        var pow: Int = 1
        if j > 0 {
            for _ in 1...j {
                pow = pow * 10
            }
        }
        
        step = Float(lroundf(step) * pow)
        
        return Double(step)
    }
    
    func depthChart(chart: CHDepthChartView, labelOnYAxisForValue value: CGFloat) -> String {
        if value == 0 {
            return ""
        }
        let strValue = value.ch_toString(maxF: 0)
        return strValue
    }

}

extension KLineDepthView{
    
    func getDataByFile(_ dict : [String : Any]) -> ([[Double]],[[Double]]){
        self.maxAmount = 0
        var asksArray : [[Double]] = []
        var bidsArray : [[Double]] = []
        if let tick = dict["tick"] as? [String : Any]{
            depthDatas.removeAll()
            if let asks = tick["asks"] as? [[Any]]{
                for arr in asks{
                    if arr.count > 1{
                        asksArray.append([NumberHandler.handleDouble(arr[0]),NumberHandler.handleDouble(arr[1])])
                    }
                }
            }
            
            if let bids = tick["buys"] as? [[Any]]{
                for arr in bids{
                    bidsArray.append([NumberHandler.handleDouble(arr[0]),NumberHandler.handleDouble(arr[1])])
                }
            }
            
            if asksArray.count > 0{
                self.decodeDatasToAppend(datas: asksArray, type: .ask)
            }
//            else{
//                self.decodeDatasToAppend(datas: [], type: .ask)
//            }
            
            if bidsArray.count > 0{
                self.decodeDatasToAppend(datas: bidsArray.reversed(), type: .bid)
            }
//            else{
//                self.decodeDatasToAppend(datas: [], type: .bid)
//            }
            self.depthView.reloadData()
        }
        noDataLabel.isHidden = asksArray.count > 0 || bidsArray.count > 0
        depthView.isUserInteractionEnabled = noDataLabel.isHidden
        return (asksArray , bidsArray)
    }
    
    ///Parsing data
    func decodeDatasToAppend(datas: [[Double]], type: CHKDepthChartItemType) {
        var total: Float = 0
        if datas.count > 0 {
            for data in datas {
                let item = CHKDepthChartItem()
                item.value = CGFloat(data[0])
                item.amount = CGFloat(data[1])
                item.type = type

                self.depthDatas.append(item)

                total += Float(item.amount)
            }
        }

        if total > self.maxAmount {
            self.maxAmount = total
        }
    }
    
}

class BuyAndSellView : UIView{
    
    lazy var buyView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemekLine.up
        return view
    }()
    
    lazy var buyLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .right
        label.layoutIfNeeded()
        label.extSetText(LanguageTools.getString(key: "buy"), textColor: UIColor.ThemekLine.up, fontSize: 11)
        return label
    }()
    
    lazy var sellView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor =  UIColor.ThemekLine.down
        return view
    }()
    
    lazy var sellLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.extSetText(LanguageTools.getString(key: "sell"), textColor:  UIColor.ThemekLine.down, fontSize: 11)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([buyView,buyLabel,sellView,sellLabel])
        buyLabel.snp.makeConstraints { (make ) in
            make.right.equalTo(self.snp.centerX).offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
        }
        
        buyView.snp.makeConstraints { (make ) in
            make.right.equalTo(buyLabel.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(10)
        }
        
        sellView.snp.makeConstraints { (make ) in
            make.left.equalTo(self.snp.centerX).offset(5)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(10)
        }
        
        sellLabel.snp.makeConstraints { (make ) in
            make.left.equalTo(sellView.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}


