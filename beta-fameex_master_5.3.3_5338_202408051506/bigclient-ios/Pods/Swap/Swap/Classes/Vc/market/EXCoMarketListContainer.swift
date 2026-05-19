//
//  EXCoMarketListContainer.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/21.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import JXSegmentedView
import RxSwift
public class EXCoMarketListContainer: EXCOBaseContainerVc {
    
    var dataSouce:[EXSwapDrawerViewData] = []
    var vcs:[EXCoMarketListVc] = []
    
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        for (idx,_) in names.enumerated() {
            let listVc = EXCoMarketListVc()
            listVc.rowDatas = self.dataSouce[idx].searData
            vcs.append(listVc)
        }
        self.view.addSubview(self.listContainerView)
        let y =  (self.segmentedView.frame.maxY)
        segmentedView.listContainer = self.listContainerView
        self.listContainerView.frame = CGRect(x: 0, y:y, width: EXSCREEN_WIDTH, height:self.view.frame.height - y - EXTABBAR_HEIGHT - EX_NAV_SCREEN_HEIGHT - EXCoMarketListContainer.segmentHeight)

        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: NOTI_CONCTRACT_WS_RECONNECTED))
            .take(until: self.rx.deallocated) 
            .subscribe(onNext: {[weak self] noti in
                self?.noDataReload()
            })
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noDataReload()
    }
}


extension EXCoMarketListContainer{
    override func configTitles() -> [String]{
        return setOringinData()
    }
}

extension EXCoMarketListContainer: JXSegmentedListContainerViewDataSource {
    
    public func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    public func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return vcs[index]
    }
}

extension EXCoMarketListContainer{
    
    func noDataReload(){
        if self.vcs.count > 0 {
            return
        }
        names = configTitles()
        if names.count > 0 {
            maskSegmentedDataSource.titles = names
            self.segmentedView.dataSource = maskSegmentedDataSource
            self.segmentedView.indicators = [self.maskIndicatorLienView]
        }
        for (idx,_) in names.enumerated() {
            let listVc = EXCoMarketListVc()
            listVc.rowDatas = self.dataSouce[idx].searData
            vcs.append(listVc)
        }
        self.segmentedView.reloadData()
    }
    
    func setOringinData() -> [String] {
        dataSouce = EXSwapDrawerViewData.getSwapDataSoure()
        let titles  = EXSwapDrawerViewData.getSwapDataSoureTitlelist()
        return titles
    }
}


extension EXCoMarketListContainer: JXSegmentedListContainerViewListDelegate {
    public func listView() -> UIView {
        return self.view
    }
}
