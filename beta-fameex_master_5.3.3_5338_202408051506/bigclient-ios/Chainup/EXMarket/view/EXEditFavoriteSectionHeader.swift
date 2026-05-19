//
//  EXEditFavoriteSectionHeader.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/29.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXEditFavoriteSectionHeader: UIView {
    
    lazy var symbolLabel:UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.ThemeLabel.colorDark
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "common_text_coinsymbol".localized()
        label.textAlignment = .left
        return label
    }()
    
    lazy var topLabel:UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.ThemeLabel.colorDark
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "market_edit_like_type_top".localized()
        label.textAlignment = .center
        return label
    }()
    
    lazy var rightLabel:UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.ThemeLabel.colorDark
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "market_edit_like_type_drag".localized()
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(symbolLabel)
        self.addSubview(topLabel)
        self.addSubview(rightLabel)
        let centerX = EXUIMeasure.getPercentX(0.73)

        symbolLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalToSuperview()
        }
        
        topLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(centerX)
            make.top.equalToSuperview()
        }
        
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.top.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

