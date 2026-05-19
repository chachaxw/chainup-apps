//
//  EXOTCTradeTextField.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXOTCTradeTextField: EXBaseField {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionBtn: CMLocalizedButton!
    @IBOutlet var input: UITextField!
    @IBOutlet var bottomLeftLabel: UILabel!
    @IBOutlet var bottomRightLabel: UILabel!
    @IBOutlet var baseLine: UIView!
    let style = EXTextFieldStyle.commonStyle
    typealias ActionAllBlock = ()->()
    var sendAllCallback:ActionAllBlock?
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()

    override func onCreate() {
        super.onCreate()
        actionBtn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .normal)
        actionBtn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .selected)
        style.bindHighlight(textField: input, effectView: baseLine)
        self.presenter.configWithTextField(input: input)
    }
    
    override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    override func setText(text: String) {
        input.text = text
    }
    
    override func setTitle(title: String) {
        titleLabel.text = title
    }

    func setBottomLeftText(value:String) {
        bottomLeftLabel.text = value
    }
    
    func setBottomRightText(value:String) {
        bottomRightLabel.text = value
    }
    
    func setBottomRightTextColor(_ color:UIColor) {
        bottomRightLabel.textColor = color
    }
    
    @IBAction func onActionBtnClick(_ sender: Any) {
        sendAllCallback?()
    }
}

extension EXOTCTradeTextField : ExTextFieldProtocol {
    
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

extension EXOTCTradeTextField : EXTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.baseLine
    }
}
