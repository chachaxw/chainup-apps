//
//  KLineDetailsView.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/15.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import EXKit
class KLineDetailsView: UIView {
    
    lazy var noDataLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetText(LanguageTools.getString(key: "refresh"), textColor: UIColor.ThemekLine.labcolorLite, fontSize: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = UIColor.ThemekLine.viewBg
        label.isUserInteractionEnabled = true
        return label
    }()
    
    //K-line time chart
    lazy var kLineTimeView : KLineTimeView = {
        let view = KLineTimeView()
        view.extUseAutoLayout()
//        view.isHidden = true
        return view
    }()
    
    //K-line diagram
    lazy var kLineView : KLineView = {
        let view = KLineView()
        view.extUseAutoLayout()
        view.isUserInteractionEnabled = false
//        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ThemekLine.viewBg
        addSubViews([kLineView,kLineTimeView,noDataLabel])
        addConstraints()
    }
    
    func addConstraints() {
//        titleLabel.snp.makeConstraints { (make) in
//            make.top.right.equalToSuperview()
//            make.left.equalToSuperview().offset(10)
//            make.height.equalTo(54)
//        }
        noDataLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(-10)
        }
        kLineTimeView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(41)
        }
        kLineView.snp.makeConstraints { (make) in
            make.top.equalTo(kLineTimeView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(374)
        }
    }
    
    //Refresh k line
    func reloadKLineView(_ array : [KlineChartData]){
        kLineView.kLineDatas = array
        kLineView.chartView.reloadData(toPosition: CHChartViewScrollPosition.end, resetData: true)
        reloadView(array.count > 0)
    }
    
    //Add k line
    func appendKLineView(_ entity : KlineChartData){
        kLineView.kLineDatas.append(entity)
//        kLineView.chartView.reloadData()
        
//        kLineView.chartView.reloadData(toPosition: CHChartViewScrollPosition.end, resetData: false)
        kLineView.chartView.reloadData()
        reloadView(true)
    }
    
    //Is the K-line displayed
    func reloadView(_ b : Bool){
//        kLineView.isHidden = !b
//        kLineTimeView.isHidden = !b
        kLineView.isUserInteractionEnabled = b
        noDataLabel.isHidden = b
    }
    
    deinit {
//        NSLog ("K-line diagram details")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class KLineTimeView : UIView {
    
    var subject : BehaviorSubject<Int> = BehaviorSubject.init(value: -1)
    
    //Time sharing
    lazy var minHourBtn : UIButton = {
        let btn = getBtn(LanguageTools.getString(key: "Line"))
        btn.tag = 1000
        btn.contentHorizontalAlignment = .left
        return btn
    }()
    
    //1 minute
    lazy var oneMinBtn : UIButton = {
        let btn = getBtn(LanguageTools.getString(key: "1min"))
        btn.tag = 1001
        return btn
    }()
    
    //Five minutes
    lazy var fiveMinBtn : UIButton = {
        let btn = getBtn(LanguageTools.getString(key: "5min"))
        btn.tag = 1002
        return btn
    }()
    
    //15 minutes
    lazy var fifteenMinBtn : UIButton = {
        let btn = getBtn(LanguageTools.getString(key: "15min"))
        btn.tag = 1003
        return btn
    }()
    
    //30 minutes
    lazy var halfHourBtn : UIButton = {
        let btn = getBtn(LanguageTools.getString(key: "30min"))
        btn.tag = 1004
        btn.isSelected = true
        return btn
    }()
    
    //1 hour
    lazy var hourBtn : UIButton = {
        let btn = getBtn(LanguageTools.getString(key: "60min"))
        btn.tag = 1005
        return btn
    }()
    
    //1 day
    lazy var dayBtn : UIButton = {
        let btn = getBtn(LanguageTools.getString(key: "1day"))
        btn.tag = 1006
        return btn
    }()
    
    //1 week
    lazy var weekBtn : UIButton = {
        let btn = getBtn(LanguageTools.getString(key: "1week"))
        btn.tag = 1007
        return btn
    }()
    
    //January
    lazy var mouthBtn : UIButton = {
        let btn = getBtn(LanguageTools.getString(key: "1month"))
        btn.tag = 1008
        return btn
    }()
    
    //more
    lazy var moreBtn : UIButton = {
        let btn = getBtn(LanguageTools.getString(key: "more"))
        btn.tag = 2000
        btn.contentHorizontalAlignment = .right
        return btn
    }()
    
    //Show more
    lazy var showView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.isHidden = true
        view.backgroundColor = UIColor.black
        view.alpha = 0.8
        var klines = EXAppConfigManager.sharedInstance.getKlineScale()
        for i in 0..<klines.count {
            if i > 5{
                 let btn = getBtn(klines[i])
                btn.frame = CGRect(x: 0, y: (i-6)*41, width: 64, height: 41)
                view.addSubview(btn)
                btn.tag = 1000 + i
            }
        }
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([minHourBtn,oneMinBtn,fiveMinBtn,fifteenMinBtn,halfHourBtn,hourBtn,moreBtn,showView])
//        showView.addSubViews([dayBtn,weekBtn,mouthBtn])
        addConstraints()
    }
    
    func addConstraints() {
        let width = (SCREEN_WIDTH - 20) / 7
        minHourBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.bottom.top.equalToSuperview()
            make.width.equalTo(width)
        }
        oneMinBtn.snp.makeConstraints { (make) in
            make.left.equalTo(minHourBtn.snp.right)
            make.bottom.top.equalToSuperview()
            make.width.equalTo(width)
        }
        fiveMinBtn.snp.makeConstraints { (make) in
            make.left.equalTo(oneMinBtn.snp.right)
            make.bottom.top.equalToSuperview()
            make.width.equalTo(width)
        }
        fifteenMinBtn.snp.makeConstraints { (make) in
            make.left.equalTo(fiveMinBtn.snp.right)
            make.bottom.top.equalToSuperview()
            make.width.equalTo(width)
        }
        halfHourBtn.snp.makeConstraints { (make) in
            make.left.equalTo(fifteenMinBtn.snp.right)
            make.bottom.top.equalToSuperview()
            make.width.equalTo(width)
        }
        hourBtn.snp.makeConstraints { (make) in
            make.left.equalTo(halfHourBtn.snp.right)
            make.bottom.top.equalToSuperview()
            make.width.equalTo(width)
        }
        moreBtn.snp.makeConstraints { (make) in
            make.left.equalTo(hourBtn.snp.right)
            make.bottom.top.equalToSuperview()
            make.width.equalTo(width)
        }
        showView.snp.makeConstraints { (make) in
            make.top.equalTo(moreBtn.snp.bottom)
            make.height.equalTo((EXAppConfigManager.sharedInstance.getKlineScale().count - 6) * 41)
            make.width.equalTo(64)
            make.right.equalToSuperview().offset(-10)
        }
//        dayBtn.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(10)
//            make.left.right.equalToSuperview()
//            make.height.equalTo(41)
//        }
//        weekBtn.snp.makeConstraints { (make) in
//            make.top.equalTo(dayBtn.snp.bottom)
//            make.left.right.equalToSuperview()
//            make.height.equalTo(41)
//        }
//        mouthBtn.snp.makeConstraints { (make) in
//            make.top.equalTo(weekBtn.snp.bottom)
//            make.left.right.equalToSuperview()
//            make.height.equalTo(41)
//        }
        
    }
    
    @objc func clickBtn(_ btn : UIButton){
        subject.onNext(btn.tag)
        if btn.tag >= 1006{
            moreBtn.setTitle(btn.titleLabel?.text, for: UIControl.State.selected)
            moreBtn.isSelected = true
        }
        if btn.tag == 2000{
            showView.isHidden = false
        }else{
            showView.isHidden = true
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == nil{
            if showView.isHidden == false{
                let c = 1006 + EXAppConfigManager.sharedInstance.getKlineScale().count - 6
//                if let tag = view?.tag , tag >= 1006 && tag <= c{
                    for tag in 1006...c{
                        if let tempoint = self.viewWithTag(tag)?.convert(point, from: self){
                            if (self.viewWithTag(tag)?.bounds)!.contains(tempoint) == true{
                                return self.viewWithTag(tag)
                            }
                        }
                    }
//                }
                
                
//                if let tempoint = self.viewWithTag(1007)?.convert(point, from: self){
//                    if (self.viewWithTag(1007)?.bounds)!.contains(tempoint) == true{
//                        return self.viewWithTag(1007)
//                    }
//                }
//                if let tempoint = self.viewWithTag(1008)?.convert(point, from: self){
//                    if (self.viewWithTag(1008)?.bounds)!.contains(tempoint) == true{
//                        return self.viewWithTag(1008)
//                    }
//                }
            }
        }
        return view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getBtn(_ title : String)->UIButton{
        let btn = UIButton()
//        btn.extUseAutoLayout()
        
        var temp = ""
        
        if title == "4h"{
            temp = LanguageTools.getString(key: "4h")
        }else if title == "1day"{
            temp = LanguageTools.getString(key: "1day")

        }else if title == "1week"{
            temp = LanguageTools.getString(key: "1week")

        }else if title == "1month"{
            temp = LanguageTools.getString(key: "1month")

        }
       
        if temp.ch_length > 1{
            btn.extSetTitle(temp, 14, UIColor.ThemekLine.labcolorMedium, UIControl.State.normal)
            btn.extSetTitle(temp, 14, UIColor.ThemekLine.viewHighlight, UIControl.State.selected)
        }else{
            btn.extSetTitle(title, 14, UIColor.ThemekLine.labcolorMedium, UIControl.State.normal)
            btn.extSetTitle(title, 14, UIColor.ThemekLine.viewHighlight, UIControl.State.selected)
        }
       
        btn.extSetAddTarget(self, #selector(clickBtn(_:)))
        _ = subject.asObserver().subscribe({ (event) in
            if let tag = event.element{
                btn.isSelected = btn.tag == tag ? true : false
            }
        }).disposed(by: disposeBag)
        return btn
    }
    
}

