//
//  EXSFiterView.swift
//  Chainup
//
//  Created by cwd on 2022/11/6.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
import JXSegmentedView
//选择币对 English: Select currency pairs
class EXSFiterView: EXBaseContainView {
    
    var vm = EXDrawViewModel()
    var dataSouce:[EXSwapDrawerViewData] = []
    var vcs:[EXFilerListView] = []
    var isSearching = false
    //MARK: fix 盈亏筛选需添加全部 English: MARK: Fix profit and loss screening needs to add all
    override func setSubView() {
        super.setSubView()
        configSubView()
        let h =  Device_H * 0.5
        self.snp.makeConstraints { make in
            make.height.equalTo(h)
        }
        
        self.vm.eventSubject.subscribe(onNext: { [weak self] type in
            switch type{
            case .selectFinsh(_):
                self?.clearSelectData()
                EXAlert.dismiss()
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
    
    deinit{
//        //print("deinit")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.exs_roundCorners(corners: [.topLeft,.topRight], radius: 10)
    }
    //MARK: lazy
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
   
    
    //搜索栏 English: Search bar
    lazy var searchBar: EXCOSearchBar = {
        let v = EXCOSearchBar()
        v.enableSearch = true
        v.bgColor = UIColor.ThemeView.card2
        v.backgroundColor = UIColor.ThemeView.alertBg
        v.showCancelBtn = true
        v.canbtnBlock = {
            EXAlert.dismiss()
        }
        v.textField.textfieldValueChangeBlock = {[weak self]str in
            print(str)
            self?.isSearching = str.count > 0
            self?.vm.eventSubject.onNext(.searchKey(keyWord: str))
        }
        return v
    }()
    
    

}
extension EXSFiterView{
    //MARK:  盈亏需加 全部 English: MARK: Profit and loss need to be added in full
    func configAllData(){
        names =  EXSwapDrawerViewData.getSwapDataSoureTitlelist(containAll: true)
        maskSegmentedDataSource.titles = names
        self.dataSouce = EXSwapDrawerViewData.getSwapDataSoure(containAll: true)
        self.segmentedView.dataSource = maskSegmentedDataSource
        vcs.removeAll()
        for (idx,_) in names.enumerated() {
            let listVc = EXFilerListView()
            listVc.orinDatas = self.dataSouce[idx].searData
            listVc.rowDatas = self.dataSouce[idx].searData
            vcs.append(listVc)
            listVc.vm = self.vm
        }
        
        self.segmentedView.reloadData()
        
        
    }
    
    func clearSelectData(){
        for list in self.dataSouce{
            for item in list.originData{
                item.selected = false
            }
        }
    }
    
    func configSubView(){
        self.backgroundColor = UIColor.ThemeView.alertBg
        for (idx,_) in names.enumerated() {
            let listVc = EXFilerListView()
            listVc.orinDatas = self.dataSouce[idx].searData
            listVc.rowDatas = self.dataSouce[idx].searData
            vcs.append(listVc)
            listVc.vm = self.vm
        }
        self.addSubview(searchBar)
        self.addSubview(self.listContainerView)
        searchBar.snp.makeConstraints { make in
            make.left.equalToSuperview() //.offset(16)
            make.right.equalToSuperview()//.offset(-16)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(14)
        }
        
        self.segmentedView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(12)
            make.height.equalTo(30)
            make.left.equalToSuperview() //.offset(16)
            make.right.equalToSuperview().offset(-16)
        }
       
        segmentedView.listContainer = self.listContainerView
        
        self.listContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.segmentedView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(EX_TABBAR_BOTTOM + 20))
        }
    }
    
}
//MARK: 配置数据源 English: MARK: Configure data source
extension EXSFiterView{
    override func configTitles() -> [String]{
        let titles = EXSwapDrawerViewData.getSwapDataSoureTitlelist()
        self.dataSouce = EXSwapDrawerViewData.getSwapDataSoure()
        return titles
    }
    override func indexDidChanged() {
        if self.isSearching {
            return
        }
    }
}

extension EXSFiterView: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return vcs[index]
    }
}


extension EXSFiterView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}

extension EXSFiterView{
    
    func configDefaultSelectedItem(item: EXSwapItemModel){
        var stop = false
        for (index,list) in dataSouce.enumerated(){
            if stop {break}
            for swap in list.searData{
                if item.instrument_id == swap.instrument_id{
                    swap.selected = true
                    self.segmentedView.defaultSelectedIndex = index
                    self.listContainerView.defaultSelectedIndex = index
                    stop = true
                    break
                }
            }
        }
        
    }
    
}

