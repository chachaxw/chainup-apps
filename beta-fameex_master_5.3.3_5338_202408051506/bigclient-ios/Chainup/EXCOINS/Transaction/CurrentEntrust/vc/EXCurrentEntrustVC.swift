//
//  EXCurrentEntrustVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit 

class EXCurrentEntrustVC: NavCustomVC , EXEmptyDataSetable{
    
    var filterData : [String : String] = [:]
    
    var entity = CoinMapEntity()
    {
        didSet{
            self.mainView.entity = entity
        }
    }
        
    lazy var mainView : EXCurrentEntrustView = {
        let view = EXCurrentEntrustView()
        view.extUseAutoLayout()
        return view
    }()
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubViews([mainView])
        
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
 
    }
    
    override func setNavCustomV() {
        self.navCustomView.isHidden = true
    }
    
    func handleFilter(_ params:[String:String]) {
        //If you choose to force all
        
        self.filterData = params
        self.mainView.reloadFilter(params)
    }
    
}

