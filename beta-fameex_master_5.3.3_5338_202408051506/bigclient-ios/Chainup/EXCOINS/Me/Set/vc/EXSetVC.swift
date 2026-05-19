//
//  EXSetVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXSetVC: NavCustomVC {

    lazy var mainView : EXSetView = {
        let view = EXSetView()
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
        BusinessTools.checkVersionUpdate{ res in
            if res{
                DispatchQueue.main.async { [weak self] in
                    self?.mainView.updateAbouts()
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView.setData()
        mainView.tableView.reloadData()
    }
    
    override func setNavLeft() {
        self.setTitle(LanguageTools.getString(key: "personal_text_setting"))
        self.xscrollView = mainView.tableView
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
