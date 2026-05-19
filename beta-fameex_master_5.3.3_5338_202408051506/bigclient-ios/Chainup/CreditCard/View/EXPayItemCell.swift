//
//  EXPayItemCell.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/28.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
import YYWebImage
class EXPayItemCell: EXBaseCell {
    typealias PayBlock = (_  pay: EXPayServiceinfo) ->()
    var vm = EXCreditCardViewModel()
    var buyBlock: PayBlock?
    var model: EXPayServiceinfo?{
        didSet{
            guard let m = model else {
                return
            }
            if let url = URL(string: m.service_pic){
                symbolImg.yy_setImage(with: url, placeholder: nil, options: YYWebImageOptions.allowBackgroundTask) { (img, url, type, s, error) in
                }
            }
             
            let payUnit =  model?.source_unit ?? ""//vm.isBuy ? vm.payCoin.name : vm.payCoin.mainChainSymbol
            let recieveUnt = model?.target_unit ?? ""//vm.isBuy ? vm.recieveCoin.mainChainSymbol : vm.recieveCoin.name
//            print("vm.isBuy = \(vm.isBuy) vm.rateModel?.rate =\(vm.rateModel?.rate ?? "")")
//            print("vm.payCoinName  = \(vm.payCoin.name)   mainChainSymbol=\(vm.payCoin.mainChainSymbol)")
//            print("vm.recieveCoin  = \(vm.recieveCoin.name)   mainChainSymbol =\(vm.recieveCoin.mainChainSymbol)")
            
            nameLabel.text = m.name
            valueLabel1.text = "10-30" + "sl_str_minutes".localized()
            valueLabel2.text = m.source_amount +  payUnit//vm.payCoin.name
            valueLabel3.text = m.target_amount  + recieveUnt //vm.recieveCoin.name
            
            let unit = payUnit + "/" + recieveUnt
            valueLabel4.text = (m.rate) +  unit
            let imageNames = m.payment_pic.components(separatedBy: ",")
            for (aId,item) in self.markContainer.arrangedSubviews.enumerated() {
                guard let imgV = item as? UIImageView else{
                    return
                }
                if aId < imageNames.count{
                    imgV.image = UIImage.themeImageNamed(imageName: imageNames[aId])
                }else{
                    imgV.isHidden = true
                }
            }
        }
    }
    
    
    lazy var symbolImg: UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.themeImageNamed(imageName: "icon_quickbuycoin_smiplex")
        return arrowImmg
    }()
    
    ///Name
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.Ex.text1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var markContainer: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.spacing = 10
        v.distribution = .fillEqually
        v.addArrangedSubviews([markImg1,markImg2,markImg3])
        v.alignment = .trailing
        return v
    }()
    lazy var markImg1: UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        return arrowImmg
    }()
    
    lazy var markImg2: UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        return arrowImmg
    }()
    
    lazy var markImg3: UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        return arrowImmg
    }()
    
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    
    //确认
    lazy var tipBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.setTitle("", for: .normal)
        btn.setTitle("", for: .highlighted)
        btn.setImage(.themeImageNamed(imageName: "public_hint").reSizeImage(reSize: CGSize(width: 12, height: 12)), for: .normal)
        btn.setEnlargeEdgeWithTop(30, left: 30, bottom: 30, right: 30)
        return btn
    }()
  
    ///
    lazy var titleLabel1: UILabel = {
        let label = UILabel(text: "creditCard_text5".localized(), font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    ///
    lazy var valueLabel1: UILabel = {
        let label = UILabel(text: "", font: UIFont.Ex.medium(14), textColor: UIColor.Ex.text1, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    ///
    lazy var titleLabel2: UILabel = {
        let label = UILabel(text: "creditCard_text1".localized(), font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    ///
    lazy var valueLabel2: UILabel = {
        let label = UILabel(text: "", font: UIFont.Ex.medium(14), textColor: UIColor.Ex.text1, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    ///
    lazy var titleLabel3: UILabel = {
        let label = UILabel(text: "creditCard_text2".localized(), font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    ///
    lazy var valueLabel3: UILabel = {
        let label = UILabel(text: "", font: UIFont.Ex.medium(14), textColor: UIColor.Ex.text1, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    ///
    lazy var titleLabel4: UILabel = {
        var t = "creditCard_text3".localized()
        t.removeLast()
        let label = UILabel(text: t, font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    ///
    lazy var valueLabel4: UILabel = {
        let label = UILabel(text: "", font:  UIFont.Ex.medium(14), textColor: UIColor.Ex.text1, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
//    lazy var sureBtn : EXSButton = {
//        let btn = EXSButton()
//        btn.ext_UseAutoLayout()
////        btn.ext_SetAddTarget(self, #selector(sure))
//        btn.setTitle("cp_overview_text14".ex_localized(), for: UIControl.State.normal)
//        btn.disabledColor = UIColor.ThemeLabel.colorDark
//        btn.color = UIColor.ThemeBtn.highlight
//        btn.isEnabled = false
//        return btn
//    }()
    
    lazy var buyBtn: EXButton = {
        let btn = EXButton()
        btn.ext_UseAutoLayout()
        btn.ext_SetAddTarget(self, #selector(buy))
        btn.disabledColor = UIColor.ThemeLabel.colorDark
        btn.color = UIColor.ThemeBtn.highlight
        btn.setTitle("otc_action_buy".localized(), for: .normal)
//        btnSell.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white, for: .selected)
        return btn
    }()
    
    lazy var gap: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.bgGap
        return v
    }()
    
    override func setUpView() {
        self.contentView.addSubViews([
            symbolImg,nameLabel,markContainer,
            line,
            titleLabel1,valueLabel1,
            titleLabel2,tipBtn,valueLabel2,
            titleLabel3,valueLabel3,
            titleLabel4,valueLabel4,
            buyBtn
        ])
//        buyBtn.isEnabled = false
        symbolImg.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(15)
            make.width.height.equalTo(30)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(symbolImg.snp.right).offset(8)
            make.centerY.equalTo(symbolImg)
        }
        markContainer.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(22)
        }
        for item in markContainer.arrangedSubviews {
            item.snp.makeConstraints { make in
                make.width.equalTo(30)
                make.height.equalTo(20)
            }
        }
        
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(symbolImg.snp.bottom).offset(8)
        }
        
        titleLabel1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(line.snp.bottom).offset(16)
        }
        valueLabel1.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(line.snp.bottom).offset(14)
        }
        
        titleLabel2.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel1.snp.bottom).offset(14)
        }
        tipBtn.snp.makeConstraints { make in
            make.left.equalTo(titleLabel2.snp.right).offset(4)
            make.width.height.equalTo(10)
            make.centerY.equalTo(titleLabel2)
        }
        valueLabel2.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel1.snp.bottom).offset(14)
        }
        
        titleLabel3.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel2.snp.bottom).offset(14)
        }
        valueLabel3.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel2.snp.bottom).offset(14)
        }
        
        titleLabel4.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel3.snp.bottom).offset(14)
        }
        valueLabel4.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel3.snp.bottom).offset(14)
        }
        
        buyBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel4.snp.bottom).offset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-34)
        }
    }
    
    @objc func buy(){
        self.buyBlock?(self.model!)
    }
    
    @objc func clickBtn(){
        
        let alert = EXCommonAlert()
        alert.configAlert(title:"dialog_tip_title".localized(), message:"quick_buy_choose3party_notice".localized(),
                          onlyOneBtnTitle: "guide_3".localized(), bottomOnlyOneBtn: true) { _ in
            EXAlert.dismiss()
        }
        EXAlert.showAlert(alertView: alert)
    }
}

