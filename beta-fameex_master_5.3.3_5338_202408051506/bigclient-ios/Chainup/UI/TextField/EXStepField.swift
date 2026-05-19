//
//  EXStepField.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

/*
 self.textfieldValueChangeBlock?(value)
 self.textfieldDidBeginBlock?()
 self.textfieldDidEndBlock?()
 */

//Input box of percentage: 25%/50%/75%/100%. The maximum number of inputs can be processed: one Decimal separator and negative number

import UIKit
import RxSwift

enum EXStepFieldLayout {
    case horizon
    case vertical
}

class EXStepField: EXBaseField {
    //Pass decimal, choose one from two
//    var decimal:String = "0" {
//        didSet {
//            print(decimal)
//        }
//    }
    var layoutType:EXStepFieldLayout = .horizon
    @IBOutlet var input: UITextField!
    @IBOutlet var baseLine: UIView!
    let disposebg = DisposeBag()
    let style = EXTextFieldStyle()
    @IBOutlet var leftBg: EXStepLBg!
    @IBOutlet var minusBtn: UIButton!
    @IBOutlet var plusBtn: UIButton!
    @IBOutlet var minusBtnR: UIButton!
    var inputText = ""
    var highLightColor:UIColor = UIColor.ThemeView.highlight {
        didSet {
            style.highlightColor = highLightColor
        }
    }
    @IBOutlet var vLineR: UIView!
    @IBOutlet var vLineL: UIView!
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    override func onCreate() {
        super.onCreate()
        self.vLineL.isHidden = true
        self.vLineR.isHidden = true
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.ThemeView.border.cgColor
       
        configLayouts(type: .horizon)
        style.bindHighlight(textField: input, effectView: self,isBorder: true)
        self.presenter.configWithTextField(input: input)
    }
    
    func configLayouts(type:EXStepFieldLayout) {
        if type == .horizon {
            self.vLineL.isHidden = true
            self.vLineR.isHidden = true
            minusBtn.backgroundColor = UIColor.ThemeView.bg
            plusBtn.backgroundColor = UIColor.ThemeView.bg

            minusBtn.setImage(UIImage.themeImageNamed(imageName: "exchange_reduction"), for: .normal)
            plusBtn.setImage(UIImage.themeImageNamed(imageName: "exchange_increase"), for: .normal)
            input.textAlignment = .center
            minusBtnR.isHidden = true
            leftBg.isHidden = false
            leftBg.snp.remakeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.width.equalTo(40)
            }
        }else {
            self.vLineL.isHidden = false
            self.vLineR.isHidden = false
            minusBtnR.backgroundColor = UIColor.ThemeView.bgTab
            plusBtn.backgroundColor = UIColor.ThemeView.bgTab
            minusBtnR.setImage(UIImage.themeImageNamed(imageName: "transaction_triangle_down"), for: .normal)
            plusBtn.setImage(UIImage.themeImageNamed(imageName: "transaction_triangle_up"), for: .normal)
            leftBg.snp.remakeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.width.equalTo(5)
            }
            input.textAlignment = .left
            minusBtnR.isHidden = false
            leftBg.isHidden = true
        }
    }
    
    func updateHighLightColor(_ color:UIColor) {
        self.style.highlightColor = color
    }
    
    override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    override func setText(text: String) {
        input.text = text
        inputText = text
//        input.sendActions(for: .valueChanged)
    }

    @IBAction func stepBack(_ sender: Any) {
        if let coinDecimal = Int(self.decimal) {
            
            let number = NSDecimalNumber.init(value: 1).multiplying(byPowerOf10: Int16(coinDecimal))
            let base = "1" as NSString
            let step = base.dividing(by: number.stringValue, decimals: coinDecimal)
            
            if inputText.isEmpty {
                let nsZero = "0" as NSString
                let nsRst = nsZero.subtracting(step, decimals: coinDecimal)
                if let rst = nsRst {
                    let result = rst as NSString
                    if result.isBig("0") {
                        input.text = rst
                    }else {
                        input.text = "0"
                    }
                    input.sendActions(for: .valueChanged)
                }

            }else {
                let nsZero =  inputText as NSString
                let nsRst = nsZero.subtracting(step, decimals: coinDecimal)
                if let rst = nsRst {
                    let result = rst as NSString
                    if result.isBig("0") {
                        input.text = rst
                    }else {
                        input.text = "0"
                    }
                    input.sendActions(for: .valueChanged)
                }
            }
        }
    }
    
    @IBAction func stepForward(_ sender: Any) {
        if let coinDecimal = Int(decimal) {
            
            let number = NSDecimalNumber.init(value: 1).multiplying(byPowerOf10: Int16(coinDecimal))
            let base = "1" as NSString
            let step = base.dividing(by: number.stringValue, decimals: coinDecimal)
            
            if inputText.isEmpty {
                let nsZero = "0" as NSString
                let nsRst = nsZero.adding(step, decimals: coinDecimal)
                if let rst = nsRst {
                    let result = rst as NSString
                    if result.isBig("0") {
                        input.text = rst
                    }else {
                        input.text = "0"
                    }
                    input.sendActions(for: .valueChanged)
                }
                
            }else {
                let nsZero =  inputText as NSString
                let nsRst = nsZero.adding(step, decimals: coinDecimal)
                if let rst = nsRst {
                    let result = rst as NSString
                    if result.isBig("0") {
                        input.text = rst
                    }else {
                        input.text = "0"
                    }
                    input.sendActions(for: .valueChanged)
                }
            }
        }
    }
}

extension EXStepField :ExTextFieldProtocol {
    
    func textValueChanged(value: String) {
        inputText = value
        self.textfieldValueChangeBlock?(value)
    }
    
    func inputDidBeginEditing() {
        self.hideError(input)
        self.textfieldDidBeginBlock?()
    }
    
    func inputDidEndEditing() {
        self.textfieldDidEndBlock?()
    }
}

extension EXStepField : EXTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.baseLine
    }
}

