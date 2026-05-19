//
//  EXRankingContainerCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/14.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import DeepDiff
import EXKit
import JXSegmentedView
import EXKit

class EXRankingContainerCell: EXHomeBaseCell {
    var needCallBack = true
    var lastOffset: CGFloat = 0
    var recieveDataCallBack: EXComVoidBlock?
    typealias RankContainerIndexChange = (Int,String)->()
    var onIndexChanges:RankContainerIndexChange?
    typealias ReloadTable = ()->()
    var onReloadTable:ReloadTable?
    var rankTableSize:CGSize = CGSize(width: SCREEN_WIDTH, height:EXHomePageHeightHelper.rankingH*10 + EXHomePageHeightHelper.rankingHeader)
    var rankLayouts:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var rankScrollIdx:Int = 0
    var titles:[String] = []
    var keys:[String] = []
    var rowDatas:[EXRecommendList] = []
    
    var jxSegmentedTitle:JXSegmentedView = JXSegmentedView()
    
    lazy var segmentedDataSource: EKMaskSegmentDatasource = {
        let source = EKMaskSegmentDatasource()
        return source
    }()
    
    lazy var indicatorLienView: EKMaskSegmentIndicator = {
        let view = EKMaskSegmentIndicator()
        return view
    }()
    
    var rankingIdentifier:[String:String] = [:]
    lazy var emptyNetwork : EXEmptyNetworkView = {
        let empty = EXEmptyNetworkView()
        self.addSubview(empty)
        empty.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        empty.refreshBtn.addTarget(self, action: #selector(refreshTable), for:.touchUpInside)
        return empty
    }()
    
    lazy var rankCollection : UICollectionView = {
        let collectionV = UICollectionView.init(frame: CGRect.init(x: 0, y: EXHomePageHeightHelper.rankingMenu, width: rankTableSize.width, height: rankTableSize.height) , collectionViewLayout: getCollectionLayout())
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.showsVerticalScrollIndicator = false
        collectionV.register(EXRankingCollectionItem.classForCoder(), forCellWithReuseIdentifier: "EXRankingCollectionItem")
        collectionV.register(EXRankingDealItem.classForCoder(), forCellWithReuseIdentifier: "EXRankingDealItem")
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.backgroundColor = UIColor.ThemeView.bg
        collectionV.isPagingEnabled = true
        collectionV.bounces = false
        collectionV.clipsToBounds = false
        if #available(iOS 11.0, *) {
            collectionV.contentInsetAdjustmentBehavior = .never
        }
        return collectionV
    }()
    
//    lazy var seperator:UIView = {
//        let v = UIView()
//        v.backgroundColor = UIColor.ThemeView.seperator
//        return v
//    }()
    
    func getCollectionLayout() -> UICollectionViewFlowLayout{
        let collectionLayout = UICollectionViewFlowLayout.init()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.minimumLineSpacing = 0
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.itemSize = CGSize.init(width: rankTableSize.width, height: rankTableSize.height)
        return collectionLayout
    }
    
    func resetTitleView() {
        self.jxSegmentedTitle.removeFromSuperview()
    
        self.jxSegmentedTitle = JXSegmentedView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: EXHomePageHeightHelper.rankingMenu))
        self.jxSegmentedTitle.delegate = self
        self.segmentedDataSource.titles = self.titles
        self.jxSegmentedTitle.dataSource = self.segmentedDataSource
        self.jxSegmentedTitle.indicators = [self.indicatorLienView]
        self.jxSegmentedTitle.backgroundColor = UIColor.ThemeView.bg
        self.contentView.addSubview(jxSegmentedTitle)
        
//        self.seperator.frame = CGRect(x: 0, y: 44, width: SCREEN_WIDTH, height: 0.5)
//        self.contentView.addSubview(seperator)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.perform(#selector(preformNetworkView), with: nil, afterDelay: 5)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        self.contentView.addSubview(self.rankCollection)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindRankings(datas:[EXRecommendList]) {
        if datas.count == 0 {
            return
        }
        self.emptyNetwork.isHidden = true
        self.recieveDataCallBack?()
        let newTitles = datas.map { return $0.title }
        let change = diff(old: self.titles, new: newTitles)
        self.titles = newTitles
        if change.count > 0 {
            resetTitleView()
        }
        self.keys = datas.map{ return $0.key }
        self.rowDatas = datas
        
        var maxHeight = EXHomePageHeightHelper.rankingH*10
        //Contract version, with several additional. saas versions, fixed at 10 heights
        if EXHomeViewModel.isContractStatus() {
            for item in datas {
                let heights = CGFloat(item.list.count) * EXHomePageHeightHelper.rankingH
                if heights > maxHeight {
                    maxHeight = heights
                }
            }
            self.rankTableSize = CGSize(width: SCREEN_WIDTH, height:CGFloat(maxHeight + EXHomePageHeightHelper.rankingHeader))
        }
        if self.rankCollection.superview == nil {
            self.contentView.addSubview(self.rankCollection)
        }
        self.rankCollection.reloadData()
    }
    
    func updateColumn(data:EXRecommendList,pageIdx:Int) {
        if rankScrollIdx == pageIdx {
            if let cell = self.rankCollection.cellForItem(at: IndexPath.init(row: self.rankScrollIdx, section: 0)) as? EXRankingCollectionItem {
                cell.updateCells(cellModel: data, rankIdx: pageIdx)
            }
        }
    }
    
    fileprivate func updateCurrentCell(closure: (_ currentCell:EXRankingCollectionItem)->()) {
        if let collectionCell = self.rankCollection.cellForItem(at: IndexPath.init(row: self.rankScrollIdx, section: 0)) as? EXRankingCollectionItem {
            closure(collectionCell)
        }
    }
    
    fileprivate func updateData(_ updateIdx: Int, _ rankModel: EXRecommendList) {
        
        let isRasing = (rankModel.key == "rasing") ? true : false
        
        updateCurrentCell { (collectionCell) in
            
            if rankModel.key == "hot" {
                collectionCell.rankTable.reloadData()
                return
            }
            let sortRst = rankModel.list.sorted { (a, b) -> Bool in
                if isRasing {
                    return a.rose1 > b.rose1
                }else {
                    return a.rose1 < b.rose1
                }
            }
            let changes = diff(old: rankModel.list, new: sortRst)
            if changes.count > 0 {
                var updateIdxs:[IndexPath] = []
                for change in changes {
                    if let moveItem = change.move {
                        let idxPath = IndexPath.init(row: moveItem.fromIndex, section: 0)
                        if !updateIdxs.contains(idxPath) {
                            updateIdxs.append(idxPath)
                        }
                    }
                }
                //Refresh all visible cells
                for idxpath  in updateIdxs {
                    let item = sortRst[idxpath.row]
                    item.app_serial_number = idxpath.row + 1
                    collectionCell.updateTicker(tick: item, rowIdx:idxpath.row)
                }
                rankModel.list = sortRst
            }else {
                collectionCell.updateTicker(tick: rankModel.list[updateIdx], rowIdx:updateIdx)
                rankModel.list = sortRst
            }
        }
    }
    
    func updateRankingItem(contract_id:Int64) {
        if self.rowDatas.count <= rankScrollIdx {
            return
        }
        let rankModel = self.rowDatas[rankScrollIdx]
        var updateIdx:Int = -1
        for (idx,tick) in rankModel.list.enumerated() {
            if tick.contract_id == contract_id {
                updateIdx = idx
                break
            }
        }
        if updateIdx >= 0 {
            
            updateCurrentCell { (currentCell) in
                
                currentCell.updateTicker(tick: rankModel.list[updateIdx], rowIdx: updateIdx)
            }
        }
    }
    
    func updateRankingItem(item:EXTickerModel,symbol:String) {
        if self.rowDatas.count <= rankScrollIdx {
            return
        }
        
        let rankModel = self.rowDatas[rankScrollIdx]
        if rankModel.key != "deal" {
            let symbols = rankModel.list.flatMap { (tick) -> [String] in
                return [tick.symbol]
            }
            if symbols.contains(symbol) {
                var updateIdx:Int = -1
                for (idx,tick) in rankModel.list.enumerated() {
                    if tick.symbol == symbol {
                        tick.updateModelWithTicker(ticker: item)
                        updateIdx = idx
                        break
                    }
                }
                
                if updateIdx >= 0 {
                    updateData(updateIdx, rankModel)
                }
            }
        }
    }
}



extension EXRankingContainerCell : UICollectionViewDelegate {
    
}

extension EXRankingContainerCell : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = self.rowDatas[indexPath.row]
        if item.key == "deal" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EXRankingDealItem", for: indexPath) as! EXRankingDealItem
            cell.updateCells(cellModel: item, rankIdx: indexPath.row)
            return cell
        }else {
            var cellIdentifier = ""
            if let idstr = rankingIdentifier["\(indexPath.row)"] {
                cellIdentifier = idstr
                //                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idstr, for: indexPath) as! EXRankingCollectionItem
                //                cell.updateCells(cellModel: item, rankIdx: indexPath.row)
                //                return cell
            }else {
                cellIdentifier = "\(indexPath.row)_" + "EXRankingCollectionItem"
                rankingIdentifier["\(indexPath.row)"] = cellIdentifier
                collectionView.register(EXRankingCollectionItem.classForCoder(), forCellWithReuseIdentifier: cellIdentifier)
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! EXRankingCollectionItem
            cell.updateCells(cellModel: item, rankIdx: indexPath.row)
            return cell
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        updateRankScrollIdx(page)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastOffset = scrollView.contentOffset.x
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.x
        let width = scrollView.frame.size.width
        var page = Int((scrollView.contentOffset.x + (0.7 * width)) / width)
        if offset - self.lastOffset > 0 {
//            print("向左滑")
            page = Int((scrollView.contentOffset.x + (0.33 * width)) / width)
        }else{
//            print("向右滑")
        }
        updateRankScrollIdx(page)
    }
    
    func updateRankScrollIdx(_ idx:Int) {
        if idx == self.rankScrollIdx {
            return
        }
        jxSegmentedTitle.selectItemAt(index: idx)
        self.rankScrollIdx = idx
        self.onIndexChanges?(idx,self.keys[idx])
    }
    
    func setSelectIndex(index: Int){
        needCallBack = false
        let idxPath = IndexPath.init(row: index, section: 0)
        self.rankCollection.scrollToItem(at:idxPath, at: .centeredHorizontally, animated: false)
        needCallBack = true
    }
}


extension EXRankingContainerCell : JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        let idxPath = IndexPath.init(row: index, section: 0)
        self.rankCollection.scrollToItem(at:idxPath, at: .centeredHorizontally, animated: false)
    }
}


extension EXRankingContainerCell:EXEmptyUIProtocal {
    func isEmptyData() -> Bool {
        return (self.rowDatas.count == 0)
    }
    
    func isLoadBeforeMarket() -> Bool {
        if let collectionCell = self.rankCollection.cellForItem(at: IndexPath.init(row: self.rankScrollIdx, section: 0)) as? EXRankingCollectionItem {
            if let tableCell = collectionCell.rankTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? EXHomeRankNewCell{
                if let name = tableCell.nameLabel.text,let price = tableCell.priceLabel.text {
                    return (name.count == 0 && price.count > 0)
                }else {
                    return false
                }
            }else {
                return false
            }
        }else {
            return false
        }
    }
    
    func isEmptyUI() -> Bool {
        if let collectionCell = self.rankCollection.cellForItem(at: IndexPath.init(row: self.rankScrollIdx, section: 0)) as? EXRankingCollectionItem {
            if collectionCell.rankTable.visibleCells.count == 0 {
                return true
            }else {
                return false
            }
        }
        return true
    }
}

extension EXRankingContainerCell {
    
    @objc func preformNetworkView(){
//        if self.titles.count == 0 {
//            self.emptyNetwork.isHidden = false
//        }else{
//            self.emptyNetwork.isHidden = true
//        }
        
    }
    @objc func refreshTable(){
        self.onReloadTable?()
    }
}

