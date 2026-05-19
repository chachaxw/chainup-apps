//
//  EXTextField.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/6.
//  Copyright © 2019 zewu wang. All rights reserved.
//

/*
 self.textfieldValueChangeBlock?(value)
 self.textfieldDidBeginBlock?()
 self.textfieldDidEndBlock?()
 */

import UIKit
import RxSwift

//enablePrivacyModel 控制展示隐私按钮，默认不展示
//enableTitleModel 控制展示title，默认不展示

public class EXTextField: EXBaseField {
    private let rightMargin:CGFloat = 25
    private let topMargin:CGFloat = 22
    private let bottomMargin:CGFloat = 24
    
    
    @IBOutlet public var input: UITextField!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var baseLine: UIView!
    @IBOutlet public var inputRightMargin: NSLayoutConstraint!
    @IBOutlet public var topMarginConsaint: NSLayoutConstraint!
    @IBOutlet public var privacyBtn: UIButton!
    @IBOutlet public var extraLabel: UILabel!
    
    public let style = EXTextFieldStyle.commonStyle
    
    public let disposebg = DisposeBag()

    public var enablePrivacyModel:Bool = false {
        didSet {
            self.privacyMode(enabled: enablePrivacyModel)
            privacyBtn.sendActions(for: .touchUpInside)
        }
    }
    
    public var enableTitleModel:Bool = false {
        didSet {
            self.titleMode(enabled: enableTitleModel)
        }
    }
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    public override func onCreate() {
        super.onCreate()
        titleLabel.secondaryRegular()
        titleLabel.adjustsFontSizeToFitWidth = true
        self.backgroundColor = UIColor.ThemeView.bg
        input.backgroundColor = UIColor.ThemeView.bg
        input.font = .Ex.regular(16)//主动调用,应用下鸿蒙字体,字号和xib的保持一致
        self.titleMode(enabled: false)
        self.privacyMode(enabled: false)
        extraLabel.font = UIFont.ThemeFont.SecondaryRegular
        extraLabel.textColor = UIColor.ThemeLabel.colorMedium
        
        privacyBtn.setImage(UIImage.themeImageNamedFromPod(imageName: "visible"), for: .normal)
        privacyBtn.setImage(UIImage.themeImageNamedFromPod(imageName: "hide"), for: .selected)

        style.bindHighlight(textField: input, effectView: baseLine)
        input.setModifyClearButton()
        self.presenter.configWithTextField(input: input)
    }
    
    public func privacyMode(enabled:Bool) {
        inputRightMargin.constant = enabled ? rightMargin : 0
    }

    public func titleMode(enabled:Bool) {
        topMarginConsaint.constant = enabled ? topMargin : 0
    }
    
    public override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }

    public override func setText(text: String) {
        input.text = text
        input.sendActions(for: .valueChanged)
    }
    
    public override func setTitle(title: String) {
        titleLabel.text = title
    }
    
    public func setExtraText(_ text:String) {
        extraLabel.text = text
    }
    
    @IBAction public func privacyDidTap(_ sender: UIButton) {
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

extension EXTextField : EXTextFieldPresenterProtocol {
    
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

extension EXTextField : EXTextFieldConfigurable {
    
    public var baseField: UITextField {
        return self.input
    }
    
    public var baseHighlight: UIView {
        return self.baseLine
    }
}

extension EXTextField : EXTextFieldProtocol {
    public var textField: UITextField { input }
}
