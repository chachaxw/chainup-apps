//
//  EXOTCTradeTextField.swift
//  Chainup
//
//  Created by liuxuan on2020/3/28.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit

public class EXOTCTradeTextField: EXBaseField {
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var actionBtn: CMLocalizedButton!
    @IBOutlet public var input: UITextField!
    @IBOutlet public var bottomLeftLabel: UILabel!
    @IBOutlet public var bottomRightLabel: UILabel!
    @IBOutlet public var baseLine: UIView!
    public let style = EXTextFieldStyle.commonStyle
    public typealias ActionAllBlock = ()->()
    public var sendAllCallback:ActionAllBlock?
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()

    public override func onCreate() {
        super.onCreate()
        style.bindHighlight(textField: input, effectView: baseLine)
        self.presenter.configWithTextField(input: input)
    }
    
    public override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    public override func setText(text: String) {
        input.text = text
    }
    
    public override func setTitle(title: String) {
        titleLabel.text = title
    }

    public func setBottomLeftText(value:String) {
        bottomLeftLabel.text = value
    }
    
    public func setBottomRightText(value:String) {
        bottomRightLabel.text = value
    }
    
    public func setBottomRightTextColor(_ color:UIColor) {
        bottomRightLabel.textColor = color
    }
    
    @IBAction public func onActionBtnClick(_ sender: Any) {
        sendAllCallback?()
    }
}

extension EXOTCTradeTextField : EXTextFieldPresenterProtocol {
    
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

extension EXOTCTradeTextField : EXTextFieldConfigurable {
    
    public var baseField: UITextField {
        return self.input
    }
    
    public var baseHighlight: UIView {
        return self.baseLine
    }
}
