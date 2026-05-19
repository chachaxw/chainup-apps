//
//  EXOTCManagerView.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXOTCManagerView: UIView {
    
    var tableViewRowDatas : [EXOTCManagerAdListEntity] = []
    
    let statusArr = ["otc_text_adBuy".localized() , "otc_text_adSell".localized()]
    
    var page = 1
    let pageSize: UInt8 = 20
    
    var type = "buy"//Buy Sell
    
    var closeHide = "1"//If left blank, default to display all, 0 to display all, 1 to hide and close advertisements
    
    //Market price limit button
    lazy var statusBtn : EXDirectionSelector = {
        let v = EXDirectionSelector()
        v.extUseAutoLayout()
        v.layoutIfNeeded()
        v.iconSize = .init(width: 10, height: 10)
        v.titleLabel.font = .Ex.regular(14)
        v.titleLabel.textColor = .Ex.text1
        v.titleLabel.text = statusArr[0]
        v.addTarget(self, action: #selector(clickStatusBtn), for: .touchUpInside)
        return v
    }()
    
    //Hide Button
    lazy var hiddenBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.layoutIfNeeded()
        btn.setImage(UIImage.themeImageNamed(imageName: "agreement_confirm"), for: .normal)
        btn.setImage(UIImage.themeImageNamed(imageName: "agreement_noconfirm"), for: .selected)
        btn.setTitle(" " + "otc_text_adHidden".localized(), for: .normal)
        btn.setTitleColor(.Ex.text2, for: .normal)
        btn.titleLabel?.font = .Ex.regular(12)
        btn.extSetAddTarget(self, #selector(clickHiddenBtn))
        return btn
    }()
    
    lazy var tableView : UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.extUseAutoLayout()
        v.extSetTableView(self, self)
        v.extRegistCell([EXOTCManagerTC.classForCoder()], ["EXOTCManagerTC"])
        v.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.loadHeadDatas()
        })
        
        v.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.loadFootDatas()
        })
        v.mj_footer.isHidden = true
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView,statusBtn,hiddenBtn])
        tableView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
        statusBtn.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(15)
        }
        hiddenBtn.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.centerY.equalTo(statusBtn)
            make.width.equalTo(80)
            make.right.equalToSuperview().offset(-15)
        }
        hiddenBtn.textSizeFit()
        loadHeadDatas()
    }
    
    //Click on the status button
    @objc func clickStatusBtn(){
        let sheet = EXOldActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            mySelf.statusBtn.titleLabel.text = mySelf.statusArr[idx]
//            mySelf.statusBtn.checked(check: false)
            mySelf.type = idx == 0 ? "buy" : "sell"
            mySelf.loadHeadDatas()
        }
        sheet.actionCancelCallback = {[weak self]() in
            guard let mySelf = self else{return}
//            mySelf.statusBtn.checked(check: false)
        }
        var idx = 0
        for i in 0..<statusArr.count{
            if statusArr[i] == statusBtn.titleLabel.text{
                idx = i
                break
            }
        }
        sheet.configButtonTitles(buttons:  statusArr,selectedIdx: idx)
        EXAlert.showSheet(sheetView: sheet)
    }
    
    //Click on the hide button
    @objc func clickHiddenBtn(_ sender : UIButton){
        sender.isSelected = !sender.isSelected
        //
        if sender.isSelected == true{
            self.closeHide = "0"
        }else{
            self.closeHide = "1"
        }
        hiddenBtn.isUserInteractionEnabled = false
        loadHeadDatas()
    }
    
    //drop-down
    func loadHeadDatas(){
        self.page = 1
        self.getDatas()
    }
    
    //Pull up
    func loadFootDatas(){
        self.getDatas()
    }
    
    //get data
    func getDatas(){
        let uid = UserInfoEntity.sharedInstance().uid
        otcApi
            .rx
            .request(OTCAPIEndPoint.getPersonAds(uid: uid,
                                                      pageSize: String(pageSize),
                                                      page: String(page),
                                                      adType: self.type,
                                                      closeHide : self.closeHide))
        .MJObjectMap(EXOTCManagerEntity.self)
        .subscribe(onSuccess: {[weak self] (models) in
            guard let mySelf = self else{return}
            if mySelf.page == 1{
                mySelf.tableViewRowDatas.removeAll()
            }
            for entity in models.adList{
                mySelf.tableViewRowDatas.append(entity)
            }
            if mySelf.tableViewRowDatas.count == 0 {
                mySelf.tableView.mj_footer.isHidden = true
            } else {
                mySelf.tableView.mj_footer.isHidden = false
            }
            if models.adList.count < mySelf.pageSize {
                mySelf.tableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                mySelf.tableView.mj_footer.resetNoMoreData()
            }
            mySelf.tableView.reloadData()
            mySelf.page = mySelf.page + 1
        }, onFailure: { _ in
            
        }, onDisposed: { [weak self] in
            guard let self else { return }
            self.hiddenBtn.isUserInteractionEnabled = true
            if self.tableView.mj_header.isRefreshing {
                self.tableView.mj_header.endRefreshing()
            }
            if self.tableView.mj_footer.isRefreshing {
                self.tableView.mj_footer.endRefreshing()
            }
        }).disposed(by: disposeBag)
    }
    
    //close
    func endRefresh(){
        hiddenBtn.isUserInteractionEnabled = true
        self.tableView.mj_footer.endRefreshing()
        self.tableView.mj_header.endRefreshing()
    }
    
    //Enter the details page
    func gotoDetail(_ entity : EXOTCManagerAdListEntity){
        let vc = EXPublishAdvertiseMarkVc.init(nibName: "EXPublishAdvertiseMarkVc", bundle: nil)
        vc.advertisID = entity.advertId
        vc.block = {(type , id, isSell) in
            if type == .advertiseClose{
                for index in 0..<self.tableViewRowDatas.count{
                    let entity = self.tableViewRowDatas[index]
                    if entity.advertId == id{
                        self.tableViewRowDatas.remove(at: index)
                        self.tableView.reloadData()
                        break
                    }
                }
            }
        }
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXOTCManagerView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 208
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXOTCManagerTC = tableView.dequeueReusableCell(withIdentifier: "EXOTCManagerTC") as! EXOTCManagerTC
        cell.setCell(entity)
        cell.clickCheckBtnBlock = {[weak self](entity) in
            guard let mySelf = self else{return}
            mySelf.gotoDetail(entity)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = tableViewRowDatas[indexPath.row]
        self.gotoDetail(entity)
    }
}

