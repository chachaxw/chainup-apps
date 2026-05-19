//
//  EXPubCoinMapVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/10.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
class EXPubCoinMapVC: UIViewController {
    
    var type:String = ""
    
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
    
        mainTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


extension EXPubCoinMapVC : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if type == "coin" {
            return EXAppMarketManager.sharedInstance.getMarketSorts()[section]
        }else if type == "rate" {
            return ""
        }else {
            return EXAppMarketManager.sharedInstance.getAllLeverMarketArray()[section]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if type == "coin" {
            return EXAppMarketManager.sharedInstance.getMarketSorts().count
        }else if type == "rate" {
            return 1
        }else {
            return EXAppMarketManager.sharedInstance.getAllLeverMarketArray().count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if type == "coin" {
            let market =  EXAppMarketManager.sharedInstance.getMarketSorts()[section]
            let coins = EXAppMarketManager.sharedInstance.getCoinPairsBy(marketName: market)
            return coins.count
        }else if type == "rate" {
            return EXAppMarketManager.sharedInstance.getMarketSorts().count
        }else {
            let market = EXAppMarketManager.sharedInstance.getAllLeverMarketArray()[section]
            let coins = EXAppMarketManager.sharedInstance.getLeverMarketMaps(market)
            return coins.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: nil)
        
        if type == "rate" {
            let market =  EXAppMarketManager.sharedInstance.getMarketSorts()[indexPath.row]
            let rateInfo = EXAppMarketManager.sharedInstance.getCoinExchangeRate(market)
//            let oldrateInfo = PublicInfoManager.sharedInstance.getCoinExchangeRate(market)

            cell.textLabel?.text = market + "\(rateInfo.0)/\(rateInfo.1)/\(rateInfo.2)"
//            cell.detailTextLabel?.text =  market + "\(oldrateInfo.0)/\(oldrateInfo.1)/\(oldrateInfo.2)"
            return cell
        }else {
            var coins:[CoinMapEntity] = []
            var oldCoins:[CoinMapEntity] = []

            if type == "coin" {
                let market =  EXAppMarketManager.sharedInstance.getMarketSorts()[indexPath.section]
                coins = EXAppMarketManager.sharedInstance.getCoinPairsBy(marketName: market)
//                oldCoins = PublicInfoManager.sharedInstance.getCoinMapInfoWithCoin(market).coinMapEntity
            }else if type == "lever" {
                let market = EXAppMarketManager.sharedInstance.getAllLeverMarketArray()[indexPath.section]
                coins = EXAppMarketManager.sharedInstance.getLeverMarketMaps(market)
//                let fullary = PublicInfoManager.sharedInstance.getCoinMapInfoWithCoin(market).coinMapEntity
//                oldCoins = fullary.filter({ (item) -> Bool in
//                    return item.isOpenLever == "1"
//                })
            }

            if coins.count > indexPath.row {
                let entity = coins[indexPath.row]
                cell.textLabel?.text = "(\(entity.showName))"
            }else {
                cell.textLabel?.text = "！！！！！！"
            }
            
            if oldCoins.count > indexPath.row {
                let entity = oldCoins[indexPath.row]
                cell.detailTextLabel?.text = entity.showName
            }else {
                cell.detailTextLabel?.text = "！！！！！！"
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


