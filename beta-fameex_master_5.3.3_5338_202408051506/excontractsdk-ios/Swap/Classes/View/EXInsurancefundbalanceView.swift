//
//  EXInsurancefundbalanceView.swift
//  Chainup
//
//  Created by 柴伟东 on 2023/6/17.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import SnapKit
import EXKit
//余额 English: balance
class EXInsurancefundbalanceView: EXCOCustomBaseView{
    override class var viewHeight: CGFloat{
        return 21 + 88 + 18
    }
    
    var changeMarginCallBack: EXComVoidBlock?
    var amount: String = "" {
        didSet{
            numbelLabel.text = amount + self.coin
        }
    }
    var coin: String = "" {
        didSet{
           let text = coin + " " + "cp_contract_data_text21".ex_localized()
            coinTitleButton.setTitle(text, for: .normal)
            coinTitleButton.setTitle(text, for: .selected)
            let size = coinTitleButton.titleResizeSize(topAndBottom: 0, leftRight: 2,btnImageSpace: 10,hasImage: true)
            coinTitleButton.snp.updateConstraints { make in
                make.width.equalTo(size.width)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.coinTitleButton.exs_setLeftTextAndRightImg(btnImageSpace: 10)
            }
        }
    }
    var bgContentView: UIImageView!
    var coinTitleLabel: UILabel!
    var coinTitleButton: UIButton!
    var numbelLabel: UILabel!
    
    override func setSubView(){
        self.backgroundColor = UIColor.ThemeView.bg
        bgContentView = UIImageView()
        bgContentView.isUserInteractionEnabled = true
        bgContentView.image = UIImage.exs_themeImageNamed(imageName: "trade_public_insurance")
        self.addSubview(bgContentView)
        bgContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(21)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-18)
        }
        
        
        let btn = UIButton(type: .custom)
        btn.setTitle("USDT " + "cp_contract_data_text21".ex_localized(), for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryBold
        btn.setTitleColor( UIColor.ThemeLabel.colorLite, for: .normal)
        btn.setTitleColor( UIColor.ThemeLabel.colorLite, for: .selected)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_arrow_down"), for: .normal)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_arrow_down"), for: .selected)
        btn.addTarget(self, action: #selector(changeMargin), for: .touchUpInside)
        coinTitleButton = btn
        
        let numLabel = UILabel()
        numLabel.text = "0"
        numLabel.textColor = UIColor.ThemeLabel.colorLite
        numLabel.font =  UIFont.ThemeFont.HeadMedium
        numLabel.textAlignment = .center
        self.addSubview(numLabel)
        numbelLabel = numLabel
        
        bgContentView.addSubViews([coinTitleButton,numbelLabel])
        coinTitleButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(21)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalTo(128)
        }
        numbelLabel.snp.makeConstraints { make in
            make.top.equalTo(coinTitleButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }
    
    
    @objc func changeMargin(){
        self.changeMarginCallBack?()
    }
}

