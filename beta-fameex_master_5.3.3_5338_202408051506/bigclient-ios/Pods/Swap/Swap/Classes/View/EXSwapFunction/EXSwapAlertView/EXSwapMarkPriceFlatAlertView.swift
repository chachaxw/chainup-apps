//
//  EXSwapMarkPriceFlatAlertView.swift
//  Chainup
//
//  Created by ZYJ on 2023/12/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSwapMarkPriceFlatAlertView: UIView {
    
    var confirmCallback: (() -> ())?
    
    var isShowConfirmView = false {
        didSet {
            self.confirmView.isHidden = !self.isShowConfirmView
            if self.isShowConfirmView {
                self.confirmButton.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.confirmView.snp.bottom).offset(26)
                    make.right.equalTo(self.confirmView)
                    make.height.equalTo(20)
                    make.bottom.equalTo(-16)
                }
            } else {
                self.confirmButton.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.messageLabel.snp.bottom).offset(26)
                    make.right.equalTo(self.confirmView)
                    make.height.equalTo(20)
                    make.bottom.equalTo(-16)
                }
            }
        }
    }

    private lazy var titleLabel: UILabel = UILabel(text: "cp_order_text46".ex_localized(), font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
    private lazy var tipsLabel: UILabel = UILabel(text: "", font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.red, alignment: .left)
    private lazy var messageLabel: UILabel = UILabel(text: nil, font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
    private lazy var confirmView: EXSwapAlertConfirmView = {
        let view = EXSwapAlertConfirmView()
        view.backgroundColor = UIColor.ThemeView.bgTab
        return view
    }()
    private lazy var cancelButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_overview_text56".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: UIColor.ThemeLabel.colorMedium)
        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
    private lazy var confirmButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_calculator_text16".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: UIColor.ThemeBtn.highlight)
        button.ext_SetAddTarget(self, #selector(clickConfirmButton))
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 1.5
        self.backgroundColor = UIColor.ThemeView.bg
        self.messageLabel.numberOfLines = 0
        self.exs_addSubViews([titleLabel, tipsLabel,messageLabel, confirmView, cancelButton, confirmButton])
        
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initLayout() {
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(18)
        }
        self.tipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.right.equalTo(-20)
        }
        self.messageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLabel)
            make.right.equalTo(-20)
            make.top.equalTo(self.tipsLabel.snp.bottom).offset(10)
        }
        self.confirmView.snp.makeConstraints { (make) in
            make.top.equalTo(self.messageLabel.snp.bottom).offset(15)
            make.left.equalTo(self.messageLabel)
            make.right.equalTo(self.messageLabel)
            make.height.equalTo(36)
        }
        self.confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.messageLabel.snp.bottom).offset(26)
            make.right.equalTo(self.confirmView)
            make.height.equalTo(20)
            make.bottom.equalTo(-16)
        }
        self.cancelButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.confirmButton)
            make.right.equalTo(self.confirmButton.snp.left).offset(-30)
        }
    }
    
    
    // MARK: - Update
    
    func config(title: String, message: String, cancelText: String = "cp_overview_text56".ex_localized(), confirmText: String = "cp_calculator_text16".ex_localized(),tipsText : String) {
        self.titleLabel.text = title
        self.messageLabel.text = message
        self.cancelButton.setTitle(cancelText, for: .normal)
        self.confirmButton.setTitle(confirmText, for: .normal)
        if tipsText != "" {
            self.tipsLabel.text = tipsText
            self.tipsLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(20)
                make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
                make.right.equalTo(-20)
                make.height.equalTo(30)
            }
        }
    }
    
    func configAttr(title: String, message: NSMutableAttributedString, cancelText: String = "cp_overview_text56".ex_localized(), confirmText: String = "cp_calculator_text16".ex_localized(),tipsText : String) {
        self.titleLabel.text = title
        self.messageLabel.attributedText = message
        self.cancelButton.setTitle(cancelText, for: .normal)
        self.confirmButton.setTitle(confirmText, for: .normal)
        if tipsText != "" {
            self.tipsLabel.text = tipsText
            self.tipsLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(20)
                make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
                make.right.equalTo(-20)
                make.height.equalTo(30)
            }
        }
    }
    
    func updateVolume(_ volume: String, _ color: UIColor, _ type : String, _ name : String) {
        self.isShowConfirmView = true
        self.confirmView.volumeLabel.text = volume
        self.confirmView.typeLabel.textColor = color
        self.confirmView.typeLabel.text = type
        self.confirmView.nameLabel.text = name
    }
    
    
    // MARK: - Click Events
    
    @objc func clickCancelButton() {
        EXAlert.dismiss()
    }
    
    @objc func clickConfirmButton() {
        
        let strongSelf = self
        
        EXAlert.dismiss()
        strongSelf.confirmCallback?()
    }
}


class EXSwapAlertConfirmView: UIView {
    lazy var typeLabel: UILabel = UILabel(text: "-", font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemekLine.up, alignment: .left)
    lazy var nameLabel: UILabel = UILabel(text: "-", font: UIFont.ThemeFont.BodyBold, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
    lazy var volumeLeftLabel: UILabel = UILabel(text: "cp_order_text59".ex_localized(), font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .right)
    lazy var volumeLabel: UILabel = UILabel(text: "-", font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: .center)
    lazy var volumeRightLabel: UILabel = UILabel(text: "cp_overview_text9".ex_localized(), font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .right)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.exs_addSubViews([typeLabel, nameLabel, volumeLeftLabel, volumeLabel, volumeRightLabel])
        
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        self.typeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
        }
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.typeLabel.snp.right).offset(6)
            make.centerY.equalToSuperview()
        }
        self.volumeRightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
        }
        self.volumeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.volumeRightLabel.snp.left).offset(-4)
        }
        self.volumeLeftLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.volumeLabel.snp.left).offset(-4)
        }
    }
}
