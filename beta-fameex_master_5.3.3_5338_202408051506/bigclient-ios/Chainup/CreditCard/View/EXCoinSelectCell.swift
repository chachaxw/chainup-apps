//
//  EXCoinSelectCell.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/1.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

class EXCoinSelectCell: EXBaseCell {
    
    var coin: EXCreditCoin? {
        didSet{
            iconView.coin = coin
        }
    }
    lazy var iconView: EXQuickCoinView = {
        let v = EXQuickCoinView()
        return v
    }()
    
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    override func setUpView() {
        self.contentView.addSubViews([iconView, line])
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-3)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
}
