//
//  EXPriceindicationView.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/25.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
///Reference price
class EXPriceindicationView: UIView {
    lazy var rateLabel: UILabel = {
        let label = UILabel(text: "creditCard_text3".localized() + "quick_buy_coin_text1".localized(), font: UIFont.Ex.regular(12), textColor: UIColor.Ex.text2, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var availableLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.Ex.regular(12), textColor: UIColor.Ex.text2, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var imgView : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage(named: "icon_quickbuycoin_transfer")
        arrowImmg.isHidden = true 
        return arrowImmg
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.addSubViews([rateLabel,imgView,availableLabel])
        rateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview()//.offset(15)
            make.height.equalTo(14)
        }
        imgView.snp.makeConstraints { make in
            make.right.equalToSuperview() //.offset(-15)
            make.width.equalTo(15)
            make.height.equalTo(12)
            make.centerY.equalTo(rateLabel)
        }
        availableLabel.snp.makeConstraints { make in
            make.top.equalTo(rateLabel.snp.bottom).offset(8)
            make.left.equalToSuperview()//.offset(15)
            make.height.equalTo(14)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

