//
//  EXAccountInfoInputView.swift
//  Chainup
//
//  Created by wangdong on 2023/9/17.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

class EXAccountInfoInputView: NibBaseView {
    
    var leftPartClick: EXComVoidBlock?
    var security = false {
        didSet {
            if self.security {
                self.inputTextField.isSecureTextEntry = true
                self.eyebutton.isHidden = false
            }
        }
    }
    
    var placeholder: String = "" {
        didSet {
            let placeHolderAtt = NSMutableAttributedString().add(string: self.placeholder, attrDic: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium) , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorDark ])
            self.inputTextField.attributedPlaceholder = placeHolderAtt
        }
    }
    
    var showLeftSecticon: Bool = false {
        didSet{
            self.leftSelectView.isHidden =  !showLeftSecticon
//            self.leftSelectView.setCustomSpacing(12, after: self.codeLabel)
        }
        
        
    }
    @IBOutlet weak var leftSelectView: UIStackView!
    
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    var inputMaxLength = Int.max
    @IBOutlet weak var codeLabel: UILabel!
    
    @IBOutlet var bg: UIView!
    @IBOutlet weak var bg1: UIView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var eyebutton: UIButton!
    @IBOutlet weak var hintLine: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    
    func set(value: String) {
        self.inputTextField.text = value
        self.inputTextField.sendActions(for: .editingChanged)
    }
    
    var text: String {
        return self.inputTextField.text ?? ""
    }
    
    var textSignal: Observable<String>?
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            self.inputTextField.keyboardType = self.keyboardType
        }
    }
    
    var showClearButton = false
    var showActionButton = false
    
    override func onCreate() {
        backgroundColor = .clear
        nibView.backgroundColor = .clear
        actionButton.setTitleColor(UIColor.ThemeBtn.highlight, for: .normal)
        actionButton.setTitleColor(UIColor.ThemeBtn.disable, for: .disabled)
        self.clearButton.setImage(UIImage.themeImageNamed(imageName: "public_deleteall"), for: .normal)
        inputTextField.delegate = self
        
        self.countryLabel.textColor = UIColor.ThemeLabel.colorLite
        self.codeLabel.textColor = UIColor.ThemeLabel.colorLite
        self.countryLabel.font =  UIFont.ThemeFont.HeadRegular
        self.codeLabel.font = UIFont.ThemeFont.HeadRegular
        self.inputTextField.textColor =  UIColor.ThemeLabel.colorLite
        self.inputTextField.font =  UIFont.ThemeFont.HeadRegular
        arrowImageView.image = UIImage.themeImageNamed(imageName: "coins_drop_down")
        
        textSignal = inputTextField.rx.text.orEmpty.asObservable()
        
        textSignal?.subscribe(onNext: { [weak self] text in
            guard let self = `self` else { return }
            self.clearButton.isHidden = !self.inputTextField.isFirstResponder || !(self.showClearButton && text.count > 0)
        }).disposed(by: self.disposeBag)
        
        clearButton.isHidden = true
        eyebutton.isHidden = true
        actionButton.isHidden = true
        
        clearButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.inputTextField.text = nil
            self?.inputTextField.sendActions(for: .editingChanged)
        }).disposed(by: self.disposeBag)
        self.eyebutton.setImage(UIImage.themeImageNamed(imageName: "login_eyeoff"), for: .normal)
        self.eyebutton.setImage(UIImage.themeImageNamed(imageName: "login_eyeon"), for: .selected)
        eyebutton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = `self` else { return }
            self.inputTextField.isSecureTextEntry = !self.inputTextField.isSecureTextEntry
            if self.inputTextField.isSecureTextEntry {
                self.eyebutton.isSelected = false //setImage(UIImage.themeImageNamed(imageName: "login_eyeon"), for: .normal)
            }
            else {
                self.eyebutton.isSelected = true
//                self.eyebutton.setImage(UIImage.themeImageNamed(imageName: "login_eyeoff"), for: .normal)
            }
        }).disposed(by: self.disposeBag)
        
        self.showLeftSecticon = false
      
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        self.leftSelectView.isUserInteractionEnabled = true
        self.leftSelectView.addGestureRecognizer(tap)
        
        
    }
    @objc func click(){
        leftPartClick?()
    }
 
    func becomeFocus() {
        inputTextField.becomeFirstResponder()
    }
    
    func resionFocus() {
        inputTextField.resignFirstResponder()
    }
    
    func error() {
        hintLine.backgroundColor = UIColor.red
    }
}

extension EXAccountInfoInputView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        hintLine.backgroundColor = UIColor.ThemeView.highlight
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        hintLine.backgroundColor = UIColor.ThemeTextField.seperator
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < inputMaxLength
    }
}
