//
//  EXQuantHistoryListVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/5.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXQuantHistoryListVC: BaseVC,NavigationPlugin {
    
    var entity:CoinMapEntity = CoinMapEntity()
    var currentPage:Int = 1
    let pageSize: UInt8 = 20
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.tableview, presenter: self)
        nav.navtype = .list
        nav.isLastNavigationStyle = true
        nav.setTitle(title: "quant_entrust_historyList".localized())
        return nav
    }()
    
    var rowDatas:[EXQuantStrategyListItem] = []

    
    lazy var tableview : UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.extUseAutoLayout()
        v.separatorStyle = .none
        v.register(EXQuantOrderListCell.self, forCellReuseIdentifier: "EXQuantOrderListCell")

        v.backgroundColor = UIColor.ThemeView.bg
        v.emptyDataSetSource = self
        v.emptyDataSetDelegate = self
        v.delegate = self
        v.dataSource = self
        v.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let self else {return}
            self.currentPage = 1
            self.getStrategyList(page: self.currentPage)
        })
        v.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let self else {return}
            self.currentPage += 1
            self.getStrategyList(page: self.currentPage)
        })
        v.mj_footer.isHidden = true
        return v
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ThemeView.bg
        self.view.addSubview(tableview)
        self.view.addSubview(navigation)
  
        tableview.snp.makeConstraints { (make) in
            make.top.equalTo(navigation.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        getStrategyList(page: 1)
    }

    func getStrategyList(page:Int) {
        if XUserDefault.isOffLine() {
            return
        }
        
        if entity.name.isEmpty {
            return
        }
        appApi.rx.request(.quantGetStrategyList(symbol: entity.name,
                                                page: String(page),
                                                status: String(0),
                                                pageSize: String(pageSize)))
            .MJObjectMap(EXQuantStrategyList.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let self else{return}
                self.handleStrategyLists(results: model.strategyVoList)
            }, onFailure: { _ in
                
            }, onDisposed: { [weak self] in
                guard let self else { return }
                self.tableview.mj_header.endRefreshing()
                self.tableview.mj_footer.endRefreshing()
            }).disposed(by: disposeBag)
    }
    
    func handleStrategyLists(results:[EXQuantStrategyListItem]) {
        
        if results.count == 0 {
            
        }
        
        self.tableview.mj_footer.isHidden = false
        if results.count < self.pageSize {
            self.tableview.mj_footer.endRefreshingWithNoMoreData()
        }else {
            self.tableview.mj_footer.endRefreshing()
        }
        self.tableview.mj_header.endRefreshing()
        if results.count > 0{
            if self.currentPage == 1 {
                self.rowDatas = results
            }else {
                self.rowDatas = self.rowDatas + results
            }
        }else {
            self.rowDatas.removeAll()
        }
        tableview.reloadData()
    }
}

extension EXQuantHistoryListVC:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowDatas.count
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 356
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = rowDatas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXQuantOrderListCell") as! EXQuantOrderListCell
        cell.bindItems(item: model)
        cell.detailQuantCallback = {[weak self] sid in
            self?.toDetail(sid: sid,model: model)
        }
        cell.closeQuantCallback = {[weak self] sid in
            self?.closeQuant(sid: sid)
        }
        return cell
    }
    
    func closeQuant(sid:String) {
        if sid.isEmpty {
            return
        }
        
        let normalAlert = EXNormalAlert.init()
        normalAlert.configAlert(title: "", message: "quant_alert_stopGrid".localized())
        normalAlert.alertCallback = {[weak self] idx in
            if idx == 0 {
                self?.confirmClose(sid: sid)
            }
        }
        EXAlert.showAlert(alertView: normalAlert)
    }
    
    func confirmClose(sid:String) {
        appApi.rx.request(.quantStopStrategy(strategyId: sid))
            .MJObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let self else{return}
                self.reloadCurrents()
            }, onFailure: { _ in
                
            }).disposed(by: disposeBag)
    }
    
    func reloadCurrents() {
        self.tableview.mj_header.beginRefreshing()
    }
    
    func toDetail(sid:String,model:EXQuantStrategyListItem ) {
        if sid.isEmpty {
            return
        }
        let vc = EXQuantDetailContainer.init(strategyID: sid,listItem: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
