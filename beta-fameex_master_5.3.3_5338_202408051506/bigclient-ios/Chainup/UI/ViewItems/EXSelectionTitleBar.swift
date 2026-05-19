//
//  EXSelectionTitleBar.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXSelectionBarStyle :NSObject {
    var titleFont :UIFont = UIFont.ThemeFont.HeadBold
    var titleColor:UIColor = UIColor.ThemeLabel.colorMedium
    var titleHighLightColor:UIColor = UIColor.ThemeLabel.colorLite
    
    var indicatorWidth :CGFloat = 22.0
    var indicatorHeight :CGFloat = 4.0
    var horizonGap :CGFloat = 30
    var startX :CGFloat = 15

}

class EXSelectionTitleBar: NibBaseView {

    @IBOutlet var baseScroll: UIScrollView!
    var titleBtns:[EXTitleBarItem] = []
    @IBOutlet var seperator: UIView!
    
    var titleBarCallback:((Int)->())?
    
    var style:EXSelectionBarStyle = EXSelectionBarStyle()
    override func onCreate() {
//        themeNoti()
        baseScroll.showsHorizontalScrollIndicator = false
    }
    
    func hideSeperator() {
        seperator.isHidden = true 
    }
    
//    func themeNoti() {
//        _ = NotificationCenter.default.rx
//            .notification(Notification.Name(rawValue: THEME_CHANGE_NOTI))
//            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
//            .subscribe(onNext: {[weak self] notification in
//                guard let `self` = self else {return}
//                self.reloadUI()
//            })
//    }
    
    func reloadUI() {
        self.backgroundColor = UIColor.ThemeView.bg
        for bar in self.titleBtns {
            bar.backgroundColor = UIColor.ThemeView.bg
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setSelected(atIdx:Int) {
        for (idx,btn) in self.titleBtns.enumerated() {
            btn.isSelected = (idx == atIdx)
        }
    }
    
    func bindTitleBar(with titles:[String],indicatorColors:[UIColor]=[UIColor.ThemeLabel.colorHighlight,UIColor.ThemeLabel.colorHighlight]) {
        if self.titleBtns.count > 0 {
            for btn in titleBtns {
                btn.removeFromSuperview()
            }
            self.titleBtns.removeAll()
        }
        
        var lastItem:EXTitleBarItem?
        for (idx,title)  in titles.enumerated() {
            let titleBtn = EXTitleBarItem()
            titleBtn.indicatorWidth.constant = style.indicatorWidth
            titleBtn.indicatorHeight.constant = style.indicatorHeight
            titleBtn.btnItem.tag = idx
            titleBtn.setFont(style.titleFont)
            titleBtn.setTitle(title)
            titleBtn.setTitleColor(self.style.titleColor, state:.normal)
            titleBtn.setTitleColor(self.style.titleHighLightColor, state: .selected)
            if indicatorColors.count > idx {
                let color = indicatorColors[idx]
                titleBtn.selectedColor = color
            }
            titleBtn.btnItem.addTarget(self, action: #selector(onTitleBtnAction(sender:)), for: .touchUpInside)
            self.baseScroll.addSubview(titleBtn)
            self.titleBtns.append(titleBtn)
        
            if  titles.count == 1 {
                titleBtn.snp.makeConstraints { (make) in
                    make.left.equalTo(style.startX)
                    make.right.lessThanOrEqualTo(baseScroll.snp.right)
                    make.centerY.equalToSuperview()
                    make.top.bottom.equalToSuperview()
                }
            }else {
                if let btn = lastItem {
                    if idx == titles.count - 1 {
                        titleBtn.snp.makeConstraints { (make) in
                            make.left.equalTo(btn.snp.right).offset(self.style.horizonGap)
                            make.right.lessThanOrEqualTo(baseScroll.snp.right)
                            make.centerY.equalToSuperview()
                            make.top.bottom.equalToSuperview()
                        }
                    }else {
                        titleBtn.snp.makeConstraints { (make) in
                            make.left.equalTo(btn.snp.right).offset(self.style.horizonGap)
                            make.centerY.equalToSuperview()
                            make.top.bottom.equalToSuperview()
                        }
                    }
                }else {
                    titleBtn.snp.makeConstraints { (make) in
                        make.left.equalTo(style.startX)
                        make.centerY.equalToSuperview()
                        make.top.bottom.equalToSuperview()
                    }
                }
            }
            lastItem = titleBtn
        }
        self.setSelected(atIdx: 0)
    }
    
    @objc func onTitleBtnAction(sender:UIButton) {
        for btn in titleBtns {
            btn.isSelected = (btn.btnItem == sender)
        }
        self.titleBarCallback?(sender.tag)
    }
}

