//
//  EXLeverageHistoryVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit 

class EXLeverageHistoryVC: NavCustomVC ,EXEmptyDataSetable {
    
    lazy var mainView : EXLeverageHistoryView = {
        let view = EXLeverageHistoryView()
        view.extUseAutoLayout()
        return view
    }()

    

    var filterData : [String : String] = [:]
    
    
    var entity = CoinMapEntity()
    {
        didSet{
            self.mainView.entity = entity
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubViews([mainView])
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.exEmptyDataSet(mainView.tableView)
    }
    
    override func setNavCustomV() {
        self.navCustomView.isHidden = true
    }
    
    func handleFilter(_ params:[String:String]) {
        self.filterData = params
        self.mainView.reloadFilter(params)
    }

 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
