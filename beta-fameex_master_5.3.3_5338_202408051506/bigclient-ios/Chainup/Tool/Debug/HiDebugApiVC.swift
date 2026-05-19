//
//  HiDebugApiVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/18.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class HiDebugApiVC: UIViewController {
    
    let titles = ["cctv.com","apple.com","huawei.com","taobao.com","hiotc.pro","hiup.pro","bitwind","1006","bione","UCBIT()","ProEx()"]
    
    
    var customInput:UITextField?
    var headerView:UIView?
    
    
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
    
    @objc func confirm() {
        guard let cid = customInput?.text ,cid.count > 0 else {return}
        EXNetworkDoctor.sharedManager.changeDeubgSaas(companID: cid)
        reloadApp()
    }
    
    func reloadApp() {
        EXAppCache.sharedCache.removeAllCache { (success) in
            if success {
                XUserDefault.tokenValue = nil
                //Obtaining Public Data
                EXAppConfigManager.sharedInstance.fetchAppConfig()
                EXAppMarketManager.sharedInstance.fetchMarket()
                BusinessTools.reloadWindow()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mainTable)
        mainTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let title = UILabel.init(frame: CGRect.init(x: 10, y: 5, width: SCREEN_WIDTH, height: 20))
        title.text = "Saas"
        title.textColor = UIColor.ThemeLabel.colorLite
        
        let confirmBtn = UIButton.init(type: .custom)
        confirmBtn.setTitle("sure", for: .normal)
        confirmBtn.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        confirmBtn.frame = CGRect.init(x: SCREEN_WIDTH - 100, y: 0, width: 100, height: 100)
        confirmBtn.backgroundColor = UIColor.ThemeView.highlight
        headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 100))
        headerView?.backgroundColor = UIColor.green
        customInput = UITextField.init(frame: CGRect(x: 10, y: 40, width: SCREEN_WIDTH - 120, height: 50))
        customInput?.keyboardType = .numberPad
        customInput?.borderStyle = .roundedRect
        customInput?.placeholder = "saas ID"
        headerView?.addSubview(customInput!)
        headerView?.addSubview(title)
        headerView?.addSubview(confirmBtn)
        
        self.mainTable.tableHeaderView = headerView
    }
    
}


extension HiDebugApiVC : UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = titles[indexPath.row]
        if title.contains("cctv") {
            EXNetworkDoctor.sharedManager.changeDebugApi(useHost: title)
        }else if title.contains("apple") {
            EXNetworkDoctor.sharedManager.changeDebugApi(useHost: title)
        }else if title.contains("hiotc") {
            EXNetworkDoctor.sharedManager.changeDebugApi(useHost: title)
        }else if title.contains("huawei") {
            EXNetworkDoctor.sharedManager.changeDebugApi(useHost: title)
        }else if title.contains("taobao") {
            EXNetworkDoctor.sharedManager.changeDebugApi(useHost: title)
        }else if title.contains("hiup") {
            EXNetworkDoctor.sharedManager.changeDebugApi(useHost: title)
        }else if title.contains("bitwind") {
            EXNetworkDoctor.sharedManager.changeDeubgSaas(companID: "1003")
        }else if title.contains("bione") {
            EXNetworkDoctor.sharedManager.changeDeubgSaas(companID: "1321")
        }else if title.contains("UCBIT") {
            EXNetworkDoctor.sharedManager.changeDeubgSaas(companID: "1309")
        }else if title.contains("ProEx") {
            EXNetworkDoctor.sharedManager.changeDeubgSaas(companID: "1317")
        }
        reloadApp()
        
    }
    
}

