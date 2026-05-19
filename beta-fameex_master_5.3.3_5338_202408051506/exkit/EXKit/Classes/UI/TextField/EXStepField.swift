//
//  EXStepField.swift
//  Chainup
//
//  Created by liuxuan on2020/3/6.
//  Copyright ©2020 zewu wang. All rights reserved.
//

/*
 self.textfieldValueChangeBlock?(value)
 self.textfieldDidBeginBlock?()
 self.textfieldDidEndBlock?()
 */

//百分比的输入框,25%/50%/75%/100%.处理最多输入，处理小数点1个，负数处理

import UIKit
import RxSwift

public enum EXStepFieldLayout {
    case horizon
    case vertical
}

public class EXStepField: EXBaseField {
    public var layoutType:EXStepFieldLayout = .horizon
    @IBOutlet public var input: UITextField!
    @IBOutlet public var backgroundView: UIView!
    @IBOutlet public var baseLine: UIView!
    public let disposebg = DisposeBag()
    public let style = EXTextFieldStyle()
    @IBOutlet public var leftBg: UIView!
    @IBOutlet public var minusBtn: UIButton!
    @IBOutlet public var rightBg: UIView!
    @IBOutlet public var plusBtn: UIButton!
    @IBOutlet public var minusBtnR: UIButton!
    public var inputText = ""
    public var highLightColor:UIColor = UIColor.ThemeView.highlight {
        didSet {
            style.highlightColor = highLightColor
        }
    }
    @IBOutlet public var vLineR: UIView!
    @IBOutlet public var vLineL: UIView!
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    public override func onCreate() {
        super.onCreate()
        self.vLineL.isHidden = true
        self.vLineR.isHidden = true
        self.nibView.backgroundColor = .clear
        self.nibView.extSetCornerRadius(4)
        self.nibView.extSetBorderWidth(0.5, color: .clear)
        self.extSetCornerRadius(4)
        self.extSetBorderWidth(0.5, color: .clear)
    
        configLayouts(type: .horizon)
        style.normalBorderColor = .clear
        style.bindHighlight(textField: input, effectView: self,isBorder: true)
        self.presenter.configWithTextField(input: input)
    }
    
    public func configLayouts(type:EXStepFieldLayout) {
        if type == .horizon {
            self.vLineL.isHidden = true
            self.vLineR.isHidden = true
            minusBtn.setImage(EXKitBundle.image(named: "trade_reduce"), for: .normal)
            plusBtn.setImage(EXKitBundle.image(named: "trade_add"), for: .normal)
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
            minusBtnR.setImage(UIImage.themeImageNamedFromPod(imageName: "transaction_triangle_down"), for: .normal)
            plusBtn.setImage(UIImage.themeImageNamedFromPod(imageName: "transaction_triangle_up"), for: .normal)
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
    
    public func updateBackgroundColor(with color:UIColor?) {
        backgroundView.backgroundColor = color
        leftBg.backgroundColor = .clear
        rightBg.backgroundColor = .clear
        minusBtn.backgroundColor = color
        plusBtn.backgroundColor = color
    }
    
    public func updateHighLightColor(_ color:UIColor) {
        self.style.highlightColor = color
    }
    
    public override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    public override func setText(text: String) {
        input.text = text
        inputText = text
//        input.sendActions(for: .valueChanged)
    }

    @IBAction public func stepBack(_ sender: Any) {
        if let coinDecimal = Int(self.decimal) {
            
            let number = NSDecimalNumber.init(value: 1).multiplying(byPowerOf10: Int16(coinDecimal))
            let base = "1" as NSString
            let step = base.dividing(by: number.stringValue, decimals: coinDecimal)

                let nsZero =  (text ?? "0") as NSString
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
    
    @IBAction public func stepForward(_ sender: Any) {
        if let coinDecimal = Int(decimal) {
            
            let number = NSDecimalNumber.init(value: 1).multiplying(byPowerOf10: Int16(coinDecimal))
            let base = "1" as NSString
            let step = base.dividing(by: number.stringValue, decimals: coinDecimal)
                
                let nsZero = (text ?? "0") as NSString
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

extension EXStepField : EXTextFieldProtocol {
    public var textField: UITextField { input }
}

extension EXStepField :EXTextFieldPresenterProtocol {
    
    public func textValueChanged(value: String) {
        inputText = value
        self.textfieldValueChangeBlock?(value)
    }
    
    public func inputDidBeginEditing() {
        self.hideError(input)
        self.textfieldDidBeginBlock?()
    }
    
    public func inputDidEndEditing() {
        self.textfieldDidEndBlock?()
    }
}

extension EXStepField : EXTextFieldConfigurable {
    
    public var baseField: UITextField {
        return self.input
    }
    
    public var baseHighlight: UIView {
        return self.baseLine
    }
}
