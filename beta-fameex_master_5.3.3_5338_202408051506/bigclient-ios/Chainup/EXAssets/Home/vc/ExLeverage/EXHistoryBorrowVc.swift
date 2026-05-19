//
//  EXHistoryBorrowVc.swift
//  Chainup
//
//  Created by ljw on 2023/11/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit 

class EXHistoryBorrowVc:  BaseVC,EXEmptyDataSetable {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topCon: NSLayoutConstraint!
    var page = 1
    let pageSize: UInt8 = 20
    var coinMapName = ""//Incoming
    var modelsArr = [EXCurrentBorrowListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindCell()
        self.exEmptyDataSet(self.tableView, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:(CGFloat(-110)),
            ]
        })
    }
    
    func bindCell()  {
        tableView.register(UINib.init(nibName: "EXCoinBorrowRecordCell", bundle: nil), forCellReuseIdentifier: "EXCoinBorrowRecordCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = 200;
        self.tableView.backgroundColor = UIColor.ThemeView.bg
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page = 1
            mySelf.getListData()
        })
        self.tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page += 1
            mySelf.getListData()
        })
        self.tableView.mj_footer.isHidden = true
        getListData()
    }
}
extension EXHistoryBorrowVc {
    //Obtain Table Data
    func getListData(){
        appApi.rx.request(.leverBorrowHistory(symbol: coinMapName.uppercased(),
                                              startTime: nil,
                                              endTime: nil,
                                              page: String(page),
                                              pageSize: String(pageSize)))
            .MJObjectMap(EXCurrentBorrowModel.self)
            .subscribe(onSuccess: { [weak self] model in
                guard let self else { return }
                if self.page == 1{
                    self.modelsArr.removeAll()
                }
                self.modelsArr += model.financeList
                self.tableView.mj_footer.isHidden = false
                if model.financeList.count < self.pageSize {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer.resetNoMoreData()
                }
                self.tableView.reloadData()
            }, onFailure: { _ in
                
            }, onDisposed: { [weak self] in
                guard let self else { return }
                self.endRefresh()
            }).disposed(by: self.disposeBag)
    }
    
    //End refresh
    func endRefresh(){
        if self.tableView.mj_header.isRefreshing {
            self.tableView.mj_header.endRefreshing()
        }
        if self.tableView.mj_footer.isRefreshing {
            self.tableView.mj_footer.endRefreshing()
        }
    }
    
}
extension EXHistoryBorrowVc:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = modelsArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXCoinBorrowRecordCell", for: indexPath) as! EXCoinBorrowRecordCell
        cell.type = .history
        cell.setModel(model: element)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = modelsArr[indexPath.row]
        let vc = EXBorrowRecordDetailVc.init(nibName: "EXBorrowRecordDetailVc", bundle: nil)
        vc.id = element.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

