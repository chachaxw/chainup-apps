//
//  EXPasteField.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPasteField: EXBaseField {
    
    @IBOutlet var topHeight: NSLayoutConstraint!
    @IBOutlet var input: UITextField!
    @IBOutlet var baseLine: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var pasteBtn: CMLocalizedButton!
    
    var showTitle:Bool = false {
        didSet {
            self.titleMode(enabled: showTitle)
        }
    }
    
    let style = EXTextFieldStyle.commonStyle
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    func titleMode(enabled:Bool) {
        topHeight.constant = enabled ? 22 : 0
    }
    
    override func onCreate() {
        super.onCreate()
        self.showTitle = false
        style.bindHighlight(textField: input, effectView: baseLine)
        self.presenter.configWithTextField(input: input)
        pasteBtn.setTitle("common_action_paste".localized(), for: .normal)
        titleLabel.font = UIFont.ThemeFont.BodyBold
        pasteBtn.titleLabel?.font = UIFont.ThemeFont.BodyBold
        pasteBtn.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        pasteBtn.setTitleColor(UIColor.ThemeView.highlight, for: .selected)
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

    @IBAction func pasteAction(_ sender: Any) {
        if let gStr = UIPasteboard.general.string {
            input.text = gStr
            input.sendActions(for: .valueChanged)
        }
    }
}

extension EXPasteField : ExTextFieldProtocol {
    
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

extension EXPasteField : EXTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.baseLine
    }
}
