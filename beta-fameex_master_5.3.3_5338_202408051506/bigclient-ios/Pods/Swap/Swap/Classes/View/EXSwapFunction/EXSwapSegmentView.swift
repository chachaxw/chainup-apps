//
//  EXSwapSegmentView.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/12/20.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXSwapSegmentView: UIView {
    typealias ClickBtnBlock = (Int) -> ()
    var clickBtnBlock : ClickBtnBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ThemeNav.bg
        exs_addSubViews([openBtn,closeBtn,positionBtn,priceLabel,rateLabel,lineV])
        openBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.width.greaterThanOrEqualTo(40)
            make.bottom.equalToSuperview()
            make.height.equalTo(42)
        }
        closeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(openBtn.snp.right).offset(20)
            make.bottom.equalToSuperview().offset(-0)
            make.width.greaterThanOrEqualTo(40)

            make.height.equalTo(42)
        }
        positionBtn.snp.makeConstraints { (make) in
            make.left.equalTo(closeBtn.snp.right).offset(20)
            make.width.greaterThanOrEqualTo(40)
            make.bottom.equalToSuperview()
            make.height.equalTo(42)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(openBtn).offset(-8)
            make.height.equalTo(16)
        }
        rateLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(openBtn).offset(10)
            make.height.equalTo(12)
        }
        lineV.snp.makeConstraints { (make) in
            make.centerX.equalTo(openBtn)
            make.bottom.equalToSuperview()
            make.height.equalTo(3)
            make.width.equalTo(20)
        }
    }
    
    func updateUIForSingleWayStatus() {
        openBtn.setTitle("cp_content_text23".ex_localized(), for: .normal)
        closeBtn.isHidden = true
        positionBtn.snp.remakeConstraints { (make) in
            make.left.equalTo(openBtn.snp.right).offset(40)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(22)
        }
        if closeBtn.isSelected {
            
            reloadLineV(openBtn)
        }
    }
    
    func updateUIForBothWayStatus() {
        openBtn.setTitle( "cp_overview_text1".ex_localized(), for: .normal)
        closeBtn.isHidden = false
        positionBtn.snp.remakeConstraints { (make) in
            make.left.equalTo(closeBtn.snp.right).offset(40)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(22)
        }
    }
    
    @objc func clickBtn(_ btn : UIButton){
        reloadBtnStatus(btn)
        self.clickBtnBlock?(btn.tag)//1000 开仓 1001 平仓 1001 持仓 English: 1000 opening 1001 closing 1001 holding
    }
    
    func reloadBtnStatus(_ btn : UIButton){
        btn.isSelected = true
        if btn.tag == 1000 {
            closeBtn.isSelected = false
            positionBtn.isSelected = false
        } else if btn.tag == 1001 {
            openBtn.isSelected = false
            positionBtn.isSelected = false
        } else if btn.tag == 1002 {
            openBtn.isSelected = false
            closeBtn.isSelected = false
        }
        reloadLineV(btn)
    }
    
    func reloadLineV(_ btn : UIButton){
        lineV.snp.remakeConstraints { (make) in
            make.centerX.equalTo(btn)
            make.bottom.equalToSuperview()
            make.height.equalTo(3)
            make.width.equalTo(20)
        }
    }
    
//    func setView(_ tick : PriceTick){
//        priceLabel.text = tick.close
//        priceLabel.textColor = tick.rose_Color
//    }
    
    func reloadView(){
        priceLabel.text = "--"
        priceLabel.textColor = UIColor.ThemeLabel.colorLite
    }
    
    func updateHoldPositionNumber(_ volume : String) {
        
        DispatchQueue.global().async {
        
            var attrString = NSMutableAttributedString()
            var selectedAttrString = NSMutableAttributedString()
            if volume == "0" {
                attrString = NSMutableAttributedString().exs_add(string:  "cp_order_text1".ex_localized(), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium, NSAttributedString.Key.font : UIFont.ThemeFont.HeadBold])
                selectedAttrString = NSMutableAttributedString().exs_add(string:  "cp_order_text1".ex_localized(), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite, NSAttributedString.Key.font : UIFont.ThemeFont.HeadBold])
            } else {
                attrString = NSMutableAttributedString().exs_add(string:  "cp_order_text1".ex_localized(), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium, NSAttributedString.Key.font : UIFont.ThemeFont.HeadBold]).exs_add(string: String(format: "【%@】", volume), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium, NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryBold])
                selectedAttrString = NSMutableAttributedString().exs_add(string:  "cp_order_text1".ex_localized(), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite, NSAttributedString.Key.font : UIFont.ThemeFont.HeadBold]).exs_add(string: String(format: "【%@】", volume), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite, NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryBold])
            }
            
            DispatchQueue.main.async {
            
                self.positionBtn.setAttributedTitle(attrString, for: .normal)
                self.positionBtn.setAttributedTitle(selectedAttrString, for: .selected)
            }
        }
    }
    
// MARK: - lazy
    lazy var openBtn : UIButton = { // 开仓 English: open a granary to provide relief
        let btn = UIButton()
        btn.ext_UseAutoLayout()
        btn.layoutIfNeeded()
        btn.tag = 1000
        btn.setTitle( "cp_overview_text1".ex_localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for:.selected)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.isSelected = true
        btn.ext_SetAddTarget(self, #selector(clickBtn(_:)))
        return btn
    }()
    
    lazy var closeBtn : UIButton = { // 平仓 English: Closing position
        let btn = UIButton()
        btn.ext_UseAutoLayout()
        btn.layoutIfNeeded()
        btn.tag = 1001
        btn.setTitle( "cp_overview_text2".ex_localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for:.selected)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.ext_SetAddTarget(self, #selector(clickBtn(_:)))
        return btn
    }()
    
    lazy var positionBtn : UIButton = { // 持仓 English: Position
        let btn = UIButton()
        btn.ext_UseAutoLayout()
        btn.layoutIfNeeded()
        btn.tag = 1002
        let attrString = NSMutableAttributedString().exs_add(string:  "cp_order_text1".ex_localized(), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium, NSAttributedString.Key.font : UIFont.ThemeFont.HeadBold])
        let selectedAttrString = NSMutableAttributedString().exs_add(string:  "cp_order_text1".ex_localized(), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite, NSAttributedString.Key.font : UIFont.ThemeFont.HeadBold])
        btn.setAttributedTitle(attrString, for: .normal)
        btn.setAttributedTitle(selectedAttrString, for: .selected)
        btn.ext_SetAddTarget(self, #selector(clickBtn(_:)))
        btn.isHidden = true
        return btn
    }()
    
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.HeadBold
        label.text = "--"
        label.textColor = UIColor.ThemekLine.up
        return label
    }()
    
    lazy var rateLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.MinimumRegular
        label.text = "--"
        label.textColor = UIColor.ThemekLine.up
        label.backgroundColor = UIColor.ThemekLine.up15
        label.layer.cornerRadius = 1
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.highlight
        return view
    }()
    
    func updateData(priceText:String,rateText:String,bgColor:UIColor) {
        
        if EXSTools.colorWithUpAndDownText(rateText) != nil {
            self.priceLabel.textColor = EXSTools.colorWithUpAndDownText(rateText)
            self.rateLabel.textColor = EXSTools.colorWithUpAndDownText(rateText)
        }
        self.priceLabel.text = priceText
        if rateText.greaterThan(BTZERO) {
            self.rateLabel.text = " +\(rateText) "

        }else {
            self.rateLabel.text = " \(rateText) "
        }
        
        self.rateLabel.backgroundColor = bgColor
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


