//
//  EXSelectionField.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/11.
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

class EXSelectionField: EXBaseField {
    typealias TxtFieldDidTappedBlock = () -> ()
    var textfieldDidTapBlock : TxtFieldDidTappedBlock?

    var triangleWidth :CGFloat = 10
    var triangleHeight :CGFloat = 5
    var isChecked :Bool = false
    private let topMargin:CGFloat = 22

    let disposebg = DisposeBag()
    @IBOutlet var input: UITextField!
    @IBOutlet var baseLine: UIView!
    @IBOutlet var triangle: EXSelectionTriangleView!
    @IBOutlet var arrowIcon: UIImageView!
    @IBOutlet var middleView: UIView!
    
    let style = EXTextFieldStyle.commonStyle
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var topMarginConstaint: NSLayoutConstraint!
    
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
    
    func arrowModel(enabled:Bool) {
        arrowIcon.isHidden = !enabled
        triangle.isHidden = enabled
    }
    
    override func onCreate() {
        super.onCreate()
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        titleLabel.font = UIFont.ThemeFont.BodyRegular
        self.titleMode(enabled: false)
        style.bindHighlight(textField: input, effectView: baseLine)
        input.delegate = self
        input.isUserInteractionEnabled = false
        input.font = UIFont.ThemeFont.BodyRegular
        self.arrowModel(enabled: false)
        arrowIcon.image = UIImage.themeImageNamed(imageName: "transaction_enter")
        middleView.backgroundColor = UIColor.ThemeView.bg
        baseLine.backgroundColor =  UIColor.ThemeView.seperator
        let tapGesture = UITapGestureRecognizer.init()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(tapped))
        self.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(normalStyle), name:  NSNotification.Name.init("EXSheetDissmissed"), object: nil)
        triangle.snp_remakeConstraints { make in
            make.right.equalToSuperview().offset(5)
            make.height.width.equalTo(16)
            make.centerY.equalToSuperview()
        }
        triangle.icon.snp_remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setText(text: String) {
        input.text = text
        input.sendActions(for: .valueChanged)
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
        self.triangle.checked(check: true)
    }
    
    @objc func normalStyle() {
        baseLine.backgroundColor = UIColor.ThemeTextField.seperator
        self.triangle.checked(check: false)
    }
    
    
}

extension EXSelectionField {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

extension EXSelectionField :ExTextFieldProtocol {
    
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

extension EXSelectionField : EXRefreshProtocal {
    
    func refreshProtocalTrigger() {
        self.normalStyle()
    }
}

extension EXSelectionField : EXTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.baseLine
    }
}
