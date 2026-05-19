//
//  EXBtoCwithDrawRecordV.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXBtoCwithDrawRecordV: UIView {
    
    var type = "0"//0 recharge 1 withdrawal
    
    var tableViewRowDatas : [EXBtoCwithRecordListModel] = []
    
    lazy var headView : EXBtoCwithDrawRecordTV = {
        let view = EXBtoCwithDrawRecordTV.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 15))
        return view
    }()
    
    var symbol = ""//currency
    
    var page = 1

    lazy var tableView : UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style:UITableView.Style.grouped)
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXBtoCwithDrawRecordTC.classForCoder()], ["EXBtoCwithDrawRecordTC"])
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.tableHeaderView = headView
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page = 1
            mySelf.getData()
        })
        tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.getData()
        })
    }
    
    var filterData : [String : String] = [:]
    
    //get data
    func getData(){
        var startTime : String? = nil
        var endTime : String? = nil
        if let startTime1 = filterData["startTime"]{
            startTime = startTime1
        }
        if let endTime1 = filterData["endTime"]{
            endTime = endTime1
        }
        //Recharge
        if type == "0"{
            appApi.rx.request(AppAPIEndPoint.getFiatDepoistList(symbol: symbol, page: "\(page)", pageSize: "20", startTime: startTime,endTime:endTime)).MJObjectMap(EXBtoCwithRecordModel.self).subscribe(onSuccess: {[weak self] (model) in
                self?.setData(model)
            }) {[weak self] (error) in
                self?.endRefresh()
            }.disposed(by: disposeBag)
            //Withdrawal
        }else{
            appApi.rx.request(AppAPIEndPoint.getFiatWithdrawList(symbol: symbol, page: "\(page)", pageSize: "20", startTime: startTime,endTime:endTime)).MJObjectMap(EXBtoCwithRecordModel.self).subscribe(onSuccess: {[weak self] (model) in
                self?.setData(model)
            }) {[weak self] (error) in
                self?.endRefresh()
                }.disposed(by: disposeBag)
        }
    }
    
    func setData(_ model : EXBtoCwithRecordModel){
        if self.page == 1{
            self.tableViewRowDatas.removeAll()
        }
        if model.financeList.count > 0{
            for item in model.financeList{
                self.tableViewRowDatas.append(item)
            }
        }
        self.tableView.reloadData()
        self.page = self.page + 1
        self.endRefresh()
    }
    
    //End refresh
    func endRefresh(){
        self.tableView.mj_footer.endRefreshing()
        self.tableView.mj_header.endRefreshing()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXBtoCwithDrawRecordV : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXBtoCwithDrawRecordTC = tableView.dequeueReusableCell(withIdentifier: "EXBtoCwithDrawRecordTC") as! EXBtoCwithDrawRecordTC
        cell.setCell(entity)
        return cell
    }
    
}

