//
//  RegionHeaderView.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/17.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit

class RegionHeaderView: UITableViewHeaderFooterView {
    
    //name
    lazy var nameLabel : UILabel = {
        let nameLabel = UILabel()
        nameLabel.extUseAutoLayout()
        nameLabel.headRegular()
        nameLabel.textColor = UIColor.ThemeLabel.colorLite
        return nameLabel
    }()
    
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeNav.bg
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.ThemeNav.bg
        contentView.addSubViews([backView,nameLabel])
        backView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(20)
            make.left.equalToSuperview().offset(11)
        }
    }
    
    func setCellLabel(_ str : String){
        nameLabel.text = str
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

