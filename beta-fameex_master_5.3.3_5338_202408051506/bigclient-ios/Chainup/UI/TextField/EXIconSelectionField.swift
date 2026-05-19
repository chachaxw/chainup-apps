//
//  EXIconSelectionField.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

class EXIconSelectionField: EXBaseField {
    typealias TxtFieldDidTappedBlock = () -> ()
    var textfieldDidTapBlock : TxtFieldDidTappedBlock?
    private let topMargin:CGFloat = 22
    let disposebg = DisposeBag()
    @IBOutlet var input: UITextField!
    @IBOutlet var baseLine: UIView!
    let style = EXTextFieldStyle.commonStyle
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var topMarginConstaint: NSLayoutConstraint!
    
    @IBOutlet var iconBtn: UIButton!
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    var enableTitleModel:Bool = false {
        didSet {
            self.titleMode(enabled: enableTitleModel)
        }
    }
    
    
    func titleMode(enabled:Bool) {
        topMarginConstaint.constant = enabled ? topMargin : 0
    }
    
    override func onCreate() {
        super.onCreate()
        self.titleMode(enabled: false)
        style.bindHighlight(textField: input, effectView: baseLine)
        input.delegate = self
        input.isUserInteractionEnabled = false
        
        let tapGesture = UITapGestureRecognizer.init()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(tapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    override func setText(text: String) {
        input.text = text
    }
    
    override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    override func setTitle(title: String) {
        titleLabel.text = title
    }
    
    @objc private func tapped(){
        self.highlightStyle()
        self.textfieldDidTapBlock?()
    }
    
    func highlightStyle() {
        baseLine.backgroundColor = UIColor.ThemeView.highlight
        
    }
    
    func normalStyle() {
        baseLine.backgroundColor = UIColor.ThemeTextField.seperator
        
    }
}


extension EXIconSelectionField {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

extension EXIconSelectionField :ExTextFieldProtocol {
    
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

extension EXIconSelectionField : EXTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.baseLine
    }
}
