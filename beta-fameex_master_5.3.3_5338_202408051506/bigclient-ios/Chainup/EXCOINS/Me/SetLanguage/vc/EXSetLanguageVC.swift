//
//  EXSetLanguageVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSetLanguageVC: UIViewController {
    
    lazy var mainView : EXSetLanguageV = {
        let view = EXSetLanguageV()
        view.extUseAutoLayout()
        view.setData()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.roundCorners(corners: [.topLeft,.topRight], radius: 10)
        let list = EXAppConfigManager.sharedInstance.configVm.cfgModel.langList
#if DEBUG
        for lan in list{
            print("lan = \(lan.langKey) url =\(lan.nowFileAddress)")
        }
#endif
        
    }
//    override func setNavCustomV() {
//        self.setTitle(LanguageTools.getString(key: "customSetting_action_language"))
//        self.xscrollView = mainView.tableView
//        self.lastVC = true
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
