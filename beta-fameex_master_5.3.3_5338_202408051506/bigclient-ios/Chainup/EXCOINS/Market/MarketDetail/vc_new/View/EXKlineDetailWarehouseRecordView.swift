//
//  EXKlineDetailWarehouseRecordView.swift
//  Chainup
//
//  Created by youbin on 2023/6/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit
class EXKlineDetailWarehouseRecordView: EXTableView {
    
    var page: Int = 1
    var pageSize: Int = 20
    var recordList: [EXETFRecordListItem] = []
    var viewModel: EXKlineDetailNewViewModel?
    
    required init(viewModel: EXViewModelProtocol?) {
        self.viewModel = viewModel as? EXKlineDetailNewViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        
        tableView.register(EXKlineWarehouseRecordCell.self, forCellReuseIdentifier: NSStringFromClass(EXKlineWarehouseRecordCell.self))
        tableView.mj_footer = EXRefreshFooterView(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            self.page += 1
            self.updateRecordList()
        })
        
    
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}



extension EXKlineDetailWarehouseRecordView {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(EXKlineWarehouseRecordCell.self), for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let recordCell = cell as? EXKlineWarehouseRecordCell
        recordCell?.bindRecordModel(recordList[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 192
    }
    
}


extension EXKlineDetailWarehouseRecordView {
    
    func updateRecordList() {
        guard let _entity = self.viewModel?.entity else { return }
        
        appApi.rx.request(.etfActRecord(symbol: _entity.symbol,
                                        pageSize: self.pageSize,
                                        page: self.page))
            .MJObjectMap(EXETFRecordModel.self).subscribe(onSuccess: {[weak self] (model) in
                guard let `self` = self else { return }
                if model.etfPositionRecordList.count < self.pageSize {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                if self.page <= 1 {
                    self.recordList.removeAll()
                }
                self.recordList += model.etfPositionRecordList
                DispatchQueue.main.async {
                    self.tableView .reloadData()
                }
        }) { [weak self] (error) in
                guard let `self` = self else { return }
                self.tableView.mj_footer.endRefreshing()
        }.disposed(by: disposeBag)
    }
}


extension EXKlineDetailWarehouseRecordView{
   
 
}


extension EXKlineDetailWarehouseRecordView: JXSegmentedListContainerViewListDelegate {
   
    func listView() -> UIView {
        return self
    }
    
    func listWillAppear() {
        if recordList.count == 0 {
            self.page = 1
            self.updateRecordList()
        }
    }
}


