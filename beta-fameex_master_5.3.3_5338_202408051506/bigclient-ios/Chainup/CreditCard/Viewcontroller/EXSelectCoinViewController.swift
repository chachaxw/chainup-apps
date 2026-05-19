//
//  EXSelectCoinViewController.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/1.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
typealias SelectCoinBlock = (_ coin: EXCreditCoin) -> ()
class EXSelectCoinViewController: BaseVC,NavigationPlugin {
   
    var selectCoinBlock: SelectCoinBlock?
    var coinList: [EXCreditCoin]? {
        didSet {
            mainview.coinList = coinList
        }
    }
   
    var searchbar:EXNaviSearchBar = EXNaviSearchBar()
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil,presenter: self)
        return nav
    }()
    lazy var mainview: EXSelectCoinView = {
        let v = EXSelectCoinView()
        v.selectCoinBlock = { [weak self] coin in
            self?.selectCoinBlock?(coin)
            self?.navigationController?.popViewController(animated: true)
        }
        return v
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigation()
        configView()
        configDatasource()
        
        
//        searchTable.sectionIndexBackgroundColor = UIColor.clear
//        searchTable.sectionIndexColor = UIColor.ThemeLabel.colorLite

    }
    
     //MARK: method
    func configNavigation() {
        searchbar.cancelBtn.addTarget(self, action: #selector(customBack), for: .touchUpInside)
        searchbar.searchField.setPlaceHolderAtt("cl_market_text8".localized(), color: UIColor.ThemeLabel.colorDark, font: 14)
        searchbar.searchField.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] text in
                self?.mainview.readData(key: text)
            }).disposed(by: self.disposeBag)
        self.navigation.setCustomView(searchbar)
        
    }
    func configView(){
        self.view.addSubview(mainview)
        mainview.snp.makeConstraints { make in
            make.top.equalTo(self.navigation.snp_bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
        }
    }
    
    func configDatasource(){
        
    }
   
    
    @objc func customBack(){
        self.navigationController?.popViewController(animated: true)
    }

   
}
