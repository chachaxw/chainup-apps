//
//  EXTransferField.swift
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

//发币的输入框

import UIKit
import RxSwift

public class EXTransferField: EXBaseField {
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var input: UITextField!
    @IBOutlet public var baseLine: UIView!
    @IBOutlet public var bottomLabel: UILabel!
    @IBOutlet public var symbolLabel: UILabel!
    private var avalibleBalance :String=""
    public let style = EXTextFieldStyle.commonStyle
    public let disposebg = DisposeBag()
    @IBOutlet public var middleView: UIView!
    
    public var placeHolder:String = ""{
        didSet {
            input.placeholder = placeHolder
        }
    }
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    public override func onCreate() {
        super.onCreate()
        middleView.backgroundColor = UIColor.ThemeView.bg
        style.bindHighlight(textField: input, effectView: baseLine)
        self.presenter.configWithTextField(input: input)
    }
    
    public func updateField(symbol:String,balance:String) {
        avalibleBalance = balance
        bottomLabel.text = balance + symbol
        symbolLabel.text = symbol
    }

    @IBAction public func allInAction(_ sender: Any) {
        input.text = avalibleBalance
        input.sendActions(for: .valueChanged)
    }
    
    override public func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    override public func setText(text: String) {
        input.text = text
    }
}

extension EXTransferField : EXTextFieldPresenterProtocol {
    
    
    public func textValueChanged(value: String) {
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

extension EXTransferField : EXTextFieldConfigurable {
    
    public var baseField: UITextField {
        return self.input
    }
    
    public var baseHighlight: UIView {
        return self.baseLine
    }
}
