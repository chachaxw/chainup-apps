//
//  EXLeverageCoinSearchVc.swift
//  Chainup
//
//  Created by ljw on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

enum EXLeverageCoinSearchType {
    case none
    case transfer//Transfer
    case borrow //Lending
    case journal//Capital flow
}
class EXLeverageCoinSearchVc: BaseVC,EXEmptyDataSetable {
    lazy var dataArr : [CoinMapEntity] = {
       return EXAppMarketManager.sharedInstance.getAllLeverArray()
    }()
    var searchArr = [CoinMapEntity]()
    var type = EXLeverageCoinSearchType.none
    var isfromAsset: Bool = false
    typealias CallBackBlock = (_ str : String) -> ()
    var backCoinNameBlock : CallBackBlock?
    
    
    lazy var searchBar: EXSearchBarView = {
        let v = EXSearchBarView()
        v.placeHolder = "market_search_ex".localized()
        v.backgroundColor = .clear
        v.contentInsets = .zero
        v.searchContainerInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        v.searchContainer.backgroundColor = .Ex.fill3
        v.isShowCancel = true
        v.textDidChange = { [weak self] value in
            guard let self else { return }
            self.searchFor(key: value ?? "")
        }
        v.cancelCallback = { [weak self] in
            guard let self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        return v
    }()
    
    lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.backgroundColor = .clear
        v.separatorStyle = .none
        v.delegate = self
        v.dataSource = self
        v.register(UINib.init(nibName: "EXLeverageCoinSearchCell", bundle: nil), forCellReuseIdentifier: "EXLeverageCoinSearchCell")
        v.rowHeight = UITableView.automaticDimension;
        return v
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        self.exEmptyDataSet(self.tableView, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:(CGFloat(-110)),
            ]
        })
        if type == .journal {
            let allCoin = CoinMapEntity()
            allCoin.name = "leverage_all_coinMap".localized()
            dataArr.insert(allCoin, at: 0)
        }
        searchArr = dataArr
        tableView.reloadData()
    }

    func configUI()  {
        view.addSubViews([searchBar, tableView])
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(NAV_STATUS_HEIGHT + 6)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(NAV_SCREEN_HEIGHT)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func searchFor(key : String) {
        if key.isEmpty {
            searchArr = dataArr
            tableView.reloadData()
            return
        }
    
        self.searchArr.removeAll()
        tableView.reloadData()
        for item in dataArr {
            if item.name.lowercased().contains(key.lowercased()) {
                searchArr.append(item)
            }
        }
        tableView.reloadData()
    }
    

}
extension EXLeverageCoinSearchVc:UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArr.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXLeverageCoinSearchCell", for: indexPath) as! EXLeverageCoinSearchCell
        let model = searchArr[indexPath.row]
        cell.coinName.text = model.name.aliasCoinMapName()
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = searchArr[indexPath.row]
        if backCoinNameBlock != nil {
            backCoinNameBlock?(model.name)
            self.navigationController?.popViewController(animated: true)
        }else {
            if type == .borrow {//Lending
               let vc = EXLeverageReturnVc.init(nibName: "EXLeverageReturnVc", bundle: nil)
               vc.type = .leverageBorrow
                vc.isfromAsset = self.isfromAsset
               vc.currentCoinName = model.name.uppercased()
               self.navigationController?.pushViewController(vc, animated: true)
            }else if type == .transfer {//Transfer
        let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                   transfer.isPopRoot = true
                   transfer.coinMapName = model.name.uppercased()
                   transfer.isfromAsset = self.isfromAsset
                   transfer.transferFlow = .leverageToExchagne
                   transfer.onTrasferSuccessCallback = { [weak self] (ftype,ttype) in

                   }
                self.navigationController?.pushViewController(transfer, animated: true)
            }
           
        }
    }
}


