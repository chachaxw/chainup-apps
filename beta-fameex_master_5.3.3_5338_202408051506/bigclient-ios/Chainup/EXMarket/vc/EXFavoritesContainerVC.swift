//
//  EXFavoritesContainerVC.swift
//  Chainup
//
//  Created by cwd on 2022/7/19.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import RxSwift
import Swap
import EXKit
class EXFavoritesContainerVC: EXBaseContainerVc {
    var vm = EXContractUserVm()
    var marketLists :[EXFavoritesMarketVC] = []
    var wsEventSubject: PublishSubject<Int> = PublishSubject()
    //edit
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    lazy var editBtn : UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        btn.addTarget(self, action: #selector(editClick), for: UIControl.Event.touchUpInside)
        btn.setImage(UIImage.themeImageNamed(imageName: "quotes_optional"), for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMarketSketelon()
        self.view.addSubview(self.listContainerView)
        self.names = self.configTitles()
//        marketLists.removeAll()
        self.updateTabbars(with: self.names)
        if names.count == 1 {
            self.segmentedView.height = 0 //Contract not opened - hidden segmentation
        }
        
        segmentedView.listContainer = self.listContainerView
        
        self.listContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        configSubView()
        wsEventSubject.subscribe { [weak self ]it in
            self?.indexDidChanged()
        } onError: { _  in
            
        } onCompleted: {
            
        } onDisposed: {
            
        }.disposed(by: disposeBag)


    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indexDidChanged()
    }
    
    func configSubView(){
        if (names.count == 1){ //Not activated without editing button
            return
        }
        self.view.addSubview(editBtn)
        editBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalTo(self.segmentedView)
        }
    }
    
    func distributeTicker(_ data:EXMarketWsModel,symbol:String) {
        if marketLists.count > currentIdx,symbol.count > 0 {
//Print ("distribution")
            let currentVc = marketLists[currentIdx]
            currentVc.distributeTicker(data.tick, symbol: symbol)
        }
    }
    
    func listContainerReloadData() {
        if marketLists.count > currentIdx {
            let currentVc = marketLists[currentIdx]
            currentVc.tryToGetCurrentVisibleCells()
        }
    }
    //Update Edit Button
    override func indexDidChanged() {
        if currentIdx == 0 {
            let historyCollection = XUserDefault.getCollectionCoinMap()
            editBtn.isHidden = historyCollection.count == 0
        }else{
            self.vm.getFavoriteList { [weak self] items in
                guard let weakSelf = self else { return }
                if items == nil || items?.count == 0{ //If
                    weakSelf.editBtn.isHidden = true
                }else{
                    weakSelf.editBtn.isHidden = false
                }
            }
        }
    }
}


extension EXFavoritesContainerVC{
    
    override func configTitles() -> [String] {
        if EXAppConfigManager.sharedInstance.didOpenContract() {
            return ["mainTab_text_transaction".localized(),
                    "mainTab_text_contract".localized()]
        }else {
            return ["mainTab_text_transaction".localized()]
        }
    }
}

extension EXFavoritesContainerVC{
    
    @objc func editClick(){
        let v = EXEditFavoriteContainer()
        if currentIdx == 1 {
            v.currentIdx = 1 //If a contract is selected, skip over and select the contract
        }
        self.navigationController?.pushViewController(v, animated: true)
    }
}

extension EXFavoritesContainerVC: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if EXAppConfigManager.sharedInstance.didOpenContract() {
            if index == 0 {
                let favorite = EXFavoritesMarketVC()
                favorite.wsEventSubject = self.wsEventSubject
                marketLists.append(favorite)
                return favorite
            }else {
                let v = EXCoFavoriteVc()
                v.wsEventSubject = self.wsEventSubject
                return v
            }
        }else {
            let favorite = EXFavoritesMarketVC()
            favorite.wsEventSubject = self.wsEventSubject
            marketLists.append(favorite)
            return favorite
        }
    }
}


extension EXFavoritesContainerVC: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}

