//
//  EXDealBtn.swift
//  Chainup
//
//  Created by liuxuan on 2023/7/1.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXDealBtn: UIButton {
    //Bottom horizontal line
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.extSetCornerRadius(1)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([lineV])
        lineV.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(2)
            make.width.equalTo(25)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

