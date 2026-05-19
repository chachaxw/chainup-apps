//
//  EXSwapCarculateAlertView.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXSwapCarculateAlertView: UIView {
    typealias AlertCallback = (Int) -> ()
    var alertCallback : AlertCallback?
    var type = 0
    
    init(frame: CGRect ,type: Int) {
        super.init(frame: frame)
        self.type = type
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.layer.cornerRadius = 4
        if type == 0 {
            exs_addSubViews([titleLabel,
                                  depositLabel,
                                  resultLabel,
                                  resultLabel2,
                                  depositNumber,
                                  resultNum1,
                                  resultNum2,
                                  confirm,
                                  unit1])
            titleLabel.snp.makeConstraints { (make) in
                make.height.equalTo(22)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.top.equalToSuperview().offset(18)
            }
            depositLabel.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.left.equalToSuperview().offset(20)
                make.top.equalTo(titleLabel.snp.bottom).offset(15)
            }
            
            resultLabel.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.left.equalToSuperview().offset(20)
                make.top.equalTo(depositLabel.snp.bottom).offset(12)
            }
            resultLabel2.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.left.equalToSuperview().offset(20)
                make.top.equalTo(resultLabel.snp.bottom).offset(12)
            }
            unit1.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalTo(depositLabel.snp.centerY)
            }
            depositNumber.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.right.equalTo(unit1.snp.left).offset(-2)
                make.centerY.equalTo(depositLabel.snp.centerY)
            }
           
            resultNum1.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.left.equalTo(resultLabel.snp.right)
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalTo(resultLabel.snp.centerY)
            }
            resultNum2.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.left.equalTo(resultLabel2.snp.right)
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalTo(resultLabel2.snp.centerY)
            }
            confirm.snp.makeConstraints { (make) in
                make.height.equalTo(44)
                make.right.equalToSuperview().offset(-20)
                make.top.equalTo(resultLabel2.snp.bottom).offset(16)
                make.leading.equalTo(20)
                make.bottom.equalTo(-20)
            }
            
        } else if type == 1 {
            exs_addSubViews([titleLabel,
                                  depositLabel,
                                  depositNumber,
                                  confirm,unit1])
            titleLabel.snp.makeConstraints { (make) in
                make.height.equalTo(22)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.top.equalToSuperview().offset(18)
            }
            depositLabel.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.left.equalToSuperview().offset(20)
                make.top.equalTo(titleLabel.snp.bottom).offset(15)
            }

            unit1.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalTo(depositLabel.snp.centerY)
            }
            depositNumber.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.right.equalTo(unit1.snp.left).offset(-2)
                make.centerY.equalTo(depositLabel.snp.centerY)
            }

            confirm.snp.makeConstraints { (make) in
                make.height.equalTo(44)
                make.leading.equalTo(20)
                make.bottom.equalTo(-20)
                make.top.equalTo(depositLabel.snp.bottom).offset(20)
                make.right.equalToSuperview().offset(-20)
                make.bottom.equalToSuperview().offset(-20)
            }

            depositLabel.text = "cp_calculator_text4".ex_localized()
            resultLabel.text = "cp_content_text19".ex_localized()
            resultLabel2.text = "cp_content_text20".ex_localized()
        } else {
            exs_addSubViews([titleLabel,
                                  depositLabel,
                                  depositNumber,
                                  confirm,
                                  unit1])
            titleLabel.snp.makeConstraints { (make) in
                make.height.equalTo(22)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.top.equalToSuperview().offset(18)
            }
            depositLabel.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.left.equalToSuperview().offset(15)
                make.top.equalTo(titleLabel.snp.bottom).offset(20)
            }

            unit1.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalTo(depositLabel.snp.centerY)
            }
            depositNumber.snp.makeConstraints { (make) in
                make.height.equalTo(14)
                make.right.equalTo(unit1.snp.left).offset(-2)
                make.centerY.equalTo(depositLabel.snp.centerY)
            }

            confirm.snp.makeConstraints { (make) in
                make.height.equalTo(44)
                make.leading.equalTo(20)
                make.bottom.equalTo(-20)
                make.top.equalTo(depositLabel.snp.bottom).offset(20)

                make.right.equalToSuperview().offset(-20)
                make.bottom.equalToSuperview().offset(-20)
            }

            depositLabel.text = "cp_calculator_text3".ex_localized()
        }
//        mainView.center = self.center
//        self.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismiss))
//        self.addGestureRecognizer(tap)
    }
        
    @objc func dismiss(){
        EXAlert.dismiss()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var mainView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(view)
        return view
    }()
    
    lazy var titleLabel : UILabel = {
        let label = UILabel(text: "cp_calculator_text12".ex_localized(),
                            font: UIFont.ThemeFont.HeadBold,
                            textColor: UIColor.ThemeLabel.colorLite,
                            alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var depositLabel : UILabel = {
        let label = UILabel(text: "cp_calculator_text13".ex_localized(), font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var positionLabel : UILabel = {
        let label = UILabel(text: "cp_content_text21".ex_localized(), font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var resultLabel : UILabel = {
        let label = UILabel(text: "cp_calculator_text14".ex_localized(), font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var resultLabel2 : UILabel = {
        let label = UILabel(text: "cp_calculator_text15".ex_localized(), font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var depositNumber : UILabel = {
        let label = UILabel(text: "--", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var positionNumber : UILabel = {
        let label = UILabel(text: "--", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var unit1 : UILabel = {
        let label = UILabel(text: "--", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var resultNum1 : UILabel = {
        let label = UILabel(text: "--", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var resultNum2 : UILabel = {
        let label = UILabel(text: "--", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()

    private lazy var confirm: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_extra_text28".ex_localized(), titleFont: UIFont.ThemeFont.HeadBold, titleColor: UIColor.white)
        button.ext_setBackgroundColor(backgroundColor: UIColor.ThemeBtn.highlight, state: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.ext_SetAddTarget(self, #selector(clickConfirm))
        return button
    }()
    
    
    @objc func clickConfirm(_ btn : UIButton){
        EXAlert.dismiss()
    }
    
    // MARK:- interface
    func updataInfo(_ result1 : String, _ result2 : String, _ result3 : String, _ result4 : String, _ unit : String) {
        
        if self.type == 0 {
            depositNumber.text = result1
            positionNumber.text = result2
            resultNum1.text = result3
            resultNum2.text = result4
        } else if self.type == 1 {
            depositNumber.text = result1
            positionNumber.text = result2
            resultNum1.text = result3
            resultNum2.text = result4
        } else if self.type == 2 {
            depositNumber.text = result1
            positionNumber.text = result2
        }
        unit1.text = unit
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    static func dismiss(v: UIView) {
        for view in UIApplication.shared.keyWindow!.subviews {
            if view is EXSwapCarculateAlertView {
                v.removeFromSuperview()
                break
            }
        }
    }
}
