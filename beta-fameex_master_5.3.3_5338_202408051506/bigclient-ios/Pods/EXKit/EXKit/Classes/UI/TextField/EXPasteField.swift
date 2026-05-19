//
//  EXPasteField.swift
//  Chainup
//
//  Created by liuxuan on2020/3/18.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit

public class EXPasteField: EXBaseField {
    @IBOutlet public var topHeight: NSLayoutConstraint!
    @IBOutlet public var input: UITextField!
    @IBOutlet public var baseLine: UIView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var pasteBtn: CMLocalizedButton!
    
    public var showTitle:Bool = false {
        didSet {
            self.titleMode(enabled: showTitle)
        }
    }
    
    public let style = EXTextFieldStyle.commonStyle
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    public func titleMode(enabled:Bool) {
        topHeight.constant = enabled ? 22 : 0
    }
    
    public override func onCreate() {
        super.onCreate()
        titleLabel.secondaryRegular()
        self.showTitle = false
        style.bindHighlight(textField: input, effectView: baseLine)
        self.presenter.configWithTextField(input: input)
        pasteBtn.setTitle("common_action_paste".localized(), for: .normal)
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
    
    public func changeToCopyStyle() {
        self.pasteBtn.removeTarget(self, action: #selector(pasteAction(_:)), for: .touchUpInside)
        self.pasteBtn.setTitle("", for: .normal)
        self.pasteBtn.setImage(UIImage.themeImageNamedFromPod(imageName: "fiat_copy"), for: .normal)
        self.pasteBtn.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
    }
    
    @objc public func copyAction() {
        if let copystr = input.text {
            UIPasteboard.general.string = copystr
            EXKitAlert.showSuccess(msg: "common_tip_copySuccess".localized())
        }
    }

    @IBAction public func pasteAction(_ sender: Any) {
        if let gStr = UIPasteboard.general.string {
            input.text = gStr
            input.sendActions(for: .valueChanged)
        }
    }
}

extension EXPasteField : EXTextFieldPresenterProtocol {
    
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

extension EXPasteField : EXTextFieldConfigurable {
    
    public var baseField: UITextField {
        return self.input
    }
    
    public var baseHighlight: UIView {
        return self.baseLine
    }
}
