//
//  EXQuantAmountInputView.swift
//  Chainup
//
//  Created by wangdong on 2023/2/1.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXQuantAmountInputView: EXBaseField {

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var rightLabel: UILabel!
    
    var style = EXTextFieldStyle.commonStyle
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    @IBInspectable var placeHolder: String? {
        didSet {
            self.inputTextField.setPlaceHolderAtt(self.placeHolder?.localized() ?? "")
        }
    }
    
    override func onCreate() {
        nibView.backgroundColor = .clear
        nibView.extSetCornerRadius(4)
        nibView.extSetBorderWidth(0.5, color: .clear)
        extSetCornerRadius(4)
        extSetBorderWidth(0.5, color: .Ex.special2)
        backgroundColor = .Ex.special2
        rightLabel.textColor = .Ex.text1
        rightLabel.font = .Ex.medium(12)
        inputTextField.delegate = self
        inputTextField.keyboardType = .decimalPad
        inputTextField.font = .Ex.medium(14)
        style.normalBorderColor = .Ex.special2
        style.bindHighlight(textField: inputTextField, effectView: self,isBorder: true)
        presenter.configWithTextField(input: inputTextField)
    }
    
    func bindSymbol(symbol:String) {
        rightLabel.text = symbol.aliasName()
        self.symbol = symbol
    }
    
    override func setPlaceHolder(placeHolder: String, font: CGFloat) {
        inputTextField.setPlaceHolderAtt(placeHolder, color: UIColor.Ex.text3, font:font)
    }

}

extension EXQuantAmountInputView : EXTextFieldPresenterProtocol {
    
    func textValueChanged(value: String) {
        self.textfieldValueChangeBlock?(value)
    }
    
    func inputDidBeginEditing() {
        self.hideError(inputTextField)
        self.textfieldDidBeginBlock?()
    }
    
    func inputDidEndEditing() {
        self.textfieldDidEndBlock?()
    }
}
