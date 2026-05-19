//
//  EXChangeOTCPWVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXChangeOTCPWVC: NavCustomVC {

    var type: EXSafetyCheckType = .fundPasswordSet
    lazy var mainView : EXChangeOTCPWView = {
        let view = EXChangeOTCPWView()
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
        
        mainView.type = self.type
        
        mainView.setPwdTitletCallBack = { [weak self] in
            guard let `self` = self else { return }
            self.setTitle(LanguageTools.getString(key: "safety_text_editOtcPassword"))
        }
        
    }
    
    override func setNavCustomV() {
        //Fund password has been set
        if self.type == .fundPasswordModify{
            self.setTitle(LanguageTools.getString(key: "safety_text_editOtcPassword"))
        }else if self.type == .fundPasswordSet{//No fund password set
            self.setTitle(LanguageTools.getString(key: "safety_action_otcPassword"))
        }
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

