//
//  ReloadRequestDatasView.swift
//  Chainup
//
//  Created by zewu wang on 2023/9/12.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class ReloadRequestDatasView: UIView {

    lazy var btn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.extSetTitle(LanguageTools.getString(key: "no_data_available_click_refresh"), 15, UIColor.ThemekLine.labcolorMedium, .normal)
        btn.extSetAddTarget(self, #selector(clickBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(300)
        }
    }
    
    @objc func clickBtn(){
        EXAppMarketManager.sharedInstance.fetchMarket()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
