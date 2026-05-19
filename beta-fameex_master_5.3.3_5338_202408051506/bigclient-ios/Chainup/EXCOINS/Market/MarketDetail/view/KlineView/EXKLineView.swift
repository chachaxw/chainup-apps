//
//  EXKLineView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import SwiftEventBus
import EXKit
class EXKLineView: NibBaseView {
    var chartXAxisPrevDay = ""
    var kLineDatas : [KLineChartItem] = []
    let infoView = EXKLineSelectedInfoView()
    
    var priceDecimal:String = "8"
    var volumeDecimal:String = "8"
    
    typealias KLineViewTapBlock = () -> ()
    var didTapklineCallback : KLineViewTapBlock?
    
    @IBOutlet var chartsView: CHKLineChartView!
    var zoomed:Bool = false
    
    var progressHud:EXKlineProgress?
    var isLoading:Bool = false
    var menuModel = EXMenuSelectionModel.init()
    
    override func onCreate() {
        config()
    }
    //initialization
    func config() {
        self.backgroundColor = UIColor.ThemekLine.viewBg
        chartsView.backgroundColor = UIColor.ThemekLine.viewBg 
        chartsView.isInnerYAxis = true 
        chartsView.style = EXKlineStyle.normalStyle()
        chartsView.delegate = self
        self.updateAssistantAlgorithm(to: menuModel.assitantType)
        self.updateMasterAlgorithm(to: menuModel.masterType)
        showLoading()
    }
    
    func showLoading() {
        if isLoading {
            return
        }
        isLoading = true
        self.perform(#selector(performLoding), with: nil, afterDelay: 0.3)
    }
    @objc func performLoding(){
        if isLoading {
            if progressHud == nil {
                progressHud = EXKlineProgress.init(frame: self.frame)
                self.addSubview(progressHud!)
            }
            progressHud?.loading()
        }
    }
    
    func hideLoading() {
        isLoading = false
        progressHud?.dismiss()
        progressHud = nil
    }
    ///Follow the new main image moving average bool
    func updateMasterAlgorithm(to:MasterAlgorithmType) {
        switch to {
            case .none:
                break
            case .MA:
                chartsView.setSerie(hidden: false, by: "MA", inSection: 0)
                chartsView.setSerie(hidden: true, by: "BOLL", inSection: 0)
                break
            case .BOLL:
                chartsView.setSerie(hidden: true, by: "MA", inSection: 0)
                chartsView.setSerie(hidden: false, by: "BOLL", inSection: 0)
                break
            case .Hides:
                chartsView.setSerie(hidden: true, by: "MA", inSection: 0)
                chartsView.setSerie(hidden: true, by: "BOLL", inSection: 0)
                break
        }
        chartsView.reloadData()
    }
    ///Follow the new secondary image
    func updateAssistantAlgorithm(to:AssistantAlgorithmType) {
        if to != .none {
            if to == .Hides {
                chartsView.setSection(hidden: true, byKey:"assistant")
            }else {
                chartsView.setSection(hidden: false, byKey:"assistant")
                chartsView.setSerie(hidden: true, by: CHSeriesKey.macd, inSection: 2)
                chartsView.setSerie(hidden: true, by: CHSeriesKey.kdj, inSection: 2)
                chartsView.setSerie(hidden: true, by: CHSeriesKey.rsi, inSection: 2)
                chartsView.setSerie(hidden: true, by: CHSeriesKey.wr, inSection: 2)
                if to == .MACD {
                    chartsView.setSerie(hidden: false, by: CHSeriesKey.macd, inSection: 2)
                }else if to == .KDJ {
                    chartsView.setSerie(hidden: false, by: CHSeriesKey.kdj, inSection: 2)
                }else if to == .RSI {
                    chartsView.setSerie(hidden: false, by: CHSeriesKey.rsi, inSection: 2)
                }else if to == .WR {
                    chartsView.setSerie(hidden: false, by: CHSeriesKey.wr, inSection: 2)
                }
            }
            self.chartsView.reloadData()
        }
    }
    
    
    func reloadData(data:[KLineChartItem]) {
        self.kLineDatas = data
        
//        self.chartsView.reloadData(toPosition: .end, resetData: false)

        self.chartsView.reloadData(toPosition: CHChartViewScrollPosition.end, resetData: true)
//        if zoomed == false {
//            self.chartsView.zoomChart(by: 20, enlarge: true)
//            zoomed = true
//        }

    }
    
    func reloadPreData(data:[KLineChartItem]) {
        self.kLineDatas = data
        self.chartsView.reloadPreData()
    }
    

    func appendData(data:KLineChartItem) {
        if let lastModel = self.kLineDatas.last {
            if lastModel.id == data.id {
                self.kLineDatas.removeLast()
                self.kLineDatas.append(data)
                
                if chartsView.rangeFrom + chartsView.range  < kLineDatas.count - 1  {
                    chartsView.reloadData(toPosition: .none, resetData: true)
                }else {
                    chartsView.reloadData(toPosition: .none, resetData: true)
                }
            }else {
                if  data.id > lastModel.id {
                    self.kLineDatas.append(data)
                    if chartsView.rangeFrom + chartsView.range  < kLineDatas.count - 1{
                        chartsView.reloadData(toPosition: .none, resetData: true)
                    }else {
                        chartsView.reloadData(toPosition: .end, resetData: true)
                    }
                }
            }
        }else {
            self.kLineDatas .append(data)
            chartsView.reloadData(toPosition: .none, resetData: false)
        }
    }
    
    func chartSerieSwitchToLineMode(on:Bool) {
        chartsView.setSerie(hidden: !on, by: "Timeline", inSection: 0)
        chartsView.setSerie(hidden: on, by: "Candle", inSection: 0)
        chartsView.setSerie(hidden: on, by: "MA", inSection: 0)
        chartsView.setSerie(hidden: on, by: "KDJ", inSection: 0)
        chartsView.setSerie(hidden: !on, by: "volume", inSection: 0)
        chartsView.reloadData()
    }
    
}

extension EXKLineView : CHKLineChartDelegate {
    
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return kLineDatas.count
    }
    
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.kLineDatas[index]
        let item = CHChartItem()
        item.time = data.time
        item.openPrice = CGFloat(data.open)
        item.highPrice = CGFloat(data.high)
        item.lowPrice = CGFloat(data.low)
        item.closePrice = CGFloat(data.close)
        item.vol = CGFloat(data.vol)
        return item
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String {
        var strValue = ""
        if section.key == "volume" {
            if value / 1000 > 1 {
                strValue = (value / 1000).ch_toString(maxF: section.decimal).formatAmountUseDecimal(volumeDecimal) + "K"
            } else {
                strValue = value.ch_toString(maxF: section.decimal).formatAmountUseDecimal(volumeDecimal)
            }
        } else {
            strValue = value.ch_toString(maxF: section.decimal).formatAmountUseDecimal(priceDecimal)
        }
        return strValue
    }
    
    ///Customize the display content of X-axis coordinate values
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.kLineDatas[index]
        let timestamp = data.time
        return Date.klineTimeFormat(timestamp, timekey: self.menuModel.scaleKey)

    }
    
    ///Adjust the number of decimal places reserved for each partition
    ///
    /// - parameter chart:
    /// - parameter section:
    ///
    /// - returns:
    func kLineChart(chart: CHKLineChartView, decimalAt section: Int) -> Int {
        
        return Int(self.priceDecimal) ?? 8
//        if section == 0 {
//            return Int(self.priceDecimal) ?? 8
//        }else {
//            return Int(self.volumeDecimal) ?? 8
//        }
    }
    

    func kLineChart(chart: CHKLineChartView, didSelectAt index: Int, item: CHChartItem) {
        self.didTapklineCallback?()
        infoView.removeFromSuperview()
        chart .addSubview(infoView)
        infoView.updateItems(item: item,priceDecimal: priceDecimal,volumeDecimal: volumeDecimal)
        let topOffset = chart.style.padding.top
        let halfIdx = (chart.rangeTo + chart.rangeFrom) / 2
        chart.style.showYAxisLabel = index > halfIdx ? .right : .left
        
        if index > halfIdx {
            infoView.snp.makeConstraints { (make) in
                make.left.equalTo(5)
                make.top.equalTo(topOffset)
                make.width.equalTo(120)
                make.height.equalTo(134)
            }
        }else {
            infoView.snp.makeConstraints { (make) in
                make.right.equalTo(-5)
                make.top.equalTo(topOffset)
                make.width.equalTo(120)
                make.height.equalTo(134)
            }
        }
    }
    
    func kLineChartScrolled() {
        infoView.removeFromSuperview()
    }
    
    func kLineChartPinched() {
        infoView.removeFromSuperview()
    }

    func hideSelection() {
        infoView.removeFromSuperview()
        chartsView.showSelection = false
        chartsView.sightView?.isHidden = true
    }
    
    func kLinePrePage() {
        SwiftEventBus.post(EXEventBusConst.onKlinePrePageTrigger)
    }
    
}


/// loding
class EXKlineProgress : UIView{
    
    var imgV = UIImageView()

    var animation: CABasicAnimation = {
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.fillMode = CAMediaTimingFillMode.forwards;
        animation.toValue = Double.pi * 2.0
        animation.duration = 1
        animation.repeatCount = Float.greatestFiniteMagnitude
        return animation
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        self.imgV = UIImageView()
        self.imgV.image = EXKitBundle.svgImage(named: "loading") //UIImage.themeImageNamed(imageName: "refresh",kline: true)
        self.imgV.extUseAutoLayout()
        self.addSubview(self.imgV)
        self.imgV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loading(){
        self.imgV.layer.add(self.animation, forKey: "rotate")
    }
    
    func dismiss() {
        imgV.layer.removeAnimation(forKey: "rotate")
        imgV.removeFromSuperview()
        self.removeFromSuperview()
    }
}


