//
//  EXEditFavoritesVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/28.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import TableViewDragger
import RxSwift
import JXSegmentedView
import EXKit
import Swap
///Edit Selection
class EXEditFavoritesVC: BaseVC {
    let editBarHeight:CGFloat = 14
    var userSymbol:UserSymbolsVM = UserSymbolsVM()
    var marketCoins:[CoinMapEntity] = []
    var dragger: TableViewDragger!
    var checkedSymbols:[String] = []
    let symbolBehavior : BehaviorSubject<[String]> = BehaviorSubject.init(value: [])
    var oldCollections:String = ""
    var contractUserSymbol:EXContractUserVm = EXContractUserVm()

    var contractType = false //Is it a contract editor
//    internal lazy var navigation : EXNavigation = {
//        let nav =  EXNavigation.init(affectScroll: nil, presenter: self,customHandleBack: true)
//        return nav
//    }()
    
    lazy var marketListTable : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.register(EXEditFavoriteCell.classForCoder(), forCellReuseIdentifier: "EXEditFavoriteCell")
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var editFooter : EXEditFavoritesFooter = {
        let footer = EXEditFavoritesFooter()
        return footer
    }()
    
    
    func prepareFavorites() {
        if contractType {
            let historyCollection = EXStoreData.getCollectionCoinMap()
            oldCollections = historyCollection.joined(separator: ",")
            let swapItems = contractUserSymbol.getLocalFavoriteList()
            if swapItems != nil {
                self.marketCoins = swapItems!.map({ item -> CoinMapEntity in
                    let coin = CoinMapEntity()
                    coin.name = item.ex_contractInfo?.showName() ?? ""
                    coin.symbol = String(item.instrument_id)
                    return coin
                })
            }else{
                self.marketCoins.removeAll()
            }
        }else{
            let historyCollection = XUserDefault.getCollectionCoinMap()
            oldCollections = historyCollection.joined(separator: ",")
            self.marketCoins = EXAppMarketManager.sharedInstance.getCollectionCoinMapList(historyCollection)
        }
        
        self.marketListTable.reloadData()
        if marketCoins.count == 0,editFooter.selectedAllBtn.isChecked {
            editFooter.selectedAllBtn.checked(check: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareFavorites()
    }
    
    func checkFavoritesChangesOrNot() {
        //Every time you return to the current collection view, try synchronizing the collection currency
        let tmpFavorites = XUserDefault.getCollectionCoinMap().joined(separator: ",")
        if tmpFavorites != oldCollections {
            prepareFavorites()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFavorites()
        self.view.addSubview(marketListTable)
        self.view.addSubview(editFooter)
        dragger = TableViewDragger(tableView: marketListTable)
        dragger.availableHorizontalScroll = true
        dragger.dataSource = self
        dragger.delegate = self
        dragger.availableHorizontalScroll = false
        
        marketListTable.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(editFooter.snp.top)
        }
        editFooter.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(TABBAR_BOTTOM + 46)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        editFooter.deleteBtn.addTarget(self, action: #selector(deleteFavorites), for: .touchUpInside)
        
        symbolBehavior
            .asObserver()
            .map({ [weak self] symbols -> Bool in
                self?.updateDeleteTitle()
                return symbols.count > 0
            })
            .bind(to: self.editFooter.deleteBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        symbolBehavior
            .asObserver()
            .map({ [weak self] symbols -> Bool in
                if symbols.count > 0 {
                    let all  = symbols.count == self?.marketCoins.count
                    self?.updateDeleteTitle()
                    self?.editFooter.selectedAllBtn.updateTilteColor(select: all)
                    return all
                }
                self?.editFooter.selectedAllBtn.updateTilteColor(select: false)
                return false
            })
            .bind(to: self.editFooter.selectedAllBtn.rx.isSelected)
            .disposed(by: self.disposeBag)
        
        editFooter.selectedAllBtn.rx.checkState.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] checked in
                guard let `self` = self else {return}
                if checked {
                    self.check(symbol: "", isChecked: checked, selectedAll: true)
                }else {
                    if self.checkedSymbols.count == self.marketCoins.count {
                        self.check(symbol: "", isChecked: checked, selectedAll: true)
                    }
                }
            }).disposed(by: self.disposeBag)
    }
    
}

extension EXEditFavoritesVC {
    @objc func deleteFavorites() {
        let normalAlert = EXCommonAlert()
        normalAlert.configAlert(tipImage: nil, title: "market_tip_confirmDeleteCollection".localized(), message: nil, cancelBtnTitle: "common_text_btnCancel".localized(), sureBtnTitle: "common_text_btnConfirm".localized(), btnLayoutStyle: .horizontal) { [weak self] type in
            guard let weakSelf = self else { return }
            if type == .sure{
                weakSelf.confirmUpdateAll(true)
            }
        }
        EXKitAlert.showAlert(alertView: normalAlert)
    }
    
    func confirmUpdateAll(_ isDelete:Bool) {
        var resultsAry:[CoinMapEntity] = []
        if isDelete {
            resultsAry = marketCoins.filter { !checkedSymbols.contains($0.symbol) }
        }else {
            resultsAry = marketCoins
        }
        
        if contractType{
            let ids = resultsAry.map{$0.symbol}
            contractUserSymbol.handleCoFavorite(actionType: .other, swapIds: ids, callback:{ [weak self] success in
                if success,isDelete {
                    self?.checkedSymbols.removeAll()
                    self?.prepareFavorites()
                    self?.updateDeleteTitle()
                }
            })
        }else{
            
            userSymbol.handleFavorite(actionType: .other,
                                      coinMaps: resultsAry,
                                      callback: {[weak self] success in
                if success,isDelete {
                    self?.checkedSymbols.removeAll()
                    self?.prepareFavorites()
                    self?.updateDeleteTitle()
                }
                
            })
        }
    }
}


extension EXEditFavoritesVC  {
    
    override func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -161
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let text = "common_tip_nodata".localized()
        let font = UIFont.ThemeFont.SecondaryRegular
        let icon = EXKitBundle.svgImage(named: "public_increase")
        let view = EXFavoritesEmptyView.init(frame: .zero)
        view.iconImgView.image = EXKitBundle.svgImage(named: "public_nocontentyet")
        view.actionBtn.setTitle(text, for: .normal)
        view.actionBtn.titleLabel?.font = font
        view.actionBtn.setTitleColor(UIColor.ThemeLabel.colorDark, for: .normal)
//        
//        view.actionBtn.titleLabel?.attributedText = NSMutableAttributedString().add(string: "common_tip_nodata".localized(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryRegular , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorDark])
        
        
//        view.actionBtn.addTarget(self, action: #selector(beginSearch), for: .touchUpInside)
//        view.actionBtn.setImage(icon, for: .normal)
//        view.actionBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        let heightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 116)
        view.addConstraints([heightConstraint])
        return view
    }
    
//    @objc func beginSearch() {
//        EXNavigationHandler.sharedHandler.commonJumpCommand(EXRouterActionKey.appSearch.rawValue)
//    }
}


extension EXEditFavoritesVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marketCoins.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if marketCoins.count > 0 {
            let header = EXEditFavoriteSectionHeader.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: editBarHeight))
            return header
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return marketCoins.count > 0 ? editBarHeight + 14 : CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = marketCoins[indexPath.row]
        let cell : EXEditFavoriteCell = tableView.dequeueReusableCell(withIdentifier: "EXEditFavoriteCell") as! EXEditFavoriteCell
        cell.updateCoinName(name: entity.name, isChecked: checkedSymbols.contains(entity.symbol))
        cell.editCheckBox.checkCallback = {[weak self] isChecked in
            self?.check(symbol: entity.symbol, isChecked: isChecked)
        }
        cell.onTopActionCallback = {[weak self] in
            self?.handleCellTopAction(symbol: entity.symbol)
        }
        return cell
    }
    
    func check(symbol:String,isChecked:Bool,selectedAll:Bool = false) {
        if selectedAll {
           
            if isChecked {
                checkedSymbols = marketCoins.map({return $0.symbol})
            }else {
                checkedSymbols = []
            }
            self.editFooter.selectedAllBtn.updateTilteColor(select: isChecked)
            self.marketListTable.reloadData()
        }else {
            if isChecked {
                checkedSymbols.append(symbol)
            }else {
                if let index = checkedSymbols.firstIndex(of: symbol) {
                    checkedSymbols.remove(at: index)
                }
            }
        }
        symbolBehavior.onNext(checkedSymbols)
    }
    
    func updateDeleteTitle(){
        var btntitle = "address_action_delete".localized()
        if checkedSymbols.count > 0 {
             btntitle += "(\(checkedSymbols.count))"
        } else {
            self.editFooter.deleteBtn.isEnabled = false
        }
        self.editFooter.deleteBtn.setTitle(btntitle, for: .normal)
    }
    func handleCellTopAction(symbol:String) {
        let origin = marketCoins.map({return $0.symbol})
        if let moveRow = origin.firstIndex(of: symbol) {
            self.moveRow(fromIdx: IndexPath.init(row: moveRow, section: 0), toIdx: IndexPath.init(row: 0, section: 0))
            confirmUpdateAll(false)
        }
    }

//    func getCustomCollections() -> [String] {
//        return XUserDefault.getCollectionCoinMap()
//    }
}

extension EXEditFavoritesVC: TableViewDraggerDataSource, TableViewDraggerDelegate {
    
    func dragger(_ dragger: TableViewDragger, moveDraggingAt indexPath: IndexPath, newIndexPath: IndexPath) -> Bool {
        self.moveRow(fromIdx: indexPath, toIdx: newIndexPath)
        return true
    }
    
    func dragger(_ dragger: TableViewDragger, didEndDraggingAt indexPath: IndexPath) {
           confirmUpdateAll(false)
       
    }
    
    func moveRow(fromIdx:IndexPath,toIdx:IndexPath) {
        let item = marketCoins[fromIdx.row]
        marketCoins.remove(at: fromIdx.row)
        marketCoins.insert(item, at: toIdx.row)
        self.marketListTable.moveRow(at: fromIdx, to: toIdx)
    }
}

extension EXEditFavoritesVC: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}

