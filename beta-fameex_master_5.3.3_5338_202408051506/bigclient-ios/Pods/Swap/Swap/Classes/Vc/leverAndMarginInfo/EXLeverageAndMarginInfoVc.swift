//
//  EXLeverageAndMarginInfoVc.swift
//  Swap
//
//  Created by cwd on 2023/3/31.
//

import UIKit
import EXKit
class EXLeverageAndMarginInfoVc: ListBaseViewController{

    
    var lastId:Int64  =  0
    var dataModel = EXLeverMarginData()
    var viewModel = EXSwapDataViewModel(){
        didSet{
            if !self.isViewLoaded {
                return //Not loaded, not requested
            }
            
            guard let contractid = viewModel.contractModel?.instrument_id else { return }
            //Same ID twice, no request
            if contractid ==  lastId{
                return
            }
            lastId = contractid
            requestInfo()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    //MARK: lazy
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 0
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.rowHeight = (206 + 16)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.tableHeaderView = header
        tableView.tableFooterView = footer
        tableView.register(cellType: EXLeverageAndMarginCell.self)
        return tableView
    }()
    lazy var header: UIView = {
       let v = UIView(frame: CGRect(x: 0, y: 0, width: Device_W, height: 5))
        v.backgroundColor = UIColor.ThemeView.bg
      return v
    }()
    lazy var footer: EXLeverageAndMarginFooter = {
       let v = EXLeverageAndMarginFooter(frame: CGRect(x: 0, y: 0, width: Device_W, height: 15 + 22))
      return v
    }()
}

extension EXLeverageAndMarginInfoVc: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.leverMarginInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EXLeverageAndMarginCell.self)
        cell.coin = dataModel.coinAlias
        cell.item = dataModel.leverMarginInfo[indexPath.row]
        return cell
        
    }
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension EXLeverageAndMarginInfoVc{
    func requestInfo(){
        EXContractNetwork.queryLeverMaginInfo(contractId: lastId) {  [weak self] model in
           // print("dataModel",model)
            self?.dataModel = model
            if (self?.dataModel.coinAlias.count ?? 0) < 1 {
                let contract = EXSwapPublicInfo.shared.getSwapInfo(self?.lastId ?? 0)
                self?.dataModel.coinAlias = contract?.marginCoin ?? ""
            }
            self?.footer.dataModel = model
            self?.tableView.reloadData()
        } failure: { _ in
            
        }
    }
}

