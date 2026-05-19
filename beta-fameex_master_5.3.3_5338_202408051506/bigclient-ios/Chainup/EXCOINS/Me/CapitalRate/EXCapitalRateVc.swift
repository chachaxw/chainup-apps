//
//  EXCapitalRateVc.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/15.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXCapitalRateVc: NavCustomVC {
    
    var personData = PersonCenterBanner()
    lazy var mainView : EXCapitalRateView = {
        let view = EXCapitalRateView()
        view.extUseAutoLayout()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        contentView.addSubViews([mainView])
        mainView.personData = personData
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func setNavCustomV() {
        self.setTitle(LanguageTools.getString(key: "personal_Center_text3"))
        self.xscrollView = mainView.tableView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
