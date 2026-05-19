//
//  EXSwapRateAlertView.swift
//  EXSwapSDK
//
//  Created by ZYJ on 2023/5/6.
//

import UIKit

class EXSwapRateAlertView: UIView {
    
    /// ///名称 English: /Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"cp_overview_text26".ex_localized(), font: UIFont.ThemeFont.HeadMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: .center)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var firstView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.BodyMedium
        view.ext_UseAutoLayout()
        view.setLeftText("cp_overview_text32".ex_localized())
        return view
    }()
    lazy var secondView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.BodyMedium
        view.setLeftText("cp_overview_text33".ex_localized())
        return view
    }()
    lazy var thirdView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.BodyMedium
        view.setLeftText("cp_overview_text45".ex_localized())
        return view
    }()
    private lazy var confirmButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_extra_text28".ex_localized(), titleFont: UIFont.ThemeFont.HeadBold, titleColor: .Ex.text4)
        button.ext_setBackgroundColor(backgroundColor: UIColor.ThemeBtn.highlight, state: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.ext_SetAddTarget(self, #selector(clickConfirmButton))
        return button
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.layer.cornerRadius = 12

        exs_addSubViews([titleLabel,firstView,secondView,thirdView,confirmButton])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
            
        }
        firstView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(5)
            make.height.equalTo(18)
            make.trailing.equalTo(-5)
        }
        secondView.snp.makeConstraints { (make) in
            make.top.equalTo(firstView.snp.bottom).offset(12)
            make.leading.trailing.height.equalTo(firstView)
        }
        thirdView.snp.makeConstraints { (make) in
            make.top.equalTo(secondView.snp.bottom).offset(12)
            make.leading.trailing.height.equalTo(firstView)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(thirdView.snp.bottom).offset(20)
            make.height.equalTo(44)
            make.bottom.equalTo(-20)
        }
    }
    @objc func clickConfirmButton() {
       
        EXAlert.dismiss()
    }
    func config(first:String) {
        
        firstView.setRightText(first)
    }
    func config(second:String,third:String) {
        secondView.setRightText(second)
        thirdView.setRightText(third)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

