//
//  EXIconSelectionField.swift
//  Chainup
//
//  Created by liuxuan on 2019/4/11.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

public class EXIconSelectionField: EXBaseField {
    public typealias TxtFieldDidTappedBlock = () -> ()
    public var textfieldDidTapBlock : TxtFieldDidTappedBlock?
    private let topMargin:CGFloat = 22
    public let disposebg = DisposeBag()
    @IBOutlet public var input: UITextField!
    @IBOutlet public var baseLine: UIView!
    public let style = EXTextFieldStyle.commonStyle
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var topMarginConstaint: NSLayoutConstraint!
    
    @IBOutlet public var iconBtn: UIButton!
    @IBOutlet public var jumpBtn: EXButton!
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    public var enableTitleModel:Bool = false {
        didSet {
            self.titleMode(enabled: enableTitleModel)
        }
    }
    
    
    public func titleMode(enabled:Bool) {
        topMarginConstaint.constant = enabled ? topMargin : 0
    }
    
    public override func onCreate() {
        super.onCreate()
        jumpBtn.isHidden = true
        jumpBtn.titleLabel?.font = UIFont.ThemeFont.SecondaryMedium
        jumpBtn.selectStyle = .blueTextColor
        self.titleMode(enabled: false)
        style.bindHighlight(textField: input, effectView: baseLine)
        input.delegate = self
        input.isUserInteractionEnabled = false
        
        let tapGesture = UITapGestureRecognizer.init()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(tapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    public override func setText(text: String) {
        input.text = text
    }
    
    public override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    public override func setTitle(title: String) {
        titleLabel.text = title
    }
    
    @objc private func tapped(){
        self.highlightStyle()
        self.textfieldDidTapBlock?()
    }
    
    public func highlightStyle() {
        baseLine.backgroundColor = UIColor.ThemeView.highlight
        
    }
    
    public func normalStyle() {
        baseLine.backgroundColor = UIColor.ThemeTextField.seperator
        
    }
}


extension EXIconSelectionField {
    public override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

extension EXIconSelectionField :EXTextFieldPresenterProtocol {
    
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

extension EXIconSelectionField : EXTextFieldConfigurable {
    
    public var baseField: UITextField {
        return self.input
    }
    
    public var baseHighlight: UIView {
        return self.baseLine
    }
}
