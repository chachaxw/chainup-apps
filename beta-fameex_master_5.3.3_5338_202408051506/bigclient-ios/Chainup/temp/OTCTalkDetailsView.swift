//
//  OTCTalkDetailsView.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/17.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit

class OTCTalkDetailsView: UIView {
    
    var detailEntity = EXOTCOrderDetailModel()
    
    var type = OTCTalkType.user

    var tableViewRowDatas : [OTCTalkEntity] = []//User Chat
    
    var serviceTableViewRowDatas : [OTCServiceEntity] = []//Appeal Chat
    
    lazy var tableView : UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.extUseAutoLayout()
        tableView.bounces = false
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([OTCMyTalkTC.classForCoder(),OTCOtherTalkTC.classForCoder()], ["OTCMyTalkTC","OTCOtherTalkTC"])
        tableView.backgroundColor = UIColor.ThemeNav.bg
        return tableView
    }()
    
    lazy var talkInputView : OTCTalkInputView = {
        let view = OTCTalkInputView()
        view.extUseAutoLayout()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubViews([tableView,talkInputView])
        tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(talkInputView.snp.top)
        }
        talkInputView.snp.makeConstraints { (make) in
            make.height.equalTo(54)
            make.bottom.left.right.equalToSuperview()
        }
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).takeUntil(self.rx.deallocated).subscribe {[weak self] (event) in
            guard let mySelf = self else{return}
            if let height = (event.element?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height{
                mySelf.talkInputView.snp.remakeConstraints({ (make) in
                    make.height.equalTo(54)
                    make.bottom.equalToSuperview().offset(-(height))
                    make.left.right.equalToSuperview()
                })
            }
        }.disposed(by: disposeBag)//Keyboard Bounce
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).takeUntil(self.rx.deallocated).subscribe {[weak self] (event) in
            guard let mySelf = self else{return}
                mySelf.talkInputView.snp.remakeConstraints({ (make) in
                    make.height.equalTo(54)
                    make.left.right.equalToSuperview()
                    make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
                })
            }.disposed(by: disposeBag)//Keyboard down
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension OTCTalkDetailsView : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = OTCTalkPromptView()
        view.type = type
        view.setView(detailEntity)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == .user{
            return tableViewRowDatas.count
        }else{
            return serviceTableViewRowDatas.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if type == .user{
            return tableViewRowDatas[indexPath.row].cellHeight
        }else{
            return serviceTableViewRowDatas[indexPath.row].cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if type == .user{
            let entity = tableViewRowDatas[indexPath.row]
            if entity.from == UserInfoEntity.sharedInstance().uid{
                let cell : OTCMyTalkTC = tableView.dequeueReusableCell(withIdentifier: "OTCMyTalkTC") as! OTCMyTalkTC
                cell.setCell(entity,detailEntity: detailEntity)
                return cell
            }else if entity.to == UserInfoEntity.sharedInstance().uid{
                let cell : OTCOtherTalkTC = tableView.dequeueReusableCell(withIdentifier: "OTCOtherTalkTC") as! OTCOtherTalkTC
                cell.setCell(entity,detailEntity: detailEntity)
                return cell
            }
        }else{
            let entity = serviceTableViewRowDatas[indexPath.row]
            if entity.userType == "2"{
                let cell : OTCMyTalkTC = tableView.dequeueReusableCell(withIdentifier: "OTCMyTalkTC") as! OTCMyTalkTC
                if entity == serviceTableViewRowDatas.last{
                    NSLog("12323123 \(entity)")
                }
                cell.setCellWithOTC(entity, detailEntity: detailEntity)
                return cell
            }else{
                let cell : OTCOtherTalkTC = tableView.dequeueReusableCell(withIdentifier: "OTCOtherTalkTC") as! OTCOtherTalkTC
                cell.setCellWithOTC(entity,detailEntity: detailEntity)
                return cell
            }
        }
        return UITableViewCell()
    }
    
}


