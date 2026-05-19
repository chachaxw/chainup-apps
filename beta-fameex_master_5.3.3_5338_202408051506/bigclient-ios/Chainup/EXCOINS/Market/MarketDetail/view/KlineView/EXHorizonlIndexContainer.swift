//
//  EXHorizonlIndexContainer.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXHorizonlIndexContainer: NibBaseView {
    
    @IBOutlet var indexsContainer: UIStackView!
    typealias ScaleChangeBlock = (String) -> ()
    var scaleDidChage : ScaleChangeBlock?

    override func onCreate() {
//        self.loadItems()
    }
    var swap = false
    func loadItems(_ isSwap:Bool = false){
        let klineScalse = EXAppConfigManager.sharedInstance.getKlineScale()
        for (idx, scale) in klineScalse.enumerated() {
            let scaleView = EXKLineScaleView()
            scaleView.backgroundColor = UIColor.ThemekLine.viewBg
            scaleView.bgBtn.tag = idx
            if idx == 0 { //
                let t = "kline_Line".localized()
                scaleView.setTitle(title: t)
            }else {
                scaleView.setTitle(title: EXAppConfigManager.sharedInstance.getkeyTitle(scale: scale, isSwap: false) )
            }
            scaleView.bgBtn.addTarget(self, action: #selector(scaleBtnDidTap(sender:)), for: .touchUpInside)
            indexsContainer.addArrangedSubview(scaleView)
        }
    }
    
    @objc func scaleBtnDidTap(sender:UIButton) {
        let klineScalse = EXAppConfigManager.sharedInstance.getKlineScale()
        var key = ""
        if sender.tag == 0 {
            key = "Line"
        }else {
            key = klineScalse[sender.tag]
        }
        self.defaultScale(key: key)
        self.scaleDidChage?(key)
    }
    
    func defaultScale(key:String?) {
        let scaleKey = key ?? KlineScaleDefaultKey
        
        var klineScalse = EXAppConfigManager.sharedInstance.getKlineScale()
        if klineScalse.firstIndex(of: "1min") == 0  {
            klineScalse.remove(at: 0)
            klineScalse.insert("Line", at: 0)
        }
        var  selectedIdx = 0
        for (idx, scale) in klineScalse.enumerated() {
            if scale == scaleKey {
                selectedIdx = idx
                break
            }
        }
        
        for (idx,scaleView) in indexsContainer.subviews.enumerated() {
            if scaleView .isKind(of: EXKLineScaleView.self ) {
                let item = scaleView as! EXKLineScaleView
                item.setSelected(isSelect: (idx==selectedIdx))
            }
        }
    }
}
