//
//  EXSStepInputView.swift
//  Chainup
//
//  Created by cwd on 2022/11/16.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
typealias StepBlock = (_ value:String, _ percent:Bool) -> ()
typealias TextFieldDidBeginBlock = () -> ()
class EXSStepInputView: EXCOCustomBaseView {
    var textfieldDidBeginBlock : TextFieldDidBeginBlock?
    var textValueChangeBLock: EXComStringBlock?
    var stepBtnsBlock: StepBlock? //传出去是否是百分比输入 English: Is it a percentage input when transmitting
    let style = EXSTextFieldStyle.commonStyle
    var percent = false //是否是百分比输入 English: Is it a percentage input
    var showStepBtn = true { //是否需要加减按钮 English: Do you need an add/subtract button
        didSet{
            if showStepBtn == false{
                minusBtn.isHidden = true
                plusBtn.isHidden = true
            }
        }
    }
    //MARK: 这个必须传，步进单位 English: MARK: This must be passed, step unit
    var decimal:String = "" {
        didSet{
            self.precision = String(decimal.to_Precision())
        }
    }
    var precision: String = "0"
    //MARK: lifecycle
    override func setSubView() {
        super.setSubView()
        initLayout()
        style.bindHighlight(textField: input, effectView: self,isBorder: true)
        self.addAction()
    }
    
    //MARK: lazy
    lazy var input : UITextField = {
       let textField = UITextField()
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.textColor = UIColor.ThemeLabel.colorLite
        textField.font = UIFont.ThemeFont.BodyMedium
        textField.textAlignment = .center
        return textField
    }()
    
    lazy var minusBtn:UIButton = {
        let btn = UIButton.init(type: .custom) //ui 给图命名错误 English: UI named the graph incorrectly
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_add"), for: .normal)
        return btn
    }()
    
    lazy var plusBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_reduce"), for: .normal)
        return btn
    }()
    
    
    func initLayout() {
        self.backgroundColor = UIColor.getConfigBg() //ThemeView.card2
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.getConfigBg().cgColor
        self.layer.cornerRadius = 4
        self.exs_addSubViews([input,minusBtn,plusBtn])

        self.input.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(44)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.right.equalTo(-44)
        }
        
        self.minusBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(38)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.plusBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.width.equalTo(38)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
//MARK: action
extension EXSStepInputView{
    
    func addAction(){
        self.input.addTarget(self, action: #selector(inputOnBegin), for: .editingDidBegin)
        self.input.addTarget(self, action: #selector(inputChange), for: .editingChanged)
        self.minusBtn.addTarget(self, action: #selector(stepSub), for: .touchUpInside)
        self.plusBtn.addTarget(self, action: #selector(stepAdd), for: .touchUpInside)
    }
    
    @objc func inputOnBegin() {
        self.textfieldDidBeginBlock?()
    }
    
    @objc func inputChange(){
        self.textValueChangeBLock?(self.input.text)
    }
    
    @objc func stepSub(){ //-
        feedbackGenerator()
        if var value = self.input.text,value.isEmpty == false{
            if self.percent {//百分号 English: Percentage sign
                if value.hasSuffix("%"){ //百分号 English: Percentage sign
                    value = value.components(separatedBy: "%")[0]
                    if value == "1" {
//                        self.stepBtnsBlock?("0",true)
//                        self.input.text = ""
                        return
                    }
                    value = value.bigSub("1")
                    self.stepBtnsBlock?(value,true)
                    value += "%"
                    self.input.text = value
                }
            }else{
                //MARK:  最小步数进单位 English: MARK: Minimum step count unit
                value = value.bigSub(self.decimal).exs_formatAmountUseDecimal(self.precision)
                if value.lessThan("0"){
                    return
                }
                self.input.text = value
                self.stepBtnsBlock?(value,false)
            }
        }else{ //输入框为空时 填入最小值 English: Fill in the minimum value when the input box is empty
            self.input.text = self.decimal
            self.stepBtnsBlock?(self.decimal,false)
        }
    }
    @objc func stepAdd(){ //+
        feedbackGenerator()
        if var value = self.input.text,value.isEmpty == false{
            if self.percent {//百分号 English: Percentage sign
                if value.hasSuffix("%"){ //百分号 English: Percentage sign
                    value = value.components(separatedBy: "%")[0]
                    if value == "100" {
                        return
                    }
                    value = value.bigAdd("1")
                    self.stepBtnsBlock?(value,true)
                    value += "%"
                    self.input.text = value
                }
            }else{
                //MARK:  最小步数进单位 English: MARK: Minimum step count unit
                value = value.bigAdd(self.decimal).exs_formatAmountUseDecimal(self.precision)
                self.input.text = value
                self.stepBtnsBlock?(value,false)
            }
        }else{ //输入框为空时 填入最小值 English: Fill in the minimum value when the input box is empty
            self.input.text = self.decimal
            self.stepBtnsBlock?(self.decimal,false)
        }
    }
}

