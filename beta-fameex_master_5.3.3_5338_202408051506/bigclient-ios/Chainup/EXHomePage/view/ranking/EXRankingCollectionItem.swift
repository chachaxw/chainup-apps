//
//  EXRankingCollectionItem.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/14.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import DeepDiff
import EXKit
import Swap
class EXRankingCollectionItem: UICollectionViewCell {
    
    var rankModel:EXRecommendList = EXRecommendList()
    var rankIdx:Int = 0
    
    lazy var rankTable : UITableView = {
        let view = UITableView.init(frame: .zero, style:.plain)
        view.backgroundColor = UIColor.ThemeView.bg
        view.contentInsetAdjustmentBehavior = .never
        view.extUseAutoLayout()
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
    
    func gotoContractDetailVC(row:Int) {
        let tickerModel = self.rankModel.list[row]
        var itemModel = tickerModel.itemModel
        if itemModel == nil {
            itemModel = tickerModel.mapToBtItemModel()
        }

        let vc = EXSwapKLineDetailVC()
        vc.itemModel = itemModel
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension EXRankingCollectionItem : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return EXHomePageHeightHelper.rankingH
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.rankModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellItem = self.rankModel.list[indexPath.row]
        if rankModel.key == "deal" {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXHomeDealCell
            cell.bindCell(cellItem)
            return cell
        }else {
//            if EXHomeViewModel.status() == .three {
//                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXJapanRankCell
//                cell.bindCell(cellItem)
//                return cell
//            }else {
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXHomeRankNewCell
                cell.bindCell(cellItem)
                return cell
//            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if EXHomeViewModel.isContractStatus() {
            gotoContractDetailVC(row:indexPath.row)
            return
        }
        let cellItem = self.rankModel.list[indexPath.row]
        var coinMapItem:CoinMapEntity?
        if self.rankModel.key == "deal" {
            coinMapItem = EXAppMarketManager.sharedInstance.getDealEntity(cellItem.symbol)
        }else {
            coinMapItem = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(cellItem.name)
        }
        
        let vc = EXKlineDetailNewVC(entity: coinMapItem!)
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = EXHomeSectionView()
        view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: EXHomePageHeightHelper.rankingHeader)
        let model = EXHomeSectionEntity()
        if self.rankModel.key == "deal" {
            model.leftname = "home_action_coinNameTitle".localized()
            model.middlename = "home_text_dealLatestPrice".localized() + "(" + EXAppMarketManager.sharedInstance.getFiatCoinSymbol() + ")"
            model.rightname = "home_text_deal24hour".localized() + "(BTC)"
        }else {
            model.leftname = "home_action_coinNameTitle".localized()
            model.middlename = "home_text_dealLatestPrice".localized()
            model.rightname = "common_text_priceLimit".localized()
        }
        view.setView(model)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return EXHomePageHeightHelper.rankingHeader
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
}
