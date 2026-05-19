//
//  EXCoinEntrustVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import JXSegmentedView


class EXCoinEntrustVC: NavCustomVC {
    
    var entity = CoinMapEntity()
    {
        didSet{
            currentVC.entity = entity
            historyVC.entity = entity
        }
    }
    
    lazy var currentVC: EXCurrentEntrustVC = {
        let v = EXCurrentEntrustVC()
        return v
    }()
    
    lazy var historyVC: EXHistoryEntrustVC = {
        let v = EXHistoryEntrustVC()
        v.view.isHidden = true
        return v
    }()
    
    var currentPage = 0
    
    var currentFilterParam = [String:String]()
    
    lazy var segementTitles: JXSegmentedTitleDataSource = {
        let d = JXSegmentedTitleDataSource()
        d.isItemSpacingAverageEnabled = false
        d.itemSpacing = 8
        d.titleNormalFont = .Ex.medium(14)
        d.titleSelectedFont = .Ex.medium(14)
        d.titleNormalColor = .Ex.text2
        d.titleSelectedColor = .Ex.text1
        d.titles = ["contract_text_currentEntrust".localized(),
                    "contract_text_historyCommision".localized()]
        return d
    }()
    
    lazy var segementView: JXSegmentedView = {
        let v = JXSegmentedView()
        v.delegate = self
        v.dataSource = segementTitles
        v.indicators = [EKIndicatorSegmentIndicator()]
        return v
    }()
    
    lazy var entrustMenu:EXEntrustmentMenus = {
        let v = EXEntrustmentMenus.init(menus:EXEntrustMenuItem.getMenuItems())
        v.hideLastMenu()
        v.onMenuActionCallback = {[weak self] action in
            guard let self else { return }
            self.handleSheetAction(action: action)
        }
        return v
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChild(currentVC)
        self.addChild(historyVC)
        self.contentView.addSubViews([currentVC.view,historyVC.view])
        self.contentView.addSubViews([segementView, entrustMenu])
        
        
        segementView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
        
        entrustMenu.snp.makeConstraints { (make) in
            make.top.equalTo(segementView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(38)
        }
        currentVC.view.extUseAutoLayout()
        currentVC.view.snp.makeConstraints { (make) in
            make.top.equalTo(entrustMenu.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        historyVC.view.extUseAutoLayout()
        historyVC.view.snp.makeConstraints { (make) in
            make.top.equalTo(entrustMenu.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        historyVC.view.isHidden = true
        self.entrustMenu.updateMenuTitle(title: self.entity.showName, idx: 0)
    }
    
  
    
    override func setNavCustomV() {
        self.lastVC = true
        self.navtype = .normal
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EXCoinEntrustVC: JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if index == 0 {
            currentVC.view.isHidden = false
            historyVC.view.isHidden = true
            entrustMenu.hideLastMenu()
            currentFilterParam = ["type":"1"] //limit
            currentVC.handleFilter(self.currentFilterParam)
        } else {
            currentVC.view.isHidden = true
            historyVC.view.isHidden = false
            entrustMenu.showLastMenu()
            currentFilterParam = ["type":""] //
            historyVC.handleFilter(self.currentFilterParam)
        }
    }
    
}


extension EXCoinEntrustVC {
    
    //Further encapsulation
    func handleSheetAction(action:EXEntrustMenuItem) {

        if action.action == .mixCoinMap {
            let sheet = EXCoinMapSheet()
            sheet.bindMixCell(model: EXFilterDataModel.mixFilterDataModel())
            sheet.onCoinMapCallback = { [weak self] symbol in
                var coinSymbol = ""
                if symbol.count > 0 {
                    coinSymbol = symbol.replacingOccurrences(of: "/", with: "").lowercased()
                    self?.entrustMenu.updateMenuTitle(title: symbol, idx: 0)
                }else {
                    self?.entrustMenu.updateMenuTitle(title: "common_action_allTradingPairs".localized(), idx: 0)
                }
                self?.updateFilter(key: action.paramKey, value: coinSymbol)
            }
            EXAlert.showSheet(sheetView: sheet)
        }else {
            let sheet = EXOldActionSheetView()
            let actions = EXEntrustMenuItem.getSheetValueActions(action: action.action)
            var sheetIdx:Int = 0
            if let selectValue = self.currentFilterParam[action.paramKey] {
                sheetIdx = actions.firstIndex(of: selectValue) ?? 0
            }
            sheet.actionIdxCallback = {[weak self](idx) in
                guard let mySelf = self else{return}
                mySelf.sheetSeleted(idx: idx, item: action)
            }
            if action.action == .orderType {

                sheet.configButtonTitles(buttons:EXEntrustMenuItem.getSheetTitleByActions(action: action.action),
                                         selectedIdx: sheetIdx)
            }else if action.action == .orderState {
                
                sheet.configButtonTitles(buttons: EXEntrustMenuItem.getSheetTitleByActions(action: action.action),
                                         selectedIdx: sheetIdx)
            }else if action.action == .entrustmentType {
                
                sheet.configButtonTitles(buttons:EXEntrustMenuItem.getSheetTitleByActions(action: action.action),
                                         selectedIdx: sheetIdx)
            }
            EXAlert.showSheet(sheetView: sheet)
        }
    }
    
    func sheetSeleted(idx:Int,item:EXEntrustMenuItem) {
        let actions = EXEntrustMenuItem.getSheetValueActions(action: item.action)
        let titles = EXEntrustMenuItem.getSheetTitleByActions(action: item.action)
        if titles.count > idx {
            entrustMenu.updateMenuTitle(title: titles[idx], idx:EXEntrustMenuItem.getMenuIdxByAction(action: item.action))
        }
        updateFilter(key: item.paramKey, value: actions[idx])
    }
    
    func updateFilter(key:String,value:String) {
        self.currentFilterParam[key] = value
        if currentPage == 0 {
            currentVC.handleFilter(currentFilterParam)
        }else {
            historyVC.handleFilter(currentFilterParam)
        }
    }
    
    func sheetConfirm(params: [String : String]) {
        if currentPage == 0 {
            self.currentFilterParam = params
            currentVC.handleFilter(params)
        }else {
            self.currentFilterParam = params
            historyVC.handleFilter(params)
        }
    }
    
   
     
}

