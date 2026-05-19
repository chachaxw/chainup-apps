//
//  EXMarketSectionV.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXMarketSectionV: UIView {

    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.bodyRegular()
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    lazy var leftView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.highlight
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ThemeView.bg
        addSubViews([nameLabel,leftView])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(2)
            make.right.equalToSuperview()
        }
        leftView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(20)
            make.width.equalTo(3)
        }
    }
    
    func setView(_ name : String){
        nameLabel.text = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
