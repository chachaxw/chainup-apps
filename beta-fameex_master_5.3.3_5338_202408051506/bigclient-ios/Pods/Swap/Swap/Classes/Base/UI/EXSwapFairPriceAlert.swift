//
//  EXSwapFairPriceAlert.swift
//  Chainup
//
//  Created by ZYJ on 2023/5/11.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
///标记价格和指数价格弹框 English: /Mark price and index price pop ups
class EXSwapFairPriceAlert: EXCOCustomBaseView {

    
    override func setSubView() {
        let v = UIView()
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.lessThanOrEqualToSuperview()
            make.center.equalToSuperview()
        }
        container.addArrangedSubview(v)
        v.addSubViews([
            topTitleLabel,
            titleLabel,
            msgLabel,
            line,
            secondTitle,
            secondMessageLabel,
            secondline,
            positiveBtn
        ])
       
        topTitleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(20)
            make.height.equalTo(22)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(topTitleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(18)
           
        }
        msgLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(msgLabel.snp.bottom).offset(12)
            make.height.equalTo(1)
            make.left.width.equalTo(msgLabel)
        }
        secondTitle.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(18)
        }
        secondMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(secondTitle.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        secondline.snp.makeConstraints { make in
            make.top.equalTo(secondMessageLabel.snp.bottom).offset(12)
            make.height.equalTo(1)
            make.left.width.equalTo(msgLabel)
        }
        
        positiveBtn.snp.makeConstraints { make in
            make.top.equalTo(secondline.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    lazy var container: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.backgroundColor = UIColor.ThemeView.alertBg
        view.distribution = .fill
        return view
    }()
    
    /// ///名称 English: /Name
    lazy var topTitleLabel: UILabel = {
        let label = UILabel(text:"cp_overview_text20".ex_localized(), font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    

    lazy var msgLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    lazy var secondTitle: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var secondMessageLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var secondline: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    lazy var positiveBtn:EXSButton = {
        let btn = EXSButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.backgroundColor = .Ex.main1
        btn.setTitleColor(.Ex.text4, for:.normal)
        btn.setTitle("", for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btn.extSetAddTarget(self, #selector(passtiveAction))
        return btn
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        exs_roundCorners(corners: [.allCorners], radius: 12)
    }
    func configSigleAlert(title:String?,
                          message:String,
                          sigleBtnTitle:String = "cp_extra_text28".ex_localized(), lineHeight: CGFloat? = nil)
    {
        
        if let altTitle = title,!altTitle.isEmpty {
            titleLabel.text = altTitle
        }else {
        }
        
        if lineHeight != nil {
            msgLabel.attributedText = message.exs_lineSpacingString(font: msgLabel.font, color: msgLabel.textColor, lineSpacing: lineHeight!, textAligment: .left)
        }
        else {
            msgLabel.text = message
        }
        positiveBtn.setTitle(sigleBtnTitle, for: .normal)
    }
    @objc func passtiveAction(_ sender: EXSButton) {
        EXAlert.dismiss()
    }
}

