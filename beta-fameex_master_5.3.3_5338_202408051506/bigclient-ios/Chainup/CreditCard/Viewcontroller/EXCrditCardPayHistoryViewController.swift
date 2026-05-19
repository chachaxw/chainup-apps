//
//  EXCrditCardPayListViewController.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/4/1.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXCrditCardPayHistoryViewController: NavCustomVC,EXEmptyDataSetable {
    var page = 1
    var vm = EXCreditCardViewModel()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.Ex.fill2
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 147
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.adjustBehaviorDisable()
        tableView.register(cellType: EXCrefitPayhistoryCell.self)
        return tableView
    }()
    
    override func setNavCustomV() {
        navtype = .listtitle
        self.lastVC = false
        navCustomView.backgroundColor =  UIColor.Ex.fill2
        self.setTitle("otc_text_myOrder".localized())
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
            make.left.right.equalToSuperview()
        }
        
        
        self.exEmptyDataSet(self.tableView, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:0,
                ]
        })
    
        configRefresh()
        self.tableView.mj_header.beginRefreshing()
        
    }
    func configRefresh(){
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page = 1
            mySelf.getData()
        })

        self.tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page += 1
            mySelf.getData()
        })
    }
    func getData(){
        vm.getPayHistory(page: String(page), size: "20", table: self.tableView)
    }
    
}

extension EXCrditCardPayHistoryViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.payHistoryData.orderList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EXCrefitPayhistoryCell.self)
        let item = self.vm.payHistoryData.orderList?[indexPath.row]
        cell.criditRecord = item
        return cell
        
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let data = dataList[indexPath.row]
//        return data.height
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

