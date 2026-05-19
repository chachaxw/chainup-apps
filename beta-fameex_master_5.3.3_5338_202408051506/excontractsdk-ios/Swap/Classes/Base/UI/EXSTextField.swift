//
//  EXTextField.swift
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

import UIKit
import RxSwift
import EXKit
//enablePrivacyModel 控制展示隐私按钮，默认不展示 English: EnablePrivacyModel controls the display of privacy buttons, which are not displayed by default
//enableTitleModel 控制展示title，默认不展示 English: EnableTitleModel controls the display of the title, which is not displayed by default

class EXSTextField: EXSBaseField {
    
    private let rightMargin:CGFloat = 25
    private let topMargin:CGFloat = 22
    private let bottomMargin:CGFloat = 24
    
    
    @IBOutlet var input: UITextField!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var baseLine: UIView!
    @IBOutlet var inputRightMargin: NSLayoutConstraint!
    @IBOutlet var topMarginConsaint: NSLayoutConstraint!
    @IBOutlet var privacyBtn: UIButton!
    @IBOutlet var extraLabel: UILabel!
    
    let style = EXSTextFieldStyle.commonStyle
    
    let disposebg = DisposeBag()

    var enablePrivacyModel:Bool = false {
        didSet {
            self.privacyMode(enabled: enablePrivacyModel)
            privacyBtn.sendActions(for: .touchUpInside)
        }
    }
    
    var enableTitleModel:Bool = false {
        didSet {
            self.titleMode(enabled: enableTitleModel)
        }
    }
    
    fileprivate lazy var presenter : EXSTextFieldPresenter = {
        return EXSTextFieldPresenter.init(presenter: self)
    }()
    
    override func onCreate() {
        super.onCreate()
        titleLabel.secondaryRegular()
        self.backgroundColor = UIColor.ThemeView.bg
        input.backgroundColor = UIColor.ThemeView.bg
        input.textColor = UIColor.ThemeLabel.colorLite
        self.titleMode(enabled: false)
        self.privacyMode(enabled: false)
        extraLabel.font = UIFont.ThemeFont.SecondaryRegular
        extraLabel.textColor = UIColor.ThemeLabel.colorMedium
        
        privacyBtn.setImage(UIImage.exs_themeImageNamed(imageName: "visible"), for: .normal)
        privacyBtn.setImage(UIImage.exs_themeImageNamed(imageName: "hide"), for: .selected)

        style.bindHighlight(textField: input, effectView: baseLine)
        input.setModifyClearButton()
        self.presenter.configWithTextField(input: input)
    }
    
    func privacyMode(enabled:Bool) {
        inputRightMargin.constant = enabled ? rightMargin : 0
    }

    func titleMode(enabled:Bool) {
        topMarginConsaint.constant = enabled ? topMargin : 0
    }
    
    override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.exs_setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }

    override func setText(text: String) {
        input.text = text
        input.sendActions(for: .valueChanged)
    }
    
    override func setTitle(title: String) {
        titleLabel.text = title 
    }
    
    func setExtraText(_ text:String) {
        extraLabel.text = text
    }
    
    @IBAction func privacyDidTap(_ sender: UIButton) {
        if self.enablePrivacyModel == false {
            return
        }
        if(sender.isSelected == true) {
            input.isSecureTextEntry = false
        } else {
            input.isSecureTextEntry = true
        }
        sender.isSelected = !sender.isSelected
    }
}

extension EXSTextField : EXSTextFieldProtocol {
    
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

extension EXSTextField : EXSTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.baseLine
    }
}

