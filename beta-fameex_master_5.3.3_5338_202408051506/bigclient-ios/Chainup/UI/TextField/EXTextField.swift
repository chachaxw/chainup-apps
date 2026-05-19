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

//EnablePrivacyModel controls the display privacy button, which is not displayed by default
//EnableTitleModel controls the display of the title, which is not displayed by default

class EXTextField: EXBaseField {
    
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
    let style = EXTextFieldStyle.commonStyle
    
    let disposebg = DisposeBag()

    var enablePrivacyModel:Bool = false {
        didSet {
            self.privacyMode(enabled: enablePrivacyModel)
//            privacyBtn.sendActions(for: .touchUpInside)
            privacyBtn.isSelected = !enablePrivacyModel
            if enablePrivacyModel{
                input.isSecureTextEntry = true
            }
        }
    }
    
    var enableTitleModel:Bool = false {
        didSet {
            self.titleMode(enabled: enableTitleModel)
        }
    }
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    override class func awakeFromNib() {
        
    }
   
    override func onCreate() {
        super.onCreate()
        titleLabel.secondaryRegular()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont.ThemeFont.BodyRegular
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        self.backgroundColor = UIColor.ThemeView.bg
        input.backgroundColor = UIColor.ThemeView.bg
        self.titleMode(enabled: false)
        self.privacyMode(enabled: false)
        extraLabel.backgroundColor = .clear
        extraLabel.font = UIFont.ThemeFont.SecondaryRegular
        extraLabel.textColor = UIColor.ThemeLabel.colorMedium
        privacyBtn.setImage(UIImage.themeImageNamed(imageName: "login_eyeoff"), for: .normal)//visible
        privacyBtn.setImage(UIImage.themeImageNamed(imageName: "login_eyeon"), for: .selected)//hide
        baseLine.backgroundColor = UIColor.ThemeView.seperator
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
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
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
    
    func showBottomlineErrorRed(){
        baseLine.backgroundColor = UIColor.red
    }
    
    @IBAction func privacyDidTap(_ sender: UIButton) {
        if self.enablePrivacyModel == false {
            return
        }
        sender.isSelected = !sender.isSelected
        if(sender.isSelected == true) {
            input.isSecureTextEntry = false
        } else {
            input.isSecureTextEntry = true
        }
    }
}

extension EXTextField : ExTextFieldProtocol {
    
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

extension EXTextField : EXTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.baseLine
    }
}

