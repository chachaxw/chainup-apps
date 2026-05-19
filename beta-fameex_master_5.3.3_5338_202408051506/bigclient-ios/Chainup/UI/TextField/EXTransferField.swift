//
//  EXTransferField.swift
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

//Input box for issuing coins

import UIKit
import RxSwift

class EXTransferField: EXBaseField {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var input: UITextField!
    @IBOutlet var baseLine: UIView!
    @IBOutlet var bottomLabel: UILabel!
    @IBOutlet var symbolLabel: UILabel!
    private var avalibleBalance :String=""
    let style = EXTextFieldStyle.commonStyle
    let disposebg = DisposeBag()
    @IBOutlet var middleView: UIView!
    
    var placeHolder:String = ""{
        didSet {
            input.placeholder = placeHolder
        }
    }
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    override func onCreate() {
        super.onCreate()
        middleView.backgroundColor = UIColor.ThemeView.bg
        style.bindHighlight(textField: input, effectView: baseLine)
        self.presenter.configWithTextField(input: input)
    }
    
    func updateField(symbol:String,balance:String) {
        avalibleBalance = balance
        bottomLabel.text = balance + symbol
        symbolLabel.text = symbol
    }

    @IBAction func allInAction(_ sender: Any) {
        input.text = avalibleBalance
        input.sendActions(for: UIControl.Event.valueChanged)
    }
    
    override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    override func setText(text: String) {
        input.text = text
    }
}

extension EXTransferField : ExTextFieldProtocol {
    
    
    func textValueChanged(value: String) {
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

extension EXTransferField : EXTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.baseLine
    }
}

