//
//  EXSendOutRedPacketDetailView.swift
//  Chainup
//
//  Created by zewu wang on 2023/6/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

class EXSendOutRedPacketDetailView: UIView {

    typealias NoShowShareBlock = () -> ()
    var noShowShareBlock : NoShowShareBlock?
    
    var packetSn = ""//Red envelope ID
    {
        didSet{
            self.getData()
        }
    }
    
    var entity = EXRedPacketDetailEntity()
    
    var tableViewRowDatas : [EXRedPacketListDetailEntity] = []
    
    lazy var headView : EXSendOutRedPacketDetailHeadView = {
        let view = EXSendOutRedPacketDetailHeadView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 332))
        return view
    }()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.bounces = false
        tableView.estimatedRowHeight = 75
        tableView.extSetTableView(self, self)
        tableView.tableHeaderView = headView
        tableView.extRegistCell([EXSendOutRedPacketDetailTC.classForCoder()], ["EXSendOutRedPacketDetailTC"])
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
    
    lazy var copyBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.backgroundColor = UIColor.ThemeRedPacket.normalRed
        btn.extSetCornerRadius(4)
        btn.setTitle("redpacket_sendout_copyRedPacket".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.extSetAddTarget(self, #selector(clickCopyBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView,copyBtn])
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(NAV_TOP)
            make.bottom.equalTo(copyBtn.snp.top)
        }
        copyBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-30 - TABBAR_BOTTOM)
            make.height.equalTo(44)
        }
    }
    
    //If all are received, do not display sharing related buttons
    func noShowShare(){
        self.noShowShareBlock?()
        copyBtn.isHidden = true
        tableView.snp.remakeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(NAV_TOP)
        }
    }
    
    //Click on the share button
    @objc func clickCopyBtn(){
        if entity.url == ""{
            EXAlert.showFail(msg: "redpacket_sendout_cannotReplicated".localized())
            return
        }
        UIPasteboard.general.string = entity.url
        EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXSendOutRedPacketDetailView{
    
    //get data
    func getData(){
        
        redPacketApi.rx.request(RedPacketAPIEndPoint.grantRecordInfo(packetSn: packetSn)).MJObjectMap(EXRedPacketDetailEntity.self).subscribe(onSuccess: {[weak self] (entity) in
            entity.dealcoinSymbol()
            self?.entity = entity
            self?.headView.setView(entity)
            self?.tableViewRowDatas = entity.mapList
            self?.tableView.reloadData()
            if entity.status != "1"{//Collected or expired
                self?.noShowShare()
            }
        }) { (error) in
            
        }.disposed(by: disposeBag)
        
    }
    
}

extension EXSendOutRedPacketDetailView : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : EXSendOutRedPacketDetailTC = tableView.dequeueReusableCell(withIdentifier: "EXSendOutRedPacketDetailTC") as! EXSendOutRedPacketDetailTC
        cell.setCell(tableViewRowDatas[indexPath.row])
        return cell
    }
}

