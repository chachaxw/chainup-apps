//
//  EXAnnouncementView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXAnnouncementView: UIView {
    
    var tableViewRowDatas : [EXAnnouncementEntity] = []
    
    var page = 1
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXAnnouncementTC.classForCoder()], ["EXAnnouncementTC"])
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        getData()
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            self?.reloadData()
        })
        self.tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            self?.getData()
        })
    }
    
    func reloadData(){
        page = 1
        getData()
    }
    
    func getData(){
        appApi.rx.request(AppAPIEndPoint.getNotice(page: "\(page)", pagesize: "1000")).MJObjectMap(EXAnnouncementNoticeInfoList.self).subscribe(onSuccess: {[weak self] (list) in
            guard let mySelf = self else{return}
            if mySelf.page == 1{
                mySelf.tableViewRowDatas.removeAll()
            }
            for entity in list.noticeInfoList{
                mySelf.tableViewRowDatas.append(entity)
            }
            mySelf.tableView.reloadData()
            mySelf.page = mySelf.page + 1
            mySelf.endRefresh()
        }) {[weak self] (error) in
            self?.endRefresh()
        }.disposed(by: self.disposeBag)
    }
    
    func endRefresh(){
        self.tableView.mj_header.endRefreshing()
        self.tableView.mj_footer.endRefreshing()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXAnnouncementView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXAnnouncementTC = tableView.dequeueReusableCell(withIdentifier: "EXAnnouncementTC") as! EXAnnouncementTC
        cell.setCell(entity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EXAnnouncementDetailsVC()
        vc.entity = tableViewRowDatas[indexPath.row]
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
