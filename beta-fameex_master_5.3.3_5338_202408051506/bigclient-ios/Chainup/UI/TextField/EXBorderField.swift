//
//  EXBorderField.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXBorderField: EXBaseField {

    @IBOutlet var bgView: UIView!
    @IBOutlet var unitLabel: UILabel!
    @IBOutlet var input: UITextField!
    let style = EXTextFieldStyle.commonStyle
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    override func onCreate() {
        super.onCreate()
        style.showHilights(on: false, effectView: bgView, borderHighlight: true)
        style.bindHighlight(textField: input, effectView: bgView,isBorder:true)
        style.showHilights(on: false, effectView: bgView, borderHighlight: true)
        presenter.configWithTextField(input: input)
        self.presenter.configWithTextField(input: input)
    }
    
    override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    override func setText(text: String) {
        input.text = text
    }
    
    func setUnitText(text:String) {
        unitLabel.text = text
    }

}

extension EXBorderField : ExTextFieldProtocol {
    
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

extension EXBorderField : EXTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.bgView
    }
}
