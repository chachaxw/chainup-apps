//
//  EXSecurityCenterVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXSecurityCenterVC: NavCustomVC {
    var dataVm = EXAccountDeleteViewModel()
    lazy var mainView : EXSecurityView = {
        let view = EXSecurityView()
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
    //    mainView.setData()

        //Has the account cancellation been opened
        dataVm.queryOpenDeleteAccount{ [weak self] in
            guard let newSelf = self else{
                return
            }
            if newSelf.dataVm.open.deleteAccount == "1" {
                newSelf.mainView.addDelteAccount()
            }
        } errorBlock: {
            
        }

    }
    
    
    override func setNavCustomV() {
        self.setTitle(LanguageTools.getString(key: "personal_text_safetycenter"))
        self.navtype = .listtitle
//        self.xscrollView = mainView.tableView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView.updateSafeLevel()
        mainView.setData()
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

