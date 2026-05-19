//
//  EXSelectCoinView.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/1.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXSelectCoinView: EXCustomBaseView {
    private let cellid = "EXCoinSelectCell"
    var coinList: [EXCreditCoin]? {
        didSet{
            tableView.reloadData()
        }
    }
    var fiterData = [EXCreditCoin]()
    var isSearch = false
    var selectCoinBlock: SelectCoinBlock?
    
     //MARK: lifecycle
    override func setSubView(){
        self.addSubViews([tableView])
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
//            make.left.right.bottom.equalToSuperview()
        }
    }
    
    //MARK: action
    func readData(key: String){
        self.isSearch = key.count > 0
        if self.isSearch{
            if let list = self.coinList {
                fiterData = list.filter({ coin in
                    let c = coin.name.uppercased()
                    let k = key.uppercased()
                    return c.contains(k)
                })
            }
        }
        self.tableView.reloadData()
    }
    
    
    //MARK: lazy
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 0
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(EXCoinSelectCell.self, forCellReuseIdentifier: cellid)
        return tableView
    }()

}
extension EXSelectCoinView: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearch {
            return self.fiterData.count
        }
        return self.coinList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath) as! EXCoinSelectCell
        cell.iconView.arrowImg.isHidden = true
        if self.isSearch {
            let coin = fiterData[indexPath.row]
            cell.coin = coin
            return cell
        }
        
        if let list = self.coinList{
            let coin = list[indexPath.row]
            cell.coin = coin
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isSearch{
            let coin = fiterData[indexPath.row]
            self.selectCoinBlock?(coin)
            return
        }
        
        if let list = self.coinList{
            let coin = list[indexPath.row]
            self.selectCoinBlock?(coin)
        }
       
    }
}

