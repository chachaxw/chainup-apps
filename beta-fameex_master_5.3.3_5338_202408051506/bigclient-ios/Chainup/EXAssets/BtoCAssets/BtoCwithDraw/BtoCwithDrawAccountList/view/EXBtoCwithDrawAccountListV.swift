//
//  EXBtoCwithDrawAccountListV.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXBtoCwithDrawAccountListV: UIView {
    
    typealias ClickCellBlock = (EXBtoCwithDrawAccountListModel) -> ()
    var clickCellBlock : ClickCellBlock?
    
    var entity = B2CCoinMapItem()
    
    var tableViewRowDatas : [EXBtoCwithDrawAccountListModel] = []
    
    var page = 1
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXBtoCwithDrawAccountListTC.classForCoder()], ["EXBtoCwithDrawAccountListTC"])
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.headRefresh()
        })
        
        tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.getData()
        })
    }
    
    func headRefresh(){
        self.page = 1
        self.getData()
    }
    
    //get data
    func getData(){
        appApi.rx.request(AppAPIEndPoint.getUserBankList(symbol: entity.symbol, page: "\(page)", pageSize: "20")).MJObjectMap(EXBtoCwithDrawAccountModel.self).subscribe(onSuccess: {[weak self] (arr) in
            guard let mySelf = self else{return}
            if mySelf.page == 1{
                mySelf.tableViewRowDatas.removeAll()
            }
            if arr.list.count > 0{
                for item in arr.list{
                    if let model = EXBtoCwithDrawAccountListModel.mj_object(withKeyValues: item){
                        mySelf.tableViewRowDatas.append(model)
                    }
                }
            }
            mySelf.tableView.reloadData()
            mySelf.page = mySelf.page + 1
            mySelf.endRefresh()
        }) {[weak self] (error) in
            self?.endRefresh()
        }.disposed(by: disposeBag)
    }
    
    func endRefresh(){
        tableView.mj_header.endRefreshing()
        tableView.mj_footer.endRefreshing()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXBtoCwithDrawAccountListV : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXBtoCwithDrawAccountListTC = tableView.dequeueReusableCell(withIdentifier: "EXBtoCwithDrawAccountListTC") as! EXBtoCwithDrawAccountListTC
        cell.setCell(entity)
        cell.clickEditorBtnBlock = {[weak self]entity in
            let vc = EXBtoCwithDrawAddAccountVC()
            vc.mainView.needContentBlock = {[weak self] in
                self?.headRefresh()
            }
            vc.mainView.symbol = entity.symbol
            vc.mainView.id = entity.id
            vc.type = .editor
            vc.setTitle("b2c_text_editWithdrawAccount".localized())
            self?.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = tableViewRowDatas[indexPath.row]
        self.clickCellBlock?(entity)
        self.yy_viewController?.navigationController?.popViewController(animated: true)
    }
    
}

