//
//  EXSliderInputView.swift
//  Chainup
//
//  Created by cwd on 2022/11/16.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
//带滑杆的输入框 English: Input box with sliding bar
class EXSliderInputView: EXCOCustomBaseView {
    
    var openOrderType: EXOpenOrderType = .qty
    var popViewShowBlock: EXComVoidBlock?
    var popViewDismissBlock: EXComVoidBlock?
    var selectedOpenType: ((EXOpenOrderType) -> ())?
    var maxValue:String = ""
    var decimal:String = "" {
        didSet{
            if !decimal.contains(".") {
                decimal =  "1".mapPrecision(decimal)
            }
            stepInput.decimal = decimal
        }
    }
    var openTypeUnit = [EXSBouncedModel]() {
        didSet{
            if self.openOrderType == .qty {
                lastWidth = typeBtn.text(content: openTypeUnit[0].name )
            }else{
                lastWidth = typeBtn.text(content: openTypeUnit[1].name )
            }
            
        }
    }
    var lastWidth: CGFloat = 50
    override class var viewHeight: CGFloat{
        return 40 + 8 + 16
    }
    
    //MARK: lifecycle
    override func setSubView(){
        self.addSubViews([stepInput,typeBtn])
        typeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(1)
            make.width.equalTo(30)
            make.height.equalTo(40)
        }
        stepInput.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(1)
            make.left.equalToSuperview()//.offset(1)
            make.right.equalTo(typeBtn.snp.left).offset(-5)
            make.height.equalTo(40)
            make.centerY.equalTo(typeBtn)
        }
        
        self.addSubViews([slider])
        slider.snp.makeConstraints { make in
            make.top.equalTo(stepInput.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(2)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        stepInput.exs_roundCorners(corners: .allCorners, radius: 4)
    }
    
    lazy var container: UIView = {
        let v = UIView()
        return v
    }()
    //切换对手价档位 English: Switch to opponent price level
    lazy var typeBtn : EXSDirectionButton = {
        let btn = EXSDirectionButton()
        btn.paddingleftRight = 10
        btn.spaceBetweenImageAndTitle = 6
        btn.setAlighment(margin: .marginCenter)
        btn.backgroundColor =  UIColor.getConfigBg()
        btn.container.backgroundColor = UIColor.getConfigBg()
        btn.ext_UseAutoLayout()
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.titleLabel.font = UIFont.ThemeFont.BodyRegular
        btn.addTarget(self, action: #selector(clicktypeButton), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    //MARK: lazy
    lazy var stepInput: EXSBorderField = {
        let textField = EXSBorderField()
        textField.ext_UseAutoLayout()
        textField.input.textColor = UIColor.ThemeLabel.colorLite
        textField.unitLabel.text = ""
        textField.onlyInput = true
        textField.layer.cornerRadius = 4
        textField.bgView.layer.cornerRadius = 4
        textField.bgView.layer.masksToBounds = true
        textField.bgView.backgroundColor =  UIColor.getConfigBg()//UIColor.ThemeView.card2
        textField.input.textAlignment = .center
        textField.input.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
    
    
    lazy var slider: EXNewLeverageSliderView = {
        let v = EXNewLeverageSliderView(frame: .zero, minLevel: 0, maxLevel: 100, availableLevel: 0, showTopTip: true)
        return v
    }()
}
extension EXSliderInputView{
    
    func updateTypeBtn(show: Bool){
        var w = lastWidth
        var right = 0
        if show == false{
            w = 0
            right = 5
            typeBtn.isHidden = true
        }else{
            typeBtn.isHidden = false
        }
        typeBtn.snp.updateConstraints { make in
            make.width.equalTo(w)
            make.right.equalToSuperview().offset(right)
        }
        self.layoutIfNeeded()
    }
    
    @objc func clicktypeButton(sender:UIButton) {
        AppService.topViewController()?.view.endEditing(true)
        self.popViewShowBlock?()
        self.endEditing(true)
        let popover = EXPopover(options: EXPopover.commonTradePopOption, showHandler: nil, dismissHandler: nil)
        popover.popoverColor = UIColor.ThemeView.alertBg
        popover.didDismissHandler = { [weak self] in
            self?.popViewDismissBlock?()
            self?.typeBtn.normalStyle()
        }
        let models = self.openTypeUnit
        orderWaysModel()
        let width = self.sg_width
        let view = EXSBouncedView.init(frame: CGRect(x: 0, y: 0, width:width, height: CGFloat(models.count * 36)))
        view.setData(models,cellHeight: 36)
        view.clickViewIndexBlock = {[weak self] index  in
            popover.dismiss()
            guard let mySelf = self else{return}
            let model = mySelf.openTypeUnit[index]
            mySelf.openOrderType = model.openType
            mySelf.selectedOpenType?(model.openType)
            mySelf.typeBtn.normalStyle()
            _ = mySelf.typeBtn.text(content: model.name)
            if model.openType == .qty{
                if model.name == "cp_overview_text9".ex_localized() {
                    EXNewTracking.shared.track(event: .swapOpenOrderSheet, info: [:])
                }else{
                    EXNewTracking.shared.track(event: .swapOpenOrderCoin, info: [:])
                }
            }else{
                EXNewTracking.shared.track(event: .swapOpenOrderValue, info: [:])
            }
        }
        view.clickViewBlock = {  act in
            if act == .indicator {
                let alert = EXCommonAlert()
                alert.configAlert(title: "order_setting_text3".ex_localized(), message: "order_setting_text4".ex_localized(),onlyOneBtnTitle: "cp_calculator_text16".ex_localized(),bottomOnlyOneBtn: true) { type in
                    EXAlert.dismiss()
                }
                EXAlert.showAlert(alertView: alert,touchCanDissmiss: true)
            }
        }
        popover.show(view, fromView: self)
    }
    func orderWaysModel() {
        for model in openTypeUnit {
            model.selectedColor = (self.openOrderType == model.openType) ? UIColor.ThemeView.bgTab : UIColor.ThemeView.alertBg
            model.titleColor = (self.openOrderType == model.openType) ? UIColor.ThemeView.highlight : UIColor.ThemeLabel.colorLite
        }
    }
    func reset(callback:Bool? = false){
        self.stepInput.input.text = ""
        //        self.stepInput.percent = false
        self.slider.reset(callback: callback)
    }
    
    func emptyPersentage() {
        slider.reset()
    }
    
    func setPlaceHolder(placeHolder: String,font : CGFloat = 14) {
        stepInput.input.exs_setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    func setText(text: String) {
        stepInput.input.text = text
    }
}

