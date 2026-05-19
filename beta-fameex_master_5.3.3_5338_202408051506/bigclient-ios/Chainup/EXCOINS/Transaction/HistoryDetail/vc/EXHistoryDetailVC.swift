//
//  EXHistoryDetailVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXHistoryDetailVC: NavCustomVC {
    
    var entity = EXCurrentEntrustEntity()
    {
        didSet{
            mainView.entity = entity
        }
    }
    
    var leverEntity = EXLeverageHistoryDetailModel()
    {
        didSet{
            mainView.leverEntity = leverEntity
        }
    }
    
    var type = EXHistoryDetailType.coin
    {
        didSet{
            mainView.type = type
        }
    }
    
    lazy var mainView : EXHistoryDetailView = {
        let view = EXHistoryDetailView()
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
        mainView.getDatas()
    }
    
    override func setNavCustomV() {
        var title = ""
        if type == .coin{
            title = entity.side == "BUY" ? "contract_action_buy".localized() : "contract_action_sell".localized()
            title = title + " " + entity.baseCoin.aliasName()
        }else{
            title = leverEntity.side == "BUY" ? "contract_action_buy".localized() : "contract_action_sell".localized()
            title = title + " " + leverEntity.baseCoin.aliasName()
        }
        self.setTitle(title)
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
