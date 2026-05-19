//
//  EXBannerItemCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/16.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import FSPagerView

class EXBannerItemCell: FSPagerViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.contentView.layer.shadowColor = UIColor.clear.cgColor
        self.contentView.layer.shadowRadius = 0
        self.contentView.layer.shadowOpacity = 0
        self.contentView.layer.shadowOffset = .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
