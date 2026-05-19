//
//  EXRankingDealItem.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/3.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import DeepDiff
import EXKit

class EXRankingDealItem: UICollectionViewCell {
    var rankModel:EXRecommendList = EXRecommendList()
    var rankIdx:Int = 0
    
    lazy var rankTable : UITableView = {
        let view = UITableView.init(frame: .zero, style:.plain)
        view.backgroundColor = UIColor.ThemeView.bg
        view.contentInsetAdjustmentBehavior = .never
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        view.bounces = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        self.contentView.addSubview(rankTable)
        self.rankTable.register(EXHomeRankNewCell.self)
        self.rankTable.register(EXHomeDealCell.self)
//        self.rankTable.register(EXJapanRankCell.self)
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        rankTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCells(cellModel:EXRecommendList,rankIdx:Int) {
        self.rankIdx = rankIdx
        if self.rankModel.key.isEmpty || self.rankModel.list.count == 0 {
            self.rankModel = cellModel
            self.rankTable.reloadData()
        }else {
            let arrayNew = cellModel.list
            let arrayOrigin = rankModel.list
            let changes = diff(old: arrayOrigin, new: arrayNew)
            if changes.count > 0 {
                self.rankModel = cellModel
                self.rankTable.reloadData()
            }
            self.rankModel = cellModel
        }
    }
    
    func updateTicker(tick:EXHomeTicker,rowIdx:Int) {
        if let cell = self.rankTable.cellForRow(at: IndexPath.init(row: rowIdx, section: 0)) as? EXHomeRankNewCell {
            cell.bindCell(tick)
        }
    }
  
}



extension EXRankingDealItem : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return EXHomePageHeightHelper.rankingH
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.rankModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellItem = self.rankModel.list[indexPath.row]
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXHomeDealCell
        cell.bindCell(cellItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        
        let cellItem = self.rankModel.list[indexPath.row]
        let coinMapItem = EXAppMarketManager.sharedInstance.getDealEntity(cellItem.symbol)
        let vc = EXKlineDetailNewVC(entity: coinMapItem)
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if EXHomeViewModel.status() == .three {
//            return UIView()
//        }else {
            let view = EXHomeSectionView()
            view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 22)
            let model = EXHomeSectionEntity()
            model.leftname = "home_action_coinNameTitle".localized()
            model.middlename = "home_text_dealLatestPrice".localized() + "(" + EXAppMarketManager.sharedInstance.getFiatCoinSymbol() + ")"
            model.rightname = "home_text_deal24hour".localized() + "(BTC)"
            view.setView(model)
            return view
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if EXHomeViewModel.status() == .three {
//            return CGFloat.leastNonzeroMagnitude
//        }else {
            return 22
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}


