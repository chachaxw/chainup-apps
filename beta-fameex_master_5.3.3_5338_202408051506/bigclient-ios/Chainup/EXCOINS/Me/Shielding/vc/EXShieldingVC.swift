//
//  EXShieldingVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit 

class EXShieldingVC: NavCustomVC,EXEmptyDataSetable {

    lazy var mainView : EXShieldingView = {
        let view = EXShieldingView()
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
        self.exEmptyDataSet(mainView.tableView)
    }
    
    override func setNavCustomV() {
        self.setTitle(LanguageTools.getString(key: "personal_text_blacklist"))
        self.xscrollView = mainView.tableView
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
