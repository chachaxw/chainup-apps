//
//  EXSecurityAuthAlertView.swift
//  Chainup
//
//  Created by wangdong on 2023/9/21.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftEntryKit
import EXKit
class EXSecurityAuthAlertView: NibBaseView {
    
    var codeInputAction: (() -> ())?

    @IBOutlet weak var codeInputView: EXAccountInfoInputView!
    @IBOutlet weak var googleCodeInputView: EXAccountInfoInputView!
    @IBOutlet weak var certifcateCodeInputView: EXAccountInfoInputView!
    @IBOutlet weak var submitButton: EXButton!
    @IBOutlet weak var googleCodeView: UIView!
    @IBOutlet weak var certifcateCodeView: UIView!
    @IBOutlet weak var codeInputTitleLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    
    var codeInputViewPlaceholder: String? {
        didSet {
            self.codeInputView.placeholder = codeInputViewPlaceholder ?? ""
        }
    }
    var needInputGoogleCode = false {
        didSet {
            self.googleCodeView.isHidden = !self.needInputGoogleCode
        }
    }
    
    var needInputCertifcateCode = false {
        didSet {
            self.certifcateCodeView.isHidden = !self.needInputCertifcateCode
        }
    }
    
    var codeInputViewTitle: String? {
        didSet {
            self.codeInputTitleLabel.text = self.codeInputViewTitle
        }
    }
    
    var didSubmit: ((_ code: String?, _ googleCode: String?, _ certifcateCode: String?) -> ())?
    
    
    override func onCreate() {
        backgroundColor = .Ex.fill6
        nibView.backgroundColor = .clear
        submitButton.isEnabled = false
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .disabled)
        submitButton.setTitle("common_text_btnConfirm".localized(), for: .normal)
        
        codeInputView.actionButton.isHidden = false
        
        codeInputView.actionButton.setTitle("", for: .normal)
        codeInputView.keyboardType = .numberPad
        
        resetSendCodeControl()
        
        googleCodeInputView.actionButton.isHidden = false
        googleCodeInputView.actionButton.setTitle("common_action_paste".localized(), for: .normal)
        googleCodeInputView.placeholder = "common_tip_googleAuth".localized()
        googleCodeInputView.keyboardType = .numberPad
        
        certifcateCodeInputView.placeholder = "personal_tip_inputIdnumber".localized()
        
        guard let codeSignal = codeInputView.textSignal,
            let googleCodeSignal = googleCodeInputView.textSignal,
            let certifcateCodeSignal = certifcateCodeInputView.textSignal else { return }
                
        let combine = Observable.combineLatest(codeSignal, googleCodeSignal, certifcateCodeSignal)
        
        _ = combine.map { [weak self] tuple -> Bool in
            let (code, google, certifacate) = tuple
            guard let self = `self` else { return false }

            if self.needInputGoogleCode && self.needInputCertifcateCode {
                return code.count > 0 && google.count > 0 && certifacate.count > 0
            }
            else if self.needInputGoogleCode {
                return code.count > 0 && google.count > 0
            }
            else if self.needInputCertifcateCode {
                return code.count > 0 && certifacate.count > 0
            }
            else {
                return code.count > 0
            }
            
        }.subscribe(onNext: { [weak self] isEnabled in
            guard let self = `self` else { return }
            self.submitButton.isEnabled = isEnabled
        })
        
        submitButton.rx.tap.withLatestFrom(combine).subscribe(onNext: { [weak self] tuple in
            guard let self = `self` else { return }
            let (code, googleCode, certifcateCode) = tuple
            self.didSubmit?(code, googleCode, certifcateCode)
        }).disposed(by: self.disposeBag)
        
        codeInputView.actionButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = `self` else { return }
            self.resetSendCodeControl()
            self.codeInputAction?()
        }).disposed(by: self.disposeBag)
        
        googleCodeInputView.actionButton.rx.tap.subscribe(onNext: { [weak self] tuple in
            guard let self = `self` else { return }
            self.googleCodeInputView.set(value: UIPasteboard.general.string ?? "")
        }).disposed(by: self.disposeBag)
    }

    func hide() {
        SwiftEntryKit.dismiss()
    }
    
    @IBAction func onCancelAction(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    private func resetSendCodeControl() {
        let seconds = Observable.generate(
            initialState: 89,
            condition: { $0 >= 0},
            iterate: { $0 - 1 }
        )
        
        let timer = Driver<Int>.interval(.seconds(1))
        
        Observable.zip(seconds, timer.asObservable()).map({ (seconds, timer) in
            return seconds
        }).subscribe(onNext: { [weak self] seconds in
            guard let self = `self` else { return }
            if seconds == 0 {
                self.codeInputView.actionButton.isEnabled = true
                self.codeInputView.actionButton.setTitle("login_action_resendCode".localized(), for: .normal)
            }
            else {
                self.codeInputView.actionButton.isEnabled = false
                self.codeInputView.actionButton.setTitle(String(seconds) + "(s)" + "login_action_resendCode".localized(), for: .disabled)
            }
            
        }).disposed(by: self.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bezierPath = UIBezierPath(roundedRect: self.bounds,
                                      byRoundingCorners: [.topLeft, .topRight],
                                      cornerRadii: CGSize(width: 14, height: 0.0))
        let mask = CAShapeLayer.init()
        mask.path = bezierPath.cgPath
        layer.mask = mask
    }
}

extension EXSecurityAuthAlertView: EXAlertFollowKeyboard {
    func showKeyboard() {
        codeInputView.inputTextField.becomeFirstResponder()
    }
}

