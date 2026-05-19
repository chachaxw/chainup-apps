
//
//  EXCurrentBorrowVc.swift
//  Chainup
//
//  Created by ljw on 2023/11/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit 

class EXCurrentBorrowVc: BaseVC,EXEmptyDataSetable {
    var page = 1
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topMarginCon: NSLayoutConstraint!
    var coinMapName = ""
    
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
        self.tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.register(UINib.init(nibName: "EXCoinBorrowRecordCell", bundle: nil), forCellReuseIdentifier: "EXCoinBorrowRecordCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = 200;
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page = 1
            mySelf.getListData()
        })
        getListData()
    }
}
extension EXCurrentBorrowVc {    
    func getListData() {
        appApi.rx.request(.leverCurrentBorrow(symbol:coinMapName.uppercased(),
                                              startTime: nil,
                                              endTime: nil,
                                              page:String(page),
                                              pageSize: "100"))
                      .MJObjectMap(EXCurrentBorrowModel.self)
                      .subscribe{[weak self] event in
                          switch event {
                          case .success(let model):
                          guard let mySelf = self else{return}
                          if mySelf.page == 1{
                              mySelf.modelsArr.removeAll()
                          }
                          mySelf.modelsArr += model.financeList
                          mySelf.tableView.reloadData()
                          mySelf.endRefresh()
                              break
                          case .failure(_):
                              break
                          }
                  }.disposed(by: self.disposeBag)
       }
    
    //End refresh
     func endRefresh(){
         self.tableView.mj_header.endRefreshing()
     }
}
extension EXCurrentBorrowVc : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = modelsArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXCoinBorrowRecordCell", for: indexPath) as! EXCoinBorrowRecordCell
        cell.type = .record
        cell.returnSuccessBlock = {[weak self] in
            guard let mySelf = self else {return}
            mySelf.tableView.mj_header.beginRefreshing()
        }
        cell.setModel(model: element)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Comment out because Android did not click on the event
//        let element = modelsArr[indexPath.row]
//        let vc = EXBorrowRecordDetailVc.init(nibName: "EXBorrowRecordDetailVc", bundle: nil)
//        vc.id = element.id
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
}

