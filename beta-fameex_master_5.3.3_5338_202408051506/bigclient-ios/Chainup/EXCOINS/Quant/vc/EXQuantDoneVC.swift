//
//  EXQuantDoneVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/5.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXQuantDoneVC: BaseVC {
    
    var sid:String
    var symbol:String

    var page:Int = 1
    var rowDatas:[EXOrderedGridListItem] = []
    var listItem:EXQuantStrategyListItem = EXQuantStrategyListItem()
    typealias QuantOrderCountChanged = (String) -> ()
    var orderCountChange : QuantOrderCountChanged?
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self 
        tableView.extRegistCell([EXQuantDoneCell.classForCoder()], ["EXQuantDoneCell"])
        return tableView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    required init(strategyID:String,symbol:String) {
        self.sid = strategyID
        self.symbol = symbol
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        handleRefresh()
        self.getCompletedOrders(page: self.page)
    }
    
    func handleRefresh(){
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else {return}
            mySelf.page = 1
            mySelf.getCompletedOrders(page: mySelf.page)
        })
        self.tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else {return}
            mySelf.page += 1
            mySelf.getCompletedOrders(page: mySelf.page)
        })   
    }
    
    func getCompletedOrders(page:Int) {
        appApi.rx.request(.quantGetFinishGridList(strategyId: sid, page: "\(page)"))
            .MJObjectMap(EXFinishedGridList.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                if model.list.count < 20 {
                    mySelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                }else {
                    mySelf.tableView.mj_footer.endRefreshing()
                }
                mySelf.orderCountChange?(model.count)
                mySelf.tableView.mj_header.endRefreshing()
                mySelf.handleOrderdItems(datas: model.list)
            }) { (error) in
                
        }.disposed(by: disposeBag)
    }
    
    func handleOrderdItems(datas:[EXOrderedGridListItem]) {
        for item in datas{
            item.strategyStatus = self.listItem.strategyStatus
        }
        if self.page == 1 {
            self.rowDatas = datas
        }else {
            self.rowDatas = self.rowDatas + datas
        }
        tableView.reloadData()
    }

}

extension EXQuantDoneVC:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let coinmap = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(self.symbol)
        let bg = EXQuantCellHeader.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 42))
        bg.profitL.text = "quant_profit_title".localized() + "(\(coinmap.marketName.aliasName()))"
        return bg
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if rowDatas.count > indexPath.row {
            let model = rowDatas[indexPath.row]
            return EXQuantDoneCell.getDoneCellHeightFor(model: model)
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = rowDatas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXQuantDoneCell") as! EXQuantDoneCell
        cell.bindListItem(model: model,expand: model.isExpand)
        cell.expandCallback = {[weak self] expand in
            self?.handleExpandCell(idx: indexPath.row, isExpand: expand)
        }
        return cell
    }
    
    func handleExpandCell(idx:Int,isExpand:Bool) {
        if rowDatas.count > idx {
            let model = rowDatas[idx]
            model.isExpand = isExpand
            tableView.reloadRows(at: [IndexPath.init(row: idx, section: 0)], with: .fade)
        }
    }
}

class EXQuantCellHeader:UIView {
    
    lazy var timeL:UILabel = {
        let l = UILabel.init()
        l.textColor = .Ex.text2
        l.font = .Ex.regular(12)
        l.text = "kline_text_dealTime".localized()
        return l
    }()
    
    lazy var profitL:UILabel = {
        let l = UILabel.init()
        l.textColor = .Ex.text2
        l.font = .Ex.regular(12)
        l.text = "quant_profit_title".localized()
        return l
    }()
    
    lazy var bottomLine:UIView = {
        let btn = UIView()
        btn.backgroundColor = .Ex.fill4
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(timeL)
        self.addSubview(profitL)
        self.addSubview(bottomLine)
        
        timeL.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT)
            make.centerY.equalToSuperview()
        }
        
        profitL.snp.makeConstraints { (make) in
            make.right.equalTo(-MARGIN_LEFT)
            make.centerY.equalToSuperview()
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
