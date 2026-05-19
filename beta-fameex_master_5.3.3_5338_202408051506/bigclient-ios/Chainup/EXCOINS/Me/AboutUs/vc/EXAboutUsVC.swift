//
//  EXAboutUsVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXAboutUsVC: NavCustomVC {
    
    lazy var mainView: EXAboutUsView = {
        let view = EXAboutUsView()
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
        self.setTitle("personal_text_aboutus".localized())
        self.lastVC = true
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
