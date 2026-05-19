//
//  EXReceivedRedPacketDetailView.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXReceivedRedPacketDetailView: UIView {
    
    var packetSn = ""
    {
        didSet{
            self.getData()
        }
    }
    
    var tableViewRowDatas : [EXRedPacketListDetailEntity] = []
    
    lazy var headView : EXReceivedRedPacketDetailHeadView = {
        let view = EXReceivedRedPacketDetailHeadView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 371))
        return view
    }()

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 75
        tableView.extSetTableView(self, self)
        tableView.tableHeaderView = headView
        tableView.bounces = false
        tableView.extRegistCell([EXReceivedRedPacketDetailTC.classForCoder()], ["EXReceivedRedPacketDetailTC"])
        tableView.rx.contentOffset.asObservable().subscribe({[weak self] (event) in
            guard let mySelf = self else{return}
            //do something
            guard let point = event.element else{return}
            let y = point.y
            if mySelf.headView.navtype == .list{
                if y > 0{
                    mySelf.headView.navtype = .listtitle
                }
            }else if mySelf.headView.navtype == .listtitle{
                if y < 0{
                    mySelf.headView.navtype = .list
                }
            }
        }).disposed(by: self.disposeBag)
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView])
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(NAV_TOP)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EXReceivedRedPacketDetailView{
    
    //get data
    func getData(){
        
        redPacketApi.rx.request(RedPacketAPIEndPoint.grantRecordInfo(packetSn: packetSn)).MJObjectMap(EXRedPacketDetailEntity.self).subscribe(onSuccess: {[weak self] (entity) in
            entity.dealcoinSymbol()
            self?.headView.setView(entity)
            self?.tableViewRowDatas = entity.mapList
            self?.tableView.reloadData()
        }) { (error) in
            
            }.disposed(by: disposeBag)
        
    }
    
}

extension EXReceivedRedPacketDetailView : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : EXReceivedRedPacketDetailTC = tableView.dequeueReusableCell(withIdentifier: "EXReceivedRedPacketDetailTC") as! EXReceivedRedPacketDetailTC
        cell.setCell(tableViewRowDatas[indexPath.row])
        return cell
    }
}


