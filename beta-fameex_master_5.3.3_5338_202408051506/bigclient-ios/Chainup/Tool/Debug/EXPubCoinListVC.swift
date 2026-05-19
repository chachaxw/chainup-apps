//
//  EXPubCoinListVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/10.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit



class EXPubCoinListVC: UIViewController {
    
    var coins:[CoinListEntity] = []
    var oldCoins:[CoinListEntity] = []
    
    lazy var mainTable : UITableView = {
        let view = UITableView.init(frame: .zero, style:.grouped)
        view.bounces = false
        view.delegate = self
        view.dataSource = self
        view.estimatedRowHeight = 0
        view.estimatedSectionHeaderHeight = 0
        view.estimatedSectionFooterHeight = 0
        view.extUseAutoLayout()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mainTable)
        self.coins = EXAppMarketManager.sharedInstance.marketVm.coinList
//        self.oldCoins = exappmar.sharedInstance.getAllCoinEntiy()
        
        mainTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


extension EXPubCoinListVC : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count > oldCoins.count ? coins.count : oldCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: nil)
        if coins.count > indexPath.row {
            let entity = self.coins[indexPath.row]
            cell.textLabel?.text = "(\(entity.showName))"
        }else {
            cell.textLabel?.text = "！！！！！！"
        }
        
        if oldCoins.count > indexPath.row {
            let entity = self.oldCoins[indexPath.row]
            cell.detailTextLabel?.text = "(\(entity.showName))"
        }else {
            cell.detailTextLabel?.text = "！！！！！！"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

