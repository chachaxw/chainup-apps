//
//  EXFavoritesEmptyView.swift
//  Chainup
//
//  Created by liuxuan on 2023/11/2.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXFavoritesEmptyView: UIView {

    lazy var iconImgView:UIImageView = {
        let icon = UIImageView.init()
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    lazy var actionBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configEmptySubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configEmptySubViews() {
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(iconImgView)
        self.addSubview(actionBtn)
        iconImgView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.width.equalTo(80)
        }
        actionBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImgView.snp.bottom).offset(12)
           // make.bottom.equalToSuperview()
            make.height.equalTo(18)
            make.width.equalTo(110)
        }
        
    }
}
