//
//  EXCoinRateVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/10.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit


class EXCoinRateVC: UIViewController {
    
    var coins:[String] = []
    var oldCoins:[String] = []
    
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
        self.coins = EXAppMarketManager.sharedInstance.marketVm.currentRateMap.keys.sorted(by: { (a, b) -> Bool in
            return a > b
        })
        
//        if let rate = PublicInfoManager.sharedInstance.allCoinExchangeRate[LanguageTools.phoneLanguage] {
//            self.oldCoins = rate.keys.sorted(by: { (a, b) -> Bool in
//                return a > b
//            })
//        }

        
        mainTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


extension EXCoinRateVC : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coins.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: nil)
        if coins.count > indexPath.row {
            let entity = self.coins[indexPath.row]
            cell.textLabel?.text = "(\(entity))"
        }else {
            cell.textLabel?.text = "！！！！！！"
        }
        
        if oldCoins.count > indexPath.row {
            let entity = self.oldCoins[indexPath.row]
            cell.detailTextLabel?.text = "(\(entity))"
        }else {
            cell.detailTextLabel?.text = "！！！！！！"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


