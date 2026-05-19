//
//  EXCoinSearchListVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXSearchSectionTitle: UIView {
    var titleLabel:UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func config() {
        self.backgroundColor = .Ex.special2
        titleLabel.font = UIFont.ThemeFont.HeadRegular
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
    }
    
}

class EXCoinSearchListVc: BaseVC,StoryBoardLoadable,NavigationPlugin {

    @IBOutlet var searchBarView: UIView!
    @IBOutlet var searchBarHeight: NSLayoutConstraint!
    @IBOutlet var searchTable: UITableView!
    @IBOutlet var cancelBtn: UIButton!
    var allCoins:[String:[CoinListEntity]] = [:]
    var alphaKeys:[String] = []
    
    var searchRstCoins:[String:[CoinListEntity]] = [:]
    var searchAlphas:[String] = []
    
    var searchKey:String = ""
    var searchbar:EXNaviSearchBar = EXNaviSearchBar()
    var subsetCoinAccountType:EXAccountType?
    var sourceType:EXCoinSearchSourceType = .sourceForAll
    typealias EntityCallback = (CoinListEntity) -> ()
    typealias B2CEntityCallback = (B2CCoinMapItem) -> ()
    var onEntityCallback:EntityCallback?
    var b2cOnEntityCallback:B2CEntityCallback?
    lazy var b2cDataArr : [B2CCoinMapItem] = {
        if self.sourceType == .sourceForAll {
           return EXB2CAccountListModel.shareInstance.getAllCoinMap()
        }else {
           return EXB2CAccountListModel.shareInstance.getAllCoinMap().filter({ (item) -> Bool in
                if self.sourceType == .sourceForWithdraw {
                         return item.withdrawOpen == "1"
                }else {
                        return item.depositOpen == "1"
                }
            })
        }
    }()
    var searchB2CRstCoins:[String:[B2CCoinMapItem]] = [:]
    var allB2CCoinsDictionary:[String:[B2CCoinMapItem]] = [:]
    
    var searchCoinVm:EXCoinSearchVm = EXCoinSearchVm()
    
    var needPush:Bool = false
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil,presenter: self)
        nav.backgroundColor = .Ex.special1
        return nav
    }()
    
    func configNavigation() {
        searchbar.cancelBtn.setTitleColor(.Ex.text2, for: .normal)
        searchbar.cancelBtn.addTarget(self, action: #selector(customBack), for: .touchUpInside)
        searchbar.searchField.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] text in
                self?.searchForKey(text)
            }).disposed(by: self.disposeBag)
        self.navigation.setCustomView(searchbar)
        
    }
    
    func searchForKey(_ key:String) {
        searchAlphas.removeAll()
        searchRstCoins.removeAll()
        searchKey = key
        if subsetCoinAccountType != .b2c {
            allCoins.forEach { turple in
                print("turple.=\(turple)")
                var containsArr:[CoinListEntity] = []
                let values = turple.value
                for item in values {
                    print("item.=\(item.name)")
                    var totalName = item.name
                    if !item.showName.isEmpty{
                        totalName = item.showName
                    }
                    if let _ = totalName.range(of: key, options:.caseInsensitive, range: nil, locale: nil) {
                        containsArr.append(item)
                    }
                }
                if containsArr.count > 0 {
                    searchAlphas.append(turple.key)
                    self.searchRstCoins[turple.key] = containsArr
                }
            }
        }else {
            allB2CCoinsDictionary.forEach { turple in
                var containsArr:[B2CCoinMapItem] = []
                let values = turple.value
                for item in values {
                    if let _ = item.symbol.range(of: key, options:.caseInsensitive, range: nil, locale: nil) {
                        containsArr.append(item)
                    }
                }
                if containsArr.count > 0 {
                    searchAlphas.append(turple.key)
                    self.searchB2CRstCoins[turple.key] = containsArr
                }
            }
        }
        self.searchTable.reloadData()
    }
    
    @objc func customBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarView.backgroundColor = UIColor.ThemeView.bg
        searchTable.sectionIndexBackgroundColor = UIColor.ThemeView.bg
        configNavigation()
        configTable()
        configDatasource()
        if isiPhoneX {
            searchBarHeight.constant = 88
        }else {
            searchBarHeight.constant = 64
        }
        
        searchTable.sectionIndexBackgroundColor = UIColor.clear
        searchTable.sectionIndexColor = .Ex.text2
        configHotCoin()
    }
    
    func configHotCoin() {
        _ = appApi.rx.request(.commonHotCoin).MJObjectMap(EXHotCoinModel.self).subscribe { [weak self] model in
            guard let self = `self` else { return }
            
            if model.hotCoin.isEmpty {
                return
            }
            
            let array = model.hotCoin.components(separatedBy: ",")
            if array.count > 0 {
                
                var temp: Array<String> = []
                
                for item in array {
                    temp.append(item.aliasName())
                }
                let hotCoinView = EXHotCoinView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height:EXHotCoinView.getHeight(data: array.count)))
                hotCoinView.selectedIndex = { [weak self] index in
                    let symbol = array[index]
                    var item :CoinListEntity = CoinListEntity()
                    item.name = symbol
//                    var b2cItem : B2CCoinMapItem = B2CCoinMapItem() //
                    self?.goNext(item: item, b2cItem: nil)
                    
//                    if let hasModel = EXAccountBalanceManager.manager.getCoinMapItem(symbol) {
//                        let charge = EXCoinRechageVc.instanceFromStoryboard(name: StoryBoardNameAsset)
//                        charge.symbol = hasModel.coinName
//                        self.navigationController?.pushViewController(charge, animated: true)
//                    }
                }
                hotCoinView.insert(labels: temp)
                self.searchTable.tableHeaderView = hotCoinView
                
//                let h = EXHotCoinView.stackView.height
//                hotCoinView.snp_makeConstraints { (maker) in
//                    maker.width.equalToSuperview()
//                    maker.height.equalTo(300)
//                }
//                self.searchTable.tableHeaderView?.layoutIfNeeded()
            }
        } onError: { _ in
            
        }
    }
    
    func configTable(){
        self.searchTable.register(UINib.init(nibName: "EXCoinSearchCell", bundle: nil), forCellReuseIdentifier: "EXCoinSearchCell")
        self.searchTable.snp.updateConstraints { make in
            make.top.equalTo(self.navigation.snp.bottom)
        }
    }
    
    func configDatasource() {
        if subsetCoinAccountType != .b2c {
            self.searchCoinVm.sourceType = self.sourceType
            allCoins = self.searchCoinVm.getCoinDataSource(self.subsetCoinAccountType ?? .coin)
            alphaKeys = Array(allCoins.keys).sorted(by: <)
            searchTable .reloadData()
        }else {
            var allB2CCoins:[String:[B2CCoinMapItem]] = [:]
            let sorted = b2cDataArr.sorted { $0.symbol < $1.symbol }
            var subsetCoins:[String] = []
            for item in b2cDataArr {
               subsetCoins.append(item.symbol)
            }
            for item in sorted {
                if subsetCoins.count > 0 {
                    if subsetCoins.contains(item.symbol) {
                        let alpha = String(item.symbol.prefix(1))
                        if var itemList = allB2CCoins[alpha] {
                            itemList.append(item)
                            allB2CCoins[alpha] = itemList
                        }else {
                            allB2CCoins[alpha] = [item]
                        }
                    }
                }else {
                    let alpha = String(item.symbol.prefix(1))
                    if var itemList = allB2CCoins[alpha] {
                        itemList.append(item)
                        allB2CCoins[alpha] = itemList
                    }else {
                        allB2CCoins[alpha] = [item]
                    }
                }
            }
            allB2CCoinsDictionary = allB2CCoins
            alphaKeys = Array(allB2CCoinsDictionary.keys).sorted(by: <)
            searchTable .reloadData()
        }
        
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension EXCoinSearchListVc : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchKey.isEmpty {
            return alphaKeys.count
        }else {
            return searchAlphas.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchKey.isEmpty {
            let key = alphaKeys[section]
            if subsetCoinAccountType != .b2c {
                let items = allCoins[key]!
                return items.count
            }else {
                let items = allB2CCoinsDictionary[key]!
                return items.count
            }
        }else {
            let key = searchAlphas[section]
            if subsetCoinAccountType != .b2c {
               let items = searchRstCoins[key]!
               return items.count
           }else {
               let items = searchB2CRstCoins[key]!
               return items.count
           }
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item :CoinListEntity = CoinListEntity()
        var b2cItem : B2CCoinMapItem = B2CCoinMapItem()
        if searchKey.isEmpty {
            let key = alphaKeys[indexPath.section]
            if subsetCoinAccountType != .b2c {
                item = allCoins[key]![indexPath.row]
            }else {
                b2cItem = allB2CCoinsDictionary[key]![indexPath.row]
            }
           
        }else {
            let key = searchAlphas[indexPath.section]
            if subsetCoinAccountType != .b2c {
                item =  searchRstCoins[key]![indexPath.row]
            }else {
                b2cItem = searchB2CRstCoins[key]![indexPath.row]
            }
        }
  
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXCoinSearchCell") as! EXCoinSearchCell
        if subsetCoinAccountType != .b2c {
            cell.coinName.text = item.name.aliasName()
        }else {
            cell.coinName.text = b2cItem.symbol.aliasName()
        }
        
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchKey.isEmpty {
            return alphaKeys
        }else {
            return searchAlphas
        }
    }
}

extension EXCoinSearchListVc : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = EXSearchSectionTitle.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 32))
        if searchKey.isEmpty {
            sectionHeader.titleLabel.text = alphaKeys[section]
        }else {
            sectionHeader.titleLabel.text = searchAlphas[section]
        }
        return sectionHeader
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item :CoinListEntity = CoinListEntity()
        var b2cItem : B2CCoinMapItem = B2CCoinMapItem()
        if searchKey.isEmpty {
            let key = alphaKeys[indexPath.section]
            if subsetCoinAccountType != .b2c {
                item = allCoins[key]![indexPath.row]
            }else {
                b2cItem = allB2CCoinsDictionary[key]![indexPath.row]
            }
           
        }else {
            let key = searchAlphas[indexPath.section]
            if subsetCoinAccountType != .b2c {
                item =  searchRstCoins[key]![indexPath.row]
            }else {
                b2cItem = searchB2CRstCoins[key]![indexPath.row]
            }
        }
        goNext(item: item, b2cItem: b2cItem)
//        if needPush,sourceType != .sourceForAll,subsetCoinAccountType != .b2c {
//            if let hasModel = EXAccountBalanceManager.manager.getCoinMapItem(item.name) {
//                if sourceType == .sourceForWithdraw {
//                    let withdraw = EXCoinWithdrawVc.instanceFromStoryboard(name: StoryBoardNameAsset)
//                    withdraw.coinModel = hasModel
//                    self.navigationController?.pushViewController(withdraw, animated: true)
//                }else if sourceType == .sourceForDeposit {
//                    let charge = EXCoinRechageVc.instanceFromStoryboard(name: StoryBoardNameAsset)
//                    charge.symbol = hasModel.coinName
//                    self.navigationController?.pushViewController(charge, animated: true)
//                }
//            }
//        }else if subsetCoinAccountType == .b2c {
//            if b2cOnEntityCallback != nil {
//                b2cOnEntityCallback?(b2cItem)
//                self.navigationController?.popViewController(animated: true)
//            }else {
//                if sourceType == .sourceForWithdraw {
//                    let vc = EXBtoCWithDrawVC()
//                    vc.entity = b2cItem
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }else {
//                    let vc = EXBtoCrechargeVC()
//                    vc.entity = b2cItem
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//        }else {
//            onEntityCallback?(item)
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    
    func goNext(item: CoinListEntity,b2cItem : B2CCoinMapItem?){
        if needPush,sourceType != .sourceForAll,subsetCoinAccountType != .b2c {
            if let hasModel = EXAccountBalanceManager.manager.getCoinMapItem(item.name) {
                if sourceType == .sourceForWithdraw {
                    let withdraw = EXCoinWithdrawVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                    withdraw.coinModel = hasModel
                    self.navigationController?.pushViewController(withdraw, animated: true)
                }else if sourceType == .sourceForDeposit {
                    let charge = EXCoinRechageVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                    charge.symbol = hasModel.coinName
                    self.navigationController?.pushViewController(charge, animated: true)
                }
            }
        }else if subsetCoinAccountType == .b2c {
            guard let b2cItem = b2cItem else{
                return
            }
            if b2cOnEntityCallback != nil {
                b2cOnEntityCallback?(b2cItem)
                self.navigationController?.popViewController(animated: true)
            }else {
                if sourceType == .sourceForWithdraw {
                    let vc = EXBtoCWithDrawVC()
                    vc.entity = b2cItem
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    let vc = EXBtoCrechargeVC()
                    vc.entity = b2cItem
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else {
            onEntityCallback?(item)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

class EXHotCoinModel: EXBaseModel {
    var hotCoin = ""
}
