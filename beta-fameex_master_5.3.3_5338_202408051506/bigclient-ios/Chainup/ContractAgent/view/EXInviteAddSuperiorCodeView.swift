//
//  EXInviteAddSuperiorCodeView.swift
//  Chainup
//
//  Created by bradjohn on 2024/3/18.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXInviteAddSuperiorCodeView: UIView {
    
    var confirmBlock: ((_ string: String) -> ())?
    
    var contentInset: UIEdgeInsets = .init(top: 16, left: 16, bottom: 8, right: 16) {
        didSet {
            guard contentView.superview != nil else { return }
            contentView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInset) }
        }
    }
    
    lazy var titleLabel: UILabel = {
        let v = UILabel(text: "add_invite_code".localized(),font: .Ex.medium(16), textColor: .Ex.text1)
        return v
    }()
    
    lazy var cancelButton: EXButton = {
        let v = EXButton(type: .custom)
        v.selectStyle = .blueTextColor
        v.setTitle("common_text_btnCancel".localized(), for: .normal)
        v.setTitleColor(.Ex.text2, for: .normal)
        v.setEnlargeEdgeWithTop(6, left: 6, bottom: 6, right: 6)
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        v.rx.controlEvent(.touchUpInside).subscribe(onNext: { EXAlert.dismiss() }).disposed(by: disposeBag)
        return v
    }()
    
    lazy var codeTextField: EXBasicTextField = {
        let v = EXBasicTextField()
        v.highlightColor = .Ex.main1
        v.placeholder = "referral_superior_pop_text".localized()
        v.maxLength = 10
        return v
    }()
    
    lazy var confirmButton: EXButton = {
        let v = EXButton(type: .custom)
        v.selectStyle = .blueColor
        v.setTitle("confirm".localized(), for: .normal)
        return v
    }()
    
    lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
        onBindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        backgroundColor = .Ex.fill6
        addSubViews([contentView])
        contentView.snp.makeConstraints{ $0.edges.equalToSuperview().inset(contentInset) }
        contentView.addSubViews([titleLabel, cancelButton, codeTextField, confirmButton])
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        cancelButton.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(4)
            make.right.equalToSuperview()
            make.centerY.height.equalTo(titleLabel)
        }
        
        ///
        codeTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(codeTextField.snp.bottom).offset(28)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    func onBindViewModel() {
        
        codeTextField.textField.rx.text.orEmpty
            .map { $0.filter { !$0.isChinese && $0.isAlphanumeric } }
            .bind(to: codeTextField.textField.rx.text)
            .disposed(by: disposeBag)
        
        codeTextField.textField.rx.text.orEmpty
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        confirmButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            guard let self else { return }
            guard let text = self.codeTextField.text else { return }
            self.confirmBlock?(text)
        }).disposed(by: disposeBag)
        
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).take(until: self.rx.deallocated).subscribe(onNext: {[weak self] notifition in
            guard let self else { return }
            if let userInfo = notifition.userInfo, let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
                self.updateBttomDistanceIfNeed(true, duration)
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).take(until: self.rx.deallocated).subscribe(onNext: {[weak self] notifition in
            guard let self else { return }
            if let userInfo = notifition.userInfo, let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
                self.updateBttomDistanceIfNeed(false, duration)
            }
        }).disposed(by: disposeBag)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
    
    func activeFirstResponder() {
        codeTextField.textField.becomeFirstResponder()
        codeTextField.highlightableUpdater = .default
    }
    
    
    private func updateBttomDistanceIfNeed(_ isKeyboardShow: Bool = false, _ duration: TimeInterval = 0.25) {
        if isKeyboardShow {
            contentInset.bottom = 8
        } else {
            contentInset.bottom = EXSafeAreaBottom + 8
        }
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
     }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
