//
//  EXTopSearchResultVC.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/25.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
import JXSegmentedView
import Swap
class EXTopSearchResultVC: BaseVC {
    var keyWord: String = ""
    var currentIdx:Int = 0
    var titleV:JXSegmentedView = JXSegmentedView()
    var controllers: Array<JXSegmentedListContainerViewListDelegate>  = []
    
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    lazy var segmentedDataSource: EKMaskSegmentDatasource = {
        let source = EKMaskSegmentDatasource()
        return source
    }()
    
    lazy var indicatorLienView: EKMaskSegmentIndicator = {
        let view = EKMaskSegmentIndicator()
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("\(self)\n viewWillAppear")
//        if EXAppConfigManager.sharedInstance.didOpenContract() {
//            contractSubcriber()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        debugPrint("\(self)\n viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        debugPrint("\(self)\n viewWillDisappear")
//        if EXAppConfigManager.sharedInstance.didOpenContract() {
//            cancelContractSubcriber()
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        debugPrint("\(self)\n viewDidDisappear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spotList = EXTopSearchResultListVC()
        controllers.append(spotList)
        var titles:[String] = ["mainTab_text_transaction".localized()]
        if EXAppConfigManager.sharedInstance.didOpenContract() {
            titles.append( "mainTab_text_contract".localized())
            let futures = EXTopSearchResultListVC()
            futures.vcType = .coExchange
            controllers.append(futures)
        }
        
        let titleHeight:CGFloat = titles.count == 1 ? 0 : 46
        let bg = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: titleHeight))
        self.view.addSubview(bg)
        
        self.titleV = JXSegmentedView.init(frame: CGRect(x: 4, y: 12, width: SCREEN_WIDTH - 24, height: 22))
        self.segmentedDataSource.titles = titles
        self.titleV.dataSource = self.segmentedDataSource
        self.titleV.indicators = [self.indicatorLienView]
        self.titleV.listContainer = listContainerView
        self.titleV.delegate = self
        bg.addSubview(titleV)
        self.view.addSubview(listContainerView)
        
        listContainerView.frame = CGRect(x: 0, y: titleHeight, width: SCREEN_WIDTH, height: CONTENTVIEW_HEIGHT - titleHeight)
    }
    
    
    func handleSearchAction(_ searchContent:String) {
        keyWord = searchContent
        if searchContent.isEmpty {
            return
        }
        reloadVcListData()
    }
    
   
}
//Search Result Processing
extension EXTopSearchResultVC{
    func reloadVcListData(){
        if controllers.count > currentIdx {
            //Coins
            if currentIdx == 0 {
                var array : [CoinMapEntity] = []
                for item in  EXAppMarketManager.sharedInstance.getSearchCoinMapList(self.keyWord){
                    array.append(item)
                }
                if let vc = controllers[currentIdx] as? EXTopSearchResultListVC {
                    vc.reloadResults(rsts: array)
                }
            }else if currentIdx == 1 {
                let array = EXSwapItemModel.getItemsWithkeyWord(kw: self.keyWord)
                if let vc = controllers[currentIdx] as? EXTopSearchResultListVC {
                    vc.reloadContractResults(rsts: array)
                }
            }
        }
    }
}
extension EXTopSearchResultVC:JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = titleV.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return controllers[index]
    }
}

extension EXTopSearchResultVC:JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        print("segmentedView index=\(index)")
        if currentIdx != index {
            currentIdx = index
            reloadVcListData()
        }
    }
}

