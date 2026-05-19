//
//  EXEntrustFooterView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXEntrustFooterView: UIView {
    
    lazy var line : UIView = {
        let line = UIView()
        line.backgroundColor = .Ex.fill4
        return line
    }()
    
    lazy var titleLabel : UILabel = {
        let v = UILabel(font: .Ex.medium(14), textColor: .Ex.text2)
        v.text = "common_text_tip".localized()
        return v
    }()
    
    lazy var infoLabel  : UILabel = {
        let v = UILabel(font: .Ex.medium(12), textColor: .Ex.text2)
        v.text = "common_text_entrustListLimit".localized()
        v.numberOfLines = 0
        return v
     }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .Ex.fill2
       
        addSubViews([titleLabel, infoLabel, line])
        
        line.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.bottom.equalTo(infoLabel.snp.top).offset(-5)
            make.left.equalTo(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-20)
        }

    }
    
    static func footerHeight() -> CGFloat {
        let titleH = "common_text_tip".localized().textSizeWithFont(UIFont.Ex.medium(14), width: SCREEN_WIDTH - 30).height + 20
        let contentH = "common_text_entrustListLimit".localized().textSizeWithFont(UIFont.Ex.medium(12), width: SCREEN_WIDTH - 30).height + 5 + 20
        return titleH + contentH + 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
