//
//  EXCoinBorrowRecordVc.swift
//  Chainup
//
//  Created by ljw on 2023/11/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXCoinBorrowRecordVc: BaseVC,NavigationPlugin,EXEmptyDataSetable {

    @IBOutlet weak var tableView: UITableView!
    var model = EXLeverageCoinMapItem()
    @IBOutlet weak var topMarginCon: NSLayoutConstraint!
    var borrowModel  = EXLeverCoinBorrowRecord()
    var totalBalanceSymbol = "BTC"
    var page = 1
    var modelsArr = [EXCurrentBorrowListModel]()
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.tableView, presenter: self)
        nav.isLastNavigationStyle = true
        return nav
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigation.setTitle(title:model.name.aliasCoinMapName())
        self.navigation.setdefaultType(type: .list)
        bindCell()
        self.exEmptyDataSet(self.tableView, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:(CGFloat(80)),
            ]
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        getListData()
    }
    func largeTitleValueChanged(height: CGFloat) {
        topMarginCon.constant = height
    }
    func bindCell()  {
        tableView.register(UINib.init(nibName: "EXCoinBorrowRecordCell", bundle: nil), forCellReuseIdentifier: "EXCoinBorrowRecordCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = 200;
        self.tableView.backgroundColor = UIColor.ThemeView.bg
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page = 1
            mySelf.getListData()
        })
    }
   

}
extension EXCoinBorrowRecordVc {
    
    func loadData() {
        let symbol = (model.name as NSString).replacingOccurrences(of: "/", with: "").uppercased()
        appApi.rx.request(.leverFinanceSymbolInfo(symbol:symbol))
            .MJObjectMap(EXLeverCoinBorrowRecord.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.borrowModel = model
                    self?.setupHeader()
                    break
                case .failure(_):
                    break
                }
        }.disposed(by: self.disposeBag)
    }
    func getListData() {
        let symbol = (model.name as NSString).replacingOccurrences(of: "/", with: "").uppercased()
        appApi.rx.request(.leverCurrentBorrow(symbol: symbol, startTime: nil, endTime: nil, page:String(page), pageSize: "100"))
                      .MJObjectMap(EXCurrentBorrowModel.self)
                      .subscribe{[weak self] event in
                          switch event {
                          case .success(let model):
                          guard let mySelf = self else{return}
                          if mySelf.page == 1{
                              mySelf.modelsArr.removeAll()
                          }
                          mySelf.modelsArr += model.financeList
                          mySelf.tableView.reloadData()
                          mySelf.endRefresh()
                              break
                          case .failure(_):
                              break
                          }
                  }.disposed(by: self.disposeBag)
       }
    
    //End refresh
     func endRefresh(){
         self.tableView.mj_header.endRefreshing()
     }
}
extension EXCoinBorrowRecordVc {
    func setupHeader() {
        let header = EXCoinBorrowRecordHeaderView.loadFromNib()
        header.model = borrowModel
        header.convertBorrowLab.text = getCaculatePrice()
        header.askBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let _ = self else {return}
            //Tooltip
              let alert = EXNormalAlert()
              alert.configSigleAlert(title: "common_text_tip".localized(), message: "leverage_risk_prompt".localized(), sigleBtnTitle: "alert_common_iknow".localized())
              //show
              EXAlert.showAlert(alertView: alert)
        }).disposed(by: self.disposeBag)
        let  tableHeaderView = UIView.init();
        tableHeaderView.addSubview(header)
        //This step must be placed here, otherwise there will be problems
        header.snp.makeConstraints { (make) in
            make.edges.equalTo(tableHeaderView);
        }
        let height = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        tableHeaderView.height = height
        self.tableView.tableHeaderView = tableHeaderView
    }
    
    func getCaculatePrice()->String {
        //Exchange rate of btc
        let currency = EXAppMarketManager.sharedInstance.getCoinExchangeRate(totalBalanceSymbol)
        let unit = currency.0
        let rate = currency.1
        let decimal = currency.2
        let balance = self.borrowModel.symbolBalance  as NSString
        if let rst =  balance.multiplying(by: rate, decimals: decimal) {
            return "assets_text_equivalence".localized() + unit + rst
        }else {
            return "assets_text_equivalence".localized() + unit + "0"
        }
    }
}
extension EXCoinBorrowRecordVc:UITableViewDataSource,UITableViewDelegate {
         func numberOfSections(in tableView: UITableView) -> Int {
                return 1
         }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return modelsArr.count
            
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let element = modelsArr[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXCoinBorrowRecordCell", for: indexPath) as! EXCoinBorrowRecordCell
            cell.type = .record
            cell.returnSuccessBlock = {[weak self] in
                guard let mySelf = self else {return}
                mySelf.loadData()
                mySelf.tableView.mj_header.beginRefreshing()
            }
            cell.setModel(model: element)
            return cell
        }
   
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 52
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let header = EXCoinBorrowRecordSectionHeaderView.loadFromNib()
            header.historyBtn.rx.tap.subscribe(onNext: {[weak self] in
                guard let mySelf = self else {return}
                let vc = EXLeverLoanListVC.init()
                vc.coinMapName = mySelf.borrowModel.symbol
                vc.currentIdx = 1
                mySelf.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: self.disposeBag)
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(currentApply))
            header.titleLab.addGestureRecognizer(tap)
            return header
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let element = modelsArr[indexPath.row]
            let vc = EXBorrowRecordDetailVc.init(nibName: "EXBorrowRecordDetailVc", bundle: nil)
            vc.id = element.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
}
extension EXCoinBorrowRecordVc {
    @objc func currentApply() {
       //Not useful at the moment
    }
}

