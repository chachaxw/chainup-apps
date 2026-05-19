//
//  EXLeverageCurrentVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit 

class EXLeverageCurrentVC: NavCustomVC ,EXEmptyDataSetable{

    var entity = CoinMapEntity()
    {
        didSet{
            self.mainView.entity = entity
        }
    }
    
    var filterData : [String : String] = [:]

    
    lazy var mainView : EXLeverageCurrentView = {
        let view = EXLeverageCurrentView()
        view.extUseAutoLayout()
        return view
    }()

    
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
    
    @objc func clickHistoryBtn(){
        //NSLog ("Entering Historical Delegation")
        let vc = EXLeverageHistoryVC()
        vc.entity = self.entity
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleFilter(_ params:[String:String]) {
        self.filterData = params
        self.mainView.reloadFilter(params)
    }
    
    //Click on the filter button
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

