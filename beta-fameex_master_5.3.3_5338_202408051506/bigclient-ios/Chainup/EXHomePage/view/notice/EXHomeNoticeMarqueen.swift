//
//  EXHomeNoticeMarqueen.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/3.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXHomeNoticeMarqueen: EXMarqueenCell {
    
    
    lazy var noticeTitle : UILabel = {
        let title = UILabel()
        title.textColor = UIColor.ThemeLabel.colorLite
        title.font = UIFont.ThemeFont.SecondaryMedium
        return title
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      
    }
    
    public required init(reuseIdentifier: String?, textLabelLeading: CGFloat = 10, textLabelTrailing: CGFloat = 10) {
        super.init(reuseIdentifier: reuseIdentifier, textLabelLeading: textLabelLeading, textLabelTrailing: textLabelTrailing)
        self.addSubview(noticeTitle)
        noticeTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    
}

class EXContractRateMarqueen:EXHomeNoticeMarqueen {
    required init(reuseIdentifier: String?, textLabelLeading: CGFloat = 10, textLabelTrailing: CGFloat = 10) {
        super.init(reuseIdentifier: reuseIdentifier, textLabelLeading: textLabelLeading, textLabelTrailing: textLabelTrailing)
        noticeTitle.textAlignment = .right
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
