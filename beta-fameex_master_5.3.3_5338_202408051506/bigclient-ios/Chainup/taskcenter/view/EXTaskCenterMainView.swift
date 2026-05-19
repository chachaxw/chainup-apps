//
//  EXTaskCenterMainView.swift
//  Chainup
//
//  Created by cwd on 2023/7/24.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXPagingView
import EXKit
import Swap
import JXSegmentedView
class EXTaskCenterMainView: EXView {
    var taskTypes = TaskType.allCases
    var titles =  TaskType.allCases.map { type in
        return type.describe
    }
    
    var lists = [EXTaskListView]()
    var vm: EXTaskViewModel?
    

    required init(viewModel: EXViewModelProtocol?) {
        self.vm = viewModel as? EXTaskViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func setupView() {
        configSubView()
        configData()
    }
    
    
    
    //MARK: lazy
    lazy var pagingHeader: EXTaskCenterHeaderView = {
        let v = EXTaskCenterHeaderView(frame: CGRect(x: 0, y: 0, width: Device_W, height: EXTaskCenterHeaderView.getTotalHeight()))
        return v
    }()
    lazy var pagingView: EXPagingView = {
        let v = EXPagingView(delegate: self, listContainerType: .scrollView)
        v.extUseAutoLayout()
        v.backgroundColor =  .Ex.fill2
        v.mainTableView.backgroundColor =  .Ex.fill2
//        v.mainTableView.gestureDelegate = self
        v.mainTableView.mj_header = EXRefreshHeaderView(refreshingBlock: { [weak self]  in
            guard let `self` = self else { return }
            self.vm?.getTaskHomeAllInfo()
        })
        return v
    }()
    
    
    lazy var dataSource: JXSegmentedTitleDataSource = {
        let source = JXSegmentedTitleDataSource()
        source.titles = titles
        source.titleNormalColor = UIColor.Ex.text2
        source.titleSelectedColor = UIColor.Ex.text1
        source.titleNormalFont    = UIFont.Ex.regular(14)
        source.titleSelectedFont = UIFont.Ex.medium(14)
        source.itemSpacing          = 20
        source.itemWidthIncrement   = 0
        source.isTitleZoomEnabled   = false
        source.isItemSpacingAverageEnabled = false
        return source
    }()
    
    lazy var secionHeader: EXTaskCenterSegmentView = {
        let  v = EXTaskCenterSegmentView(frame: .init(x: 0, y: 0, width: Device_W, height: 44))
        v.segmentedView.dataSource = dataSource
        return v
    }()
                                              
}
extension EXTaskCenterMainView{
    
    func reloadList(){
        for list in lists {
            list.tableView.reloadData()
        }
    }
    
    func configSubView(){
        self.addSubview(pagingView)
        pagingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
   
    func configData(){
        lists.removeAll()
        for type in self.taskTypes {
            let view = EXTaskListView(viewModel: self.vm)
            view.taskType = type
            lists.append(view)
        }
        secionHeader.segmentedView.listContainer = pagingView.listContainerView
    }
    
    func reloadHeader(){
        var singSwitch: Int = 0
        if let op = self.vm?.taskHome?.signSwitch {
            singSwitch = op
        }
        let height = EXTaskCenterHeaderView.getTotalHeight(showSign: singSwitch == 1,signInfo: self.vm?.taskHome?.signInInfo)
        self.pagingHeader.bannerUrl = (EXTheme.current == .dark) ? self.vm?.taskHome?.nightBannerImageH5Url :  self.vm?.taskHome?.bannerImageH5Url
        if singSwitch == 1 {
            self.pagingHeader.signMainview.signModel = self.vm?.taskHome?.signInInfo
        }
        
        var f = self.pagingHeader.frame
        f.size.height  = CGFloat(height)
        self.pagingHeader.frame = f
        //MARK: Only refresh height
        self.pagingHeader.signMainview.isHidden = !(singSwitch == 1)
        self.pagingView.resizeTableHeaderViewHeight()
       
    }
}


extension EXTaskCenterMainView: JXPagingViewDelegate{
    
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
//Print ("Refresh Height= (Int (self. pagingHeader. frame. size. height)")
        return Int(self.pagingHeader.frame.size.height)
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return self.pagingHeader
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return Int(secionHeader.frame.height)
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return secionHeader
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return dataSource.titles.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        let v = lists[index]
        return v
    }
    
}





