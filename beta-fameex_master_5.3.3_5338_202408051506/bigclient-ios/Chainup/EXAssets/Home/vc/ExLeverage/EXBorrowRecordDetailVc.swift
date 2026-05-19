//
//  EXBorrowRecordDetailVc.swift
//  Chainup
//
//  Created by ljw on 2023/11/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXBorrowRecordDetailVc:  BaseVC,NavigationPlugin,EXEmptyDataSetable {
    @IBOutlet weak var topMarginCon: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    var id = ""//Transferred loan order ID
    var page = 1
    var modelsArr = [EXReturnInfoListModel]()
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.tableView, presenter: self)
        nav.isLastNavigationStyle = true
        return nav
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        handNavigationBar()
        bindCell()
       
        self.exEmptyDataSet(self.tableView, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:(CGFloat(-110)),
            ]
        })
    }
    func handNavigationBar() {
        self.navigation.setTitle(title:"leverage_borrowRecord_detail".localized())
        self.navigation.setdefaultType(type: .list)
    }
    func largeTitleValueChanged(height: CGFloat) {
        topMarginCon.constant = height
    }
    func bindCell()  {
        self.tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.register(UINib.init(nibName: "EXBorrowRecordDetailCell", bundle: nil), forCellReuseIdentifier: "EXBorrowRecordDetailCell")
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = 200;
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
               guard let mySelf = self else{return}
               mySelf.page = 1
               mySelf.loadData()
           })
           self.tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
               guard let mySelf = self else{return}
               mySelf.loadData()
           })
          loadData()
    }
}
extension EXBorrowRecordDetailVc {
    func loadData()  {
        appApi.rx.request(.leverReturnInfo(id: id, page: String(page), pageSize: nil))
                    .MJObjectMap(EXReturnInfoModel.self)
                    .subscribe{[weak self] event in
                        switch event {
                        case .success(let model):
                         guard let mySelf = self else{return}
                         if mySelf.page == 1{
                             mySelf.modelsArr.removeAll()
                         }
                         mySelf.modelsArr += model.financeList
                         mySelf.tableView.reloadData()
                         mySelf.page = mySelf.page + 1
                         mySelf.endRefresh()
                            break
                        case .failure(_):
                            break
                        }
                }.disposed(by: self.disposeBag)
    }
    //End refresh
    func endRefresh(){
        self.tableView.mj_footer.endRefreshing()
        self.tableView.mj_header.endRefreshing()
    }
}
extension EXBorrowRecordDetailVc:UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelsArr.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let element = modelsArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXBorrowRecordDetailCell", for: indexPath) as! EXBorrowRecordDetailCell
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
      
    }
}


