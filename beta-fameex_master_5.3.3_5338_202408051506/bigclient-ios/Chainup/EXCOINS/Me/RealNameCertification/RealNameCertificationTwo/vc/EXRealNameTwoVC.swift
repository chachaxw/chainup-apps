//
//  EXRealNameTwoVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXRealNameTwoVC: NavCustomVC {
    
    lazy var mainView : EXRealNameTwoView = {
        let view = EXRealNameTwoView()
        view.extUseAutoLayout()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.addSubViews([mainView])
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func setNavCustomV() {
        self.setTitle(LanguageTools.getString(key: "kyc_page_name"))
        navtype = .listtitle
        self.lastVC = false
        
    }
    
    
}
