//
//  EXSwapListBaseViewController.swift
//  Chainup
//
//  Created by ZYJ on 2023/6/9.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXPagingView
import JXSegmentedView
import EXKit
class ContentBaseViewController: EXSNavCustomVC {
    var controllers = [ListBaseViewController]()
    lazy var titles:[String] = []
    lazy var dataSource: EKContractIndicatorSegmentDatasource = {
        let source = EKContractIndicatorSegmentDatasource()
        return source
    }()
    
    lazy var lineIndicatorLienView: EKIndicatorSegmentIndicator = {
        let view = EKIndicatorSegmentIndicator()
        return view
    }()
    
    var segmentedDataSource: JXSegmentedBaseDataSource?
    let segmentedView = JXSegmentedView()
    //MARK: JXCategoryView侧滑返回失效处理 English: MARK: JXCategoryView sideslip return failure handling
    lazy var listContainerView: JXSegmentedListContainerView! = {
        let v = JXSegmentedListContainerView(dataSource: self)
        if let pop = self.navigationController?.interactivePopGestureRecognizer{
            v.scrollView.panGestureRecognizer.require(toFail: pop)
        }
       
        return v
    }()
    let linev = UIView()
    open func segmentedViewSelected(index: Int){}
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navtype = .listtitle
        self.contentView.exs_addSubViews([segmentedView,listContainerView])
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！ English: SegmentedViewDatasource must be strongly held through properties!!!!!!!!!
        segmentedView.delegate = self
        segmentedView.listContainer = listContainerView
        segmentedView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width-10, height: 44)
        let y = segmentedView.frame.maxY
        listContainerView.frame = CGRect(x: 0, y: y, width: view.bounds.size.width, height: CONTENT_H - y - EX_TABBAR_BOTTOM)
        linev.backgroundColor = UIColor.ThemeView.seperator
        self.view.addSubview(linev)
        linev.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setDatasourceTitles(_ titles:[String]) {
        dataSource.titles = titles
        self.segmentedDataSource = dataSource
        self.segmentedView.indicators = [self.lineIndicatorLienView]
        segmentedView.dataSource = segmentedDataSource

    }
}

extension ContentBaseViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let dotDataSource = segmentedDataSource as? JXSegmentedDotDataSource {
            //先更新数据源的数据 English: Update the data source first
            dotDataSource.dotStates[index] = false
            //再调用reloadItem(at: index) English: Call reloadItem (at: index) again
            segmentedView.reloadItem(at: index)
        }
        segmentedViewSelected(index: index)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }
}

extension ContentBaseViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return controllers[index]
    }
}


class ListBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension ListBaseViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
    func listWillAppear() {
        
    }
    func listDidAppear() {
        
    }
}

