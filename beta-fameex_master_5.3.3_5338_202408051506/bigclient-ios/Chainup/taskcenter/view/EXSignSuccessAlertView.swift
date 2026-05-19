//
//  EXSignSuccessAlertView.swift
//  Chainup
//
//  Created by cwd on 2023/7/26.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXSignSuccessAlertView: EXView {
    
    var signItem: EXSignShowInfo? {
        didSet{
            guard let signItem = signItem else { return }
            let showText = signItem.amount + " " + signItem.coin
            let attr = showText.attributeString(specalSubStr: signItem.amount, specailAttri:[
                NSAttributedString.Key.font: UIFont.Ex.medium(24),
                NSAttributedString.Key.foregroundColor: UIColor.Ex.main1],
                                                commonAttri: [
                                                    NSAttributedString.Key.font: UIFont.Ex.medium(16),
                                                    NSAttributedString.Key.foregroundColor:UIColor.Ex.text1
                                                ])
            contentLabel.attributedText = attr
            if signItem.successDes.count > 0 {
                titleLabel.text = signItem.successDes
            }
        }
    }
    
    
    override func setupView() {
        self.backgroundColor = .Ex.fill6
        self.corneradius = 12
        self.addSubViews([img,titleLabel,contentLabel,sureBtn])
        img.snp.makeConstraints { make in
            make.height.equalTo(115)
            make.width.equalTo(132)
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(img.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(19)
        }
        contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        sureBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        self.snp.makeConstraints { make in
            make.height.equalTo(314)
        }
    }
    
    
    @objc func clickBtn(){
        EXAlert.dismiss()
    }
    
    
    lazy var img : UIImageView = {
        let img = UIImageView()
        img.image = UIImage.svgImage(named: "task_successfully")
        return img
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"rewardCenter_text13".localized(), font: .Ex.medium(16), textColor: .Ex.text1, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(16), textColor: .Ex.text1, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var sureBtn : EXButton = {
        let btn = EXButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.setTitle(LanguageTools.getString(key: "rewardCenter_text14"), for: .normal)
        return btn
    }()
    
}
