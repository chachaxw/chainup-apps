//
//  EXInviteVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/6/17.
//  Copyright © 2023 zewu wang. All rights reserved.
//Invite friends

import UIKit

class EXInviteVC: NavCustomVC {
    
    lazy var mainView : EXInviteView = {
        let view = EXInviteView()
        view.extUseAutoLayout()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func setNavCustomV() {
        self.setTitle("common_action_inviteFriend".localized())
        self.navtype = .listtitle
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

