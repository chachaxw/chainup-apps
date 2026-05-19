//
//  EXRealNameThreeView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXRealNameThreeView: UIView {
    
//    lazy var popbackBtn : UIButton = {
//        let btn = UIButton()
//        btn.extUseAutoLayout()
//        btn.setImage(UIImage.themeImageNamed(imageName: "quotes_delete"), for: UIControl.State.normal)
//        btn.extSetAddTarget(self, #selector(clickBtn))
//        return btn
//    }()
//close
    lazy var cancelbtn:UIButton = {
        let btnBuy = UIButton(type: .custom)
        btnBuy.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btnBuy.setTitle("common_text_close".localized(), for: .normal)
        btnBuy.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btnBuy.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .selected)
        btnBuy.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
//        btnBuy.isSelected = true
        return btnBuy
    }()
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "personal_successfulhints")
        return imgV
    }()

    lazy var submitLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = LanguageTools.getString(key: "common_tip_cerSubmitSuccess")
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.H3Bold
        label.textAlignment = .center
        return label
    }()
    
    lazy var detailLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = LanguageTools.getString(key: "common_tip_cerSubmitDesc")
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        label.layoutIfNeeded()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([cancelbtn,imgV,submitLabel,detailLabel])
        cancelbtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.width.equalTo(40)
            make.right.equalToSuperview().offset(-15)
        }
        imgV.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(123)
            make.height.width.equalTo(66)
            make.centerX.equalToSuperview()
        }
        submitLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imgV.snp.bottom).offset(20)
            make.height.equalTo(25)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(submitLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(49)
            make.right.equalToSuperview().offset(-49)
        }
    }
    
    @objc func clickBtn(){
        EXAlert.dismiss()
//        self.yy_viewController?.popBack()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

