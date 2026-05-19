//
//  EXReceivedRedPacketListView.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXReceivedRedPacketListView: UIView {
    
    var page = 1
    
    var tableViewRowDatas : [EXReceivedRedPacketListDetailEntity] = []
    
    let receivedRedPacketListHeadView = EXReceivedRedPacketListHeadView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 72))
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.tableHeaderView = receivedRedPacketListHeadView
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXReceivedRedPacketListTC.classForCoder()], ["EXReceivedRedPacketListTC"])
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page = 1
            mySelf.getHeadData()
            mySelf.getListData()
        })
        self.tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.getListData()
        })
        self.getHeadData()
        self.getListData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXReceivedRedPacketListView{
    
    //Get header
    func getHeadData(){
        redPacketApi.rx.request(RedPacketAPIEndPoint.receiveRecord).MJObjectMap(EXReceivedRedPacketEntity.self).subscribe(onSuccess: {[weak self] (entity) in
            self?.receivedRedPacketListHeadView.setView(entity)
        }) { (error) in
            
            }.disposed(by: disposeBag)
    }
    
    //Obtain Table Data
    func getListData(){
        redPacketApi.rx.request(RedPacketAPIEndPoint.receiveRecordList(pageSize: "20", pageNum: "\(page)")).MJObjectMap(EXReceivedRedPacketListEntity.self).subscribe(onSuccess: {[weak self] (models) in
            guard let mySelf = self else{return}
            if mySelf.page == 1{
                mySelf.tableViewRowDatas.removeAll()
            }
            for entity in models.mapList{
                mySelf.tableViewRowDatas.append(entity)
            }
            mySelf.tableView.reloadData()
            mySelf.page = mySelf.page + 1
            mySelf.endRefresh()
        }) {[weak self] (erro) in
            self?.endRefresh()
            }.disposed(by: disposeBag)
    }
    
    //End refresh
    func endRefresh(){
        self.tableView.mj_footer.endRefreshing()
        self.tableView.mj_header.endRefreshing()
    }
    
}

extension EXReceivedRedPacketListView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : EXReceivedRedPacketListTC = tableView.dequeueReusableCell(withIdentifier: "EXReceivedRedPacketListTC") as! EXReceivedRedPacketListTC
        cell.setCell(tableViewRowDatas[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = tableViewRowDatas[indexPath.row]
        let vc = EXReceivedRedPacketDetailVC()
        vc.mainView.packetSn = entity.packetSn
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

