//
//  EXMyInfoVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXMyInfoVC: NavCustomVC {
    
    lazy var mainView: EXMyInfoView = {
        let view = EXMyInfoView()
        view.extUseAutoLayout()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setNavCustomV() {
        super.setNavCustomV()
        self.navtype = .listtitle
        self.setTitle("userinfo_text_data".localized())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appApi.hideAutoLoading()
        UserInfoEntity.sharedInstance().getUserInfo ({[weak self] in
            guard let self else { return }
            self.mainView.setData()
        }) {
            
        }
    }
}

