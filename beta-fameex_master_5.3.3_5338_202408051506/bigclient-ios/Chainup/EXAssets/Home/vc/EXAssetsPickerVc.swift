//
//  EXAssetsPickerVc.swift
//  Chainup
//
//  Created by wangdong on 2023/9/11.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit 

class EXAssetsPickerVc: BaseVC, NavigationPlugin, EXEmptyDataSetable {
    
    var tableView: UITableView = {
        let view = UITableView.init(frame: CGRect.zero, style: .plain)
        view.separatorStyle = .none
        return view
    }()
    
    var searchbar:EXNaviSearchBar = EXNaviSearchBar()
    var source: [EXAccountCoinMapItem] = []
    var hasAssetsSource: [EXAccountCoinMapItem] = []
    var searchRstCoins:[EXAccountCoinMapItem] = []
    var totalBalanceSymbol: String?
    var searchKey:String = ""
    
    var didSelectedCoin: ((EXAccountCoinMapItem) -> ())?
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil,presenter: self)
        return nav
    }()
    
    convenience init(source: [EXAccountCoinMapItem]) {
        self.init()
        self.source = source
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        hasAssetsSource = source.filter({ (item) -> Bool in
            return (item.normal_balance as NSString).isBig("0") && item.withdrawOpen == "1"
        })

        tableView.backgroundColor = UIColor.ThemeView.bg
        
        configNavigation()
        
        tableView.register(UINib.init(nibName: "EXAssetsPickerCell", bundle: nil), forCellReuseIdentifier: "EXAssetsPickerCell")
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(navigation.snp.bottom)
            maker.left.right.bottom.equalToSuperview()
        }
        
        tableView.backgroundView?.backgroundColor = UIColor.clear
        
        self.exEmptyDataSet(self.tableView, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:(CGFloat(-110)),
            ]
        })
        
    }
    
    func configNavigation() {
        searchbar.cancelBtn.addTarget(self, action: #selector(customBack), for: .touchUpInside)
        searchbar.searchField.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] text in
                self?.searchForKey(text)
            }).disposed(by: self.disposeBag)
        self.navigation.setCustomView(searchbar)
    }
    
    @objc func customBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchForKey(_ key:String) {
        searchRstCoins.removeAll()
        searchKey = key
        source.forEach { item in
            if let _ = item.coinName.aliasName().range(of: key, options:.caseInsensitive, range: nil, locale: nil) {
                searchRstCoins.append(item)
            }
        }
        self.tableView.reloadData()
    }
    
}

extension EXAssetsPickerVc: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.zero)
        view.backgroundColor = UIColor.ThemeView.bg
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(label)
        label.text = "assets_digital_assets".localized()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(15)
            maker.left.equalToSuperview().offset(15)
        }
        view.clipsToBounds = true
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var model: EXAccountCoinMapItem?
        if searchKey.isEmpty {
            model = hasAssetsSource[indexPath.row]
        }
        else {
            model = searchRstCoins[indexPath.row]
        }
        
        if let _ = model, let hasModel = EXAccountBalanceManager.manager.getCoinMapItem(model!.coinName) {
            
            if let didSelectedCoinHandler = didSelectedCoin {
                didSelectedCoinHandler(hasModel)
                navigationController?.popViewController(animated: true)
            }
            else {
                let withdraw = EXCoinWithdrawVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                withdraw.coinModel = hasModel
                withdraw.allCoins = source
                withdraw.totalBalanceSymbol = totalBalanceSymbol
                self.navigationController?.pushViewController(withdraw, animated: true)
            }
            
        }
        
    }
}

extension EXAssetsPickerVc: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchKey.isEmpty {
            return hasAssetsSource.count
        }
        else {
            return searchRstCoins.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXAssetsPickerCell") as! EXAssetsPickerCell
        var model: EXAccountCoinMapItem?
        if searchKey.isEmpty {
            model = hasAssetsSource[indexPath.row]
        }
        else {
            model = searchRstCoins[indexPath.row]
        }
        
        if let _ = model {
            cell.leftLabel.text = model!.coinName.aliasName()
            cell.rightTopLabel.text = model!.normal_balance.formatAmount(model!.coinName)
            if let symbol = totalBalanceSymbol {
                cell.rightBottomLabel.text = model!.allBtcValuatin.getCaculatePrice(forSymbol: symbol, withUnit: true)
            }
            else {
                cell.rightBottomLabel.text = nil
            }
        }
        else {
            cell.leftLabel.text = nil
            cell.rightTopLabel.text = nil
            cell.rightBottomLabel.text = nil
        }
        
        
        return cell
    }
    
    
}

