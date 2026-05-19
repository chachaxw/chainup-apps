//
//  KlineScaleDropMenu.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import Swap
class KlineDropMenuUI:NSObject {
    static let column:Int = 5
    static let btnHeight:Int = 22
    static let btnWidth:Int = 55
    static let btnVerticalGap:Int = 15
    static let btnHorizontalGap:Int = 10
}

class KlineScaleDropMenu: UIView {
    var isSwap: Bool = false //Inconsistent copy
    var scaleItems:[EXDropMenuBtn]=[]
    typealias ScaleChangeBlock = (UIButton,String) -> ()
    var scaleDidChange :ScaleChangeBlock?
    var zoomActionCallback :ScaleChangeBlock?
    
    lazy var scaleBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.addTarget(self, action: #selector(zoomAction(sender:)), for: .touchUpInside)
        btn.setImage(UIImage.exs_themeImageNamed(imageName:"public_fullscreen"), for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configMenus()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configMenus()
    }
    convenience init (swap:Bool) {
        self.init()
        configMenus(swap)
    }
    @objc func zoomAction(sender:UIButton) {
        self.zoomActionCallback?(sender,"")
    }
    
    func configMenus() {
        self.clipsToBounds = true
        self.backgroundColor = UIColor.ThemekLine.viewBg
        self.addSubview(scaleBtn)
        scaleBtn.snp_makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(42)
        }
        let menus:[String] = EXAppConfigManager.sharedInstance.getOtherKlineScale()
        let numberOfcolumn = KlineDropMenuUI.column
        let itemWidth:Int = Int((SCREEN_WIDTH - 60 - 40)/5)
        let itemHeight = KlineDropMenuUI.btnHeight
        let hgap = KlineDropMenuUI.btnHorizontalGap
        let ygap = KlineDropMenuUI.btnVerticalGap
        
        for (idx, scale) in menus.enumerated() {
            var showScale = scale
            let row = idx / numberOfcolumn
            let col = idx % numberOfcolumn
            let px = (itemWidth+hgap)*col + 15
            let py = (itemHeight+ygap)*row + 15
            
            let scaleView = EXDropMenuBtn()
            scaleView.tag = idx
            if idx == 0 {
                showScale = "Line"
            }
            let title = EXAppConfigManager.sharedInstance.getkeyTitle(scale: showScale, isSwap: self.isSwap)
            scaleView.setTitle(title, for: .normal)
            scaleView.isSelected = false
            scaleView.addTarget(self, action: #selector(scaleBtnDidTap(sender:)), for: .touchUpInside)
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
    
    func updateScale(scaleKey:String) {
        let menus:[String] = EXAppConfigManager.sharedInstance.getOtherKlineScale()
        var titles = [String]()
        for m in menus{
            let t = EXAppConfigManager.sharedInstance.getkeyTitle(scale: m, isSwap: self.isSwap)
            titles.append(t)
        }
        if scaleKey.isEmpty {
            for item in scaleItems {
                item.isSelected = false
            }
        }else {
            for (idx,item) in titles.enumerated() {
                if idx == 0 {
                    if scaleKey == "Line" {
                        scaleItems[idx].isSelected = true
                    }else {
                        scaleItems[idx].isSelected = false
                    }
                }else {
                    if item == scaleKey {
                        scaleItems[idx].isSelected = true
                    }else {
                        scaleItems[idx].isSelected = false
                    }
                }
            }
        }
    }
    
    
    @objc func  scaleBtnDidTap(sender:UIButton) {
        
        for item in scaleItems {
            if item == sender {
                item.isSelected = true
            }else {
                item.isSelected = false
            }
        }
        let menus:[String] = EXAppConfigManager.sharedInstance.getOtherKlineScale()
        let lineKey = menus[sender.tag]
        if sender.tag == 0,lineKey == "1min" {
            self.scaleDidChange?(sender,"Line")
        }else {
            self.scaleDidChange?(sender,lineKey)
        }
    }
    
    static func getHeight()->CGFloat {
        
        let klineScalse = EXAppConfigManager.sharedInstance.getOtherKlineScale()
        let allcount = klineScalse.count
        let row = allcount/KlineDropMenuUI.column
        let left = allcount % KlineDropMenuUI.column > 0 ? 1 :0
        let ygap = ((row + left) - 1) * KlineDropMenuUI.btnVerticalGap
        return CGFloat((row + left)*KlineDropMenuUI.btnHeight) + CGFloat(ygap) + 30
    }
}
extension KlineScaleDropMenu{
    func uploadSwap() {
        scaleBtn.removeFromSuperview()
        for scale in scaleItems {
            scale.removeFromSuperview()
        }
        self.isSwap = true
        configMenus(true)
    }
    
    func configMenus(_ swap:Bool = false){
        self.clipsToBounds = true
        self.backgroundColor = UIColor.ThemekLine.viewBg
        var scaleBtnwidth:Int = 0
        if swap == false {
            self.addSubview(scaleBtn)
            scaleBtn.snp.makeConstraints { (make) in
                make.right.equalToSuperview()
                make.top.equalToSuperview().offset(4)
                make.width.height.equalTo(42)
            }
            scaleBtnwidth = 40
        }
        
        let menus:[String] = EXAppConfigManager.sharedInstance.getOtherKlineScale()
        let numberOfcolumn = KlineDropMenuUI.column
        let itemWidth:Int = Int((Int(SCREEN_WIDTH) - 60 - scaleBtnwidth)/5)
        let itemHeight = KlineDropMenuUI.btnHeight
        let hgap = KlineDropMenuUI.btnHorizontalGap
        let ygap = KlineDropMenuUI.btnVerticalGap
        
        for (idx, scale) in menus.enumerated() {
            var showScale = scale
            let row = idx / numberOfcolumn
            let col = idx % numberOfcolumn
            let px = (itemWidth+hgap)*col + 15
            let py = (itemHeight+ygap)*row + 15
            
            let scaleView = EXDropMenuBtn()
            scaleView.tag = idx
            if idx == 0 {
                showScale = "Line"
            }
            let title = EXAppConfigManager.sharedInstance.getkeyTitle(scale: showScale, isSwap: self.isSwap)
            scaleView.setTitle(title, for: .normal)
            scaleView.isSelected = false
            scaleView.addTarget(self, action: #selector(scaleBtnDidTap(sender:)), for: .touchUpInside)
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
}
 

