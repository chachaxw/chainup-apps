//
//  EXHistoryEntrustVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit 

class EXHistoryEntrustVC: NavCustomVC ,EXEmptyDataSetable {
    
    var filterData : [String : String] = [:]
        
    var entity = CoinMapEntity()
    {
        didSet{
            self.mainView.entity = entity
        }
    }
    
    lazy var mainView : EXHistoryEntrustView = {
        let view = EXHistoryEntrustView()
        view.extUseAutoLayout()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(mainView)

        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    override func setNavCustomV() {
        self.navCustomView.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func handleFilter(_ params:[String:String]) {
        self.filterData = params
        self.mainView.reloadFilter(params)
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
