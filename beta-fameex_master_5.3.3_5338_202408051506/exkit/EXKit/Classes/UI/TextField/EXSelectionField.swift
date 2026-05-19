//
//  EXSelectionField.swift
//  Chainup
//
//  Created by liuxuan on2020/3/11.
//  Copyright ©2020 zewu wang. All rights reserved.
//

/*
 self.textfieldValueChangeBlock?(value)
 self.textfieldDidBeginBlock?()
 self.textfieldDidEndBlock?()
 */

import UIKit
import RxSwift

public class EXSelectionField: EXBaseField {
    public typealias TxtFieldDidTappedBlock = () -> ()
    public var textfieldDidTapBlock : TxtFieldDidTappedBlock?

    public var triangleWidth :CGFloat = 10
    public var triangleHeight :CGFloat = 5
    public var isChecked :Bool = false
    private let topMargin:CGFloat = 22

    public let disposebg = DisposeBag()
    @IBOutlet public var input: UITextField!
    @IBOutlet public var baseLine: UIView!
    @IBOutlet public var triangle: EXSelectionTriangleView!
    @IBOutlet public var arrowIcon: UIImageView!
    @IBOutlet public var middleView: UIView!
    
    public let style = EXTextFieldStyle.commonStyle
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var topMarginConstaint: NSLayoutConstraint!
    
    public var needHighlight:Bool = true
    
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
    
    public func arrowModel(enabled:Bool) {
        arrowIcon.isHidden = !enabled
        triangle.isHidden = enabled
    }
    
    public func emptyRightView(enabled:Bool) {
        arrowIcon.isHidden = enabled
        triangle.isHidden = enabled
    }
    
    public override func onCreate() {
        super.onCreate()
        self.titleMode(enabled: false)
        style.bindHighlight(textField: input, effectView: baseLine)
        input.font = UIFont.ThemeFont.BodyMedium
        input.delegate = self
        input.isUserInteractionEnabled = false
        self.arrowModel(enabled: false)
        arrowIcon.image = UIImage.themeImageNamedFromPod(imageName: "public_positions_arrow_right")
        middleView.backgroundColor = UIColor.ThemeView.bg
        let tapGesture = UITapGestureRecognizer.init()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(tapped))
        self.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(normalStyle), name:  NSNotification.Name.init("EXSheetDissmissed"), object: nil)
    }
    
    public override func setText(text: String) {
        input.text = text
        input.sendActions(for: .valueChanged)
    }
    
    public override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    public override func setTitle(title: String) {
        titleLabel.text = title 
    }
    
    @objc private func tapped(){
        if needHighlight {
            self.highlightStyle()
        }
        self.textfieldDidTapBlock?()
    }
    
    public func highlightStyle() {
        baseLine.backgroundColor = UIColor.ThemeView.highlight
        self.triangle.checked(check: true)
    }
    
    @objc public func normalStyle() {
        baseLine.backgroundColor = UIColor.ThemeTextField.seperator
        self.triangle.checked(check: false)
    }
    
    
}

extension EXSelectionField {
    public override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

extension EXSelectionField :EXTextFieldPresenterProtocol {
    
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

extension EXSelectionField : EXRefreshProtocal {
    
    public func refreshProtocalTrigger() {
        self.normalStyle()
    }
}

extension EXSelectionField : EXTextFieldConfigurable {
    
    public var baseField: UITextField {
        return self.input
    }
    
    public var baseHighlight: UIView {
        return self.baseLine
    }
}

extension EXSelectionField: EXTextFieldProtocol {
    public var textField: UITextField { input }
}
