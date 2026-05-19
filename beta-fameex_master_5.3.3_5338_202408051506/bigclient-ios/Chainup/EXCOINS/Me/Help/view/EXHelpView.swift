//
//  EXHelpView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXHelpView: UIView {
    
    var tableViewSessionDatas : [EXHelpEntitySession] = []
    
    var page = 1
    
    lazy var helpBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.setTitle( "personal_text_onlineservice".localized(), for: .normal)
        btn.extSetAddTarget(self, #selector(clickhelpBtn))
        btn.isHidden = true
        return btn
    }()
    lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.extRegistCell([EXHelpTC.classForCoder()], ["EXHelpTC"])
        tableView.sectionFooterHeight = 0.1
        return tableView
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        addSubViews([tableView,helpBtn])
        var btnH:CGFloat = 0
        if EXAppConfigManager.sharedInstance.getOnlineServiceURL() != "" || EXAppConfigManager.sharedInstance.didOpenServiceOnline(){//If there is online customer service
            helpBtn.isHidden = false
            btnH = 44
        }
        helpBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-30 - TABBAR_BOTTOM)
            make.height.equalTo(btnH)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(helpBtn.snp.top)
        }
        
        getData()
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else {return}
            mySelf.getData()
        })
    }
    
    @objc func clickhelpBtn(){
        EXZenDeskManger.manger.goToNext()
    }
    
    func getData(){
        appApi.hideAutoLoading()
        appApi.rx.request(AppAPIEndPoint.getHelp).MJObjectMap(CommonAryModel.self).subscribe(onSuccess: {[weak self] (model) in
            
            guard let self else { return }
            if let arr = model.dictAry as? Array<[String : Any]>{
                self.tableViewSessionDatas.removeAll()
                for dict in arr{
                    let session = EXHelpEntitySession()
                    session.setEntityWithDict(dict)
                    self.tableViewSessionDatas.append(session)
                }
            }
            self.tableView.reloadData()
        }, onFailure: { _ in
            
        }, onDisposed: { [weak self] in
            self?.endRefresh()
        }).disposed(by: disposeBag)
    }
    
    //End refresh
    func endRefresh(){
        self.tableView.mj_header.endRefreshing()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

extension EXHelpView : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return tableViewSessionDatas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item  = tableViewSessionDatas[section]
        return item.expand ? item.cmsArticleList.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableViewSessionDatas[indexPath.section]
        let entity = row.cmsArticleList[indexPath.row]
        let cell : EXHelpTC = tableView.dequeueReusableCell(withIdentifier: "EXHelpTC") as! EXHelpTC
        cell.setCell(entity)
        cell.nameLabel.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(30)
        }
        cell.lineV.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(30)
        }
        cell.rightV.isHidden = true
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = tableViewSessionDatas[indexPath.section]
        let entity = row.cmsArticleList[indexPath.row]
        let vc = EXHelpDetailVC()
        vc.entity = entity
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell : EXHelpTC = tableView.dequeueReusableCell(withIdentifier: "EXHelpTC") as! EXHelpTC
        let rowinfo = tableViewSessionDatas[section]
        cell.nameLabel.text = rowinfo.articleTypeName
        cell.nameLabel.font = UIFont.ThemeFont.BodyMedium
        cell.nameLabel.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(15)
        }
        cell.lineV.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(15)
        }
        cell.rightV.isHidden = false
        cell.button.tag = section
        cell.button.addTarget(self, action: #selector(sessionClick), for: .touchUpInside)
        cell.button.isUserInteractionEnabled = true
        cell.rightV.transform = rowinfo.expand ? .init(rotationAngle: .pi * 0.5) : .identity
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -95.5
    }
    
    override func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    @objc func sessionClick(sender:UIButton){
        let tag: Int = sender.tag
        let info  = tableViewSessionDatas[tag]
        info.expand = !info.expand
        self.tableView.reloadData()
    }
    
}

