//
//  EXBorderField.swift
//  Chainup
//
//  Created by liuxuan on 2019/5/14.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

public class EXBorderField: EXBaseField,EXTextFieldProtocol {
    public var textField: UITextField { input }
    @IBOutlet public var bgView: UIView!
    @IBOutlet public var unitLabel: UILabel!
    @IBOutlet public var input: UITextField!
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    public var highlightColor:UIColor = .Ex.up1 {
        didSet {
            highlightableUpdater?.invokeWith(state: isHighlighted)
        }
    }
    public override func onCreate() {
        super.onCreate()
        bgView.backgroundColor = .Ex.special2
        input.textAlignment = .center
        input.font = .ThemeFont.BodyMedium
        input.textColor = UIColor.ThemeLabel.colorLite
        highlightableUpdater = EXViewStateUpdater(dynamicUpdater: { [weak self] isHighlighted in
            self?.layer.borderWidth = isHighlighted ? 0.5 : 0
            self?.layer.borderColor = isHighlighted ? self?.highlightColor.cgColor : nil
        })
        isHighlightable = true
        presenter.configWithTextField(input: input)
        self.presenter.configWithTextField(input: input)
    }
    
    public override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    public override func setText(text: String) {
        input.text = text
    }
    
    public func setUnitText(text:String) {
        unitLabel.text = text
    }
    
    public func setNoUnitStyle() {
        self.unitLabel.isHidden = true
        self.input.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }

}

extension EXBorderField : EXTextFieldPresenterProtocol {
    
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

extension EXBorderField : EXTextFieldConfigurable {
    
    public var baseField: UITextField {
        return self.input
    }
    
    public var baseHighlight: UIView {
        return self.bgView
    }
}
