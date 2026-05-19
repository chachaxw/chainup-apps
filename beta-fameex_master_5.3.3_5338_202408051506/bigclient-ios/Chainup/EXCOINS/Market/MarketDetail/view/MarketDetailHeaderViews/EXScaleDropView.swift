//
//  EXScaleDropView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXScaleDropView: UIView {
    
    var scaleIdx:Int?
    var scaleItems:[EXTextButton]=[]
    typealias ScaleChangeBlock = (String) -> ()
    var scaleDidChage : ScaleChangeBlock?
    var menuModel = EXMenuSelectionModel.init() {
        didSet {
            for (_,item) in scaleItems.enumerated() {
//                if item.titleLabel?.text == menuModel.scaleKey {
//                    item.setSelected(isSelect: true)
//                }else {
//                    item.setSelected(isSelect: false)
//                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: CGRect.zero)
        config()
    }
    
    static func getHeight()->CGFloat {
        
        let klineScalse = EXAppConfigManager.sharedInstance.getKlineScale()
        let allcount = klineScalse.count
        let row = allcount/4
        let left = allcount % 4 > 0 ? 1 :0
        return CGFloat((row + left)*40) + 2
    }
    
    
    func config() {
        
        self.backgroundColor = UIColor.ThemekLine.viewBgTab
        let klineScalse = EXAppConfigManager.sharedInstance.getKlineScale()
        
        let numberOfcolumn = 4
        let itemWidth = 94
        let itemHeight = 40
        let hgap = 0
        let ygap = 0
        let dftkey = menuModel.scaleKey
        
        for (idx, scale) in klineScalse.enumerated() {
            var showScale = scale
            let row = idx / numberOfcolumn
            let col = idx % numberOfcolumn
            let px = (itemWidth+hgap)*col
            let py = (itemHeight+ygap)*row
            
            let scaleView = EXTextButton()
            scaleView.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
            scaleView.supportCheckHighlight = true
            scaleView.color = UIColor.clear
            scaleView.backgroundColor = UIColor.ThemekLine.viewBgTab
            scaleView.highlighTextColor = UIColor.ThemekLine.labcolorHighlight
            scaleView.tag = idx
//            scaleView.bgBtn.tag = idx
            var key = ""
            if idx == 0 {
                key = "Line"
                showScale = "Line"
            }else {
                key = scale
            }
            scaleView.setTitle(showScale.localized(), for: .normal)
            scaleView.isSelected = false
            scaleView.addTarget(self, action: #selector(scaleBtnDidTap(sender:)), for: .touchUpInside)
            if dftkey == showScale {
                scaleView.isSelected = true
            }
//
//            if let scale = scaleIdx, scale == idx {
//                scaleView.isSelected = true
//            }else {
//                if scale == KlineScaleDefaultKey {
//                    scaleView.isSelected = true
//                }
//            }
            self .addSubview(scaleView)
            
            scaleView.snp.makeConstraints { (make) in
                make.left.equalTo(px)
                make.top.equalTo(py)
                make.width.equalTo(itemWidth)
                make.height.equalTo(itemHeight)
            }
            scaleItems.append(scaleView)
        }
    }
    
    @objc func  scaleBtnDidTap(sender:UIButton) {

        for (idx,item) in scaleItems.enumerated() {

            if item == sender {
                item.isSelected = true
            }else {
                item.isSelected = false
            }
        }
        let klineScalse = EXAppConfigManager.sharedInstance.getKlineScale()
        var key = ""
        if sender.tag == 0 {
            key = "Line"
        }else {
            key = klineScalse[sender.tag]
        }
        self.scaleDidChage?(key)
        
    }

}
