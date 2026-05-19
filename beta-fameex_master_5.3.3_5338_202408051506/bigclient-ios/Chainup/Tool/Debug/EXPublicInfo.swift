//
//  EXPublicInfo.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/10.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXPublicInfo: UIViewController {
    
    let titles = [""]
    
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


extension EXPublicInfo : UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let coinlistvc = EXPubCoinListVC.init()
            self.navigationController?.pushViewController(coinlistvc, animated: true)
        }else if indexPath.row == 1 {
            let coinlistvc = EXPubCoinMapVC.init()
            coinlistvc.type = "coin"
            self.navigationController?.pushViewController(coinlistvc, animated: true)
        }else if indexPath.row == 2 {
            let coinlistvc = EXPubCoinMapVC.init()
            coinlistvc.type = "lever"
            self.navigationController?.pushViewController(coinlistvc, animated: true)
        }else if indexPath.row == 4 {
            let coinlistvc = EXPubCoinMapVC.init()
            coinlistvc.type = "rate"
            self.navigationController?.pushViewController(coinlistvc, animated: true)
        }else if indexPath.row == 5 {
            
            EXAppCache.sharedCache.removeAllCache { (isRemove) in
                EXAlert.showSuccess(msg: "success")
            }
        }else if indexPath.row == 6 {
            EXLinkAlarm.sharedManager.changeLinkForUrgentcy()
        }else if indexPath.row == 7 {
            EXAppCache.sharedCache.setAppHomeVersion(ver: "1")
        }else if indexPath.row == 8 {
            EXAppCache.sharedCache.setAppHomeVersion(ver: "2")
        }else if indexPath.row == 9 {
            EXAppCache.sharedCache.setAppHomeVersion(ver: "3")
        }else {
            let coinlistvc = EXCoinRateVC.init()
            self.navigationController?.pushViewController(coinlistvc, animated: true)
        }
    }
    
}

