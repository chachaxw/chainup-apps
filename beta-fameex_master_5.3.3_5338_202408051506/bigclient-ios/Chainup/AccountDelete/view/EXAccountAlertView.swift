//
//  EXAccountAlertView.swift
//  Chainup
//
//  Created by cwd on 2023/2/9.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
/*
Account destory_text7 "=" Does not meet the requirement for account cancellation: ";
Account destory_text8 "=" Spot trading: no pending orders ";
Account destory_text9 "=" Leveraged transactions: no pending orders or loans ";
Account destory_text10 "=" Contract transaction: no pending orders or positions ";
Account destory_text11 "=" Legal currency transaction: no orders in progress (including advertisements) ";
Account destory_text12 "=" Account total assets<0.001 BTC ";
 */


class EXAccountAlertView: EXCustomBaseView {
    
    class func getDataList() -> [String]{
        var restult = [String]()
        restult.append("account_destory_text8".localized()) //Spot
        if EXAppConfigManager.sharedInstance.didOpenLever(){
            restult.append("account_destory_text9".localized()) //lever
        }
        if EXAppConfigManager.sharedInstance.didOpenContract(){
            restult.append("account_destory_text10".localized()) //contract
        }
        if EXAppConfigManager.sharedInstance.didOpenFiat(){
            restult.append("account_destory_text11".localized()) //Orders or advertisements
        }
        restult.append("account_destory_text12".localized()) //asset
        return restult
    }
    var sureDeleteBlock: EXComVoidBlock?
    var dataList = EXAccountAlertView.getDataList()
    var resultList = [Bool]() {
        didSet{
            var passed = true
            for (index,item) in resultList.enumerated(){
                if item == false{
                    passed = false
                }
                if let cell = stack.arrangedSubviews[index] as? EXAccountAlertViewCell{
                    cell.pass = item
                }
            }
            
            if passed{
                titleLabel.text = "account_destory_text15".localized()
            }
            surebtn.isEnabled = passed
        }
    }
    override func setSubView() {
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.addSubview(titleLabel)
        self.addSubview(stack)
        self.addSubview(cancelbtn)
        self.addSubview(surebtn)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.greaterThanOrEqualTo(20)
        }
        stack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        cancelbtn.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
        surebtn.snp.makeConstraints { make in
            make.top.equalTo(cancelbtn)
            make.left.equalTo(cancelbtn.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(cancelbtn.snp.width)
            make.height.equalTo(44)
        }
        
        for item in dataList{
            let v = EXAccountAlertViewCell()
            v.content = item
            stack.addArrangedSubview(v)
        }
                
    }

    ///Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"account_destory_text7".localized(), font: UIFont.ThemeFont.HeadMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.center)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()

    
    
    lazy var stack: UIStackView  = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.spacing = 16
        stack.axis = .vertical
        stack.alignment = .fill
        stack.backgroundColor = UIColor.ThemeView.alertBg
        return stack
    }()
   
    //Send button
    lazy var cancelbtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.clearColors()
        btn.backgroundColor = UIColor.ThemeView.card2
        btn.setTitle("common_text_btnCancel".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for:.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.getFont(size: 14, aweight: .medium)
        btn.extSetAddTarget(self, #selector(cancel))
        return btn
    }()
    
    
    lazy var surebtn:EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.color = UIColor.ThemeBtn.highlight
        btn.setTitle("account_destory_text1".localized(), for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.getFont(size: 14, aweight: .medium)
        btn.setTitleColor(UIColor.white, for:.normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.disabled)
//        if EXThemeManager.isNight(){
////            btn.disabledColor  = UIColor.ThemeBtn.disable
//            btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.disabled)
////            btn.backgroundColor = UIColor.ThemeBtn.disable2
//        }else{
//            btn.setTitleColor(UIColor.white, for: UIControl.State.disabled)
////            btn.backgroundColor = UIColor.ThemeBtn.disable2
////            btn.disabledColor = UIColor.extColorWithHex("#C5C9D5")
//
//        }
       
        btn.extSetAddTarget(self, #selector(sure))
        return btn
    }()
    
    class func getTotalHeight() -> CGFloat{
        let dataList = EXAccountAlertView.getDataList()
        let w = SCREEN_WIDTH - 91 - 63
        
        var h : CGFloat = 0
        for item in dataList{
            h += (item.textSizeWithFont(UIFont.ThemeFont.BodyMedium, width: w).height + 16 + 26)
        }
        return h
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: .allCorners, radius: 12)
    }
 
    @objc func cancel(){
        EXAlert.dismiss()
    }
    @objc func sure(){
        self.sureDeleteBlock?()
    }
}



class EXAccountAlertViewCell: EXCustomBaseView{
    
    var content: String? {
        didSet{
            titleLabel.text = content
        }
    }
    var pass: Bool = false {
        didSet{
            let imageName = pass ? "public_complete" : "public_incomplete"
            img.image = UIImage(named: imageName)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: .allCorners, radius: 4)
    }
    override func setSubView() {
        self.backgroundColor = UIColor.ThemeView.card2
        self.addSubViews([img,titleLabel])
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-13)
        }
        img.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(15)
            make.width.height.equalTo(16)
        }
    }
    lazy var img : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage(named: "public_incomplete")
        return arrowImmg
    }()
    ///Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
}
 

