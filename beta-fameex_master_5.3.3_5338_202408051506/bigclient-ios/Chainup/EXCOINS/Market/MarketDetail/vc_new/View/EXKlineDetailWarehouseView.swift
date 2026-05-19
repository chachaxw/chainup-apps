//
//  EXKlineDetailWarehouseView.swift
//  Chainup
//
//  Created by youbin on 2023/6/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXPagingView
import JXSegmentedView

class EXKlineDetailWarehouseView: EXView {
    
    lazy var dataSource: JXSegmentedCustomDataSource = {
        let source = JXSegmentedCustomDataSource()
        source.titles               = ["market_text_tab_etf_rule_sl".localized(),
                                       "market_text_tab_etf_rule_list".localized()]
        source.titleNormalColor     = UIColor.ThemekLine.labcolorMedium
        source.titleSelectedColor   = UIColor.ThemekLine.labcolorHighlight
        source.titleNormalFont      = UIFont.ThemeFont.SecondaryRegular
        source.titleSelectedFont    = UIFont.ThemeFont.SecondaryRegular
        source.bgColor              = UIColor.ThemekLine.viewBg
        source.bgSelectedColor      = UIColor.ThemekLine.viewBg
        source.borderColor          = UIColor.ThemekLine.labcolorMedium
        source.selectedBorderColor  = UIColor.ThemekLine.labcolorHighlight
        source.borderWidth          = 0.5
        source.selectedborderWidth  = 0.5
        source.cornerRadius         = 4.0
        source.selectedCornerRadius = 4.0
        source.itemSpacing          = 10
        source.itemWidthIncrement   = 10
        source.isTitleZoomEnabled   = false
        source.isItemSpacingAverageEnabled = false
        return source
    }()
    
    lazy var segmentedView: JXSegmentedView = {
        let v = JXSegmentedView()
        v.delegate = self
        v.dataSource = dataSource
        let line = UIView()
        line.backgroundColor = UIColor.ThemekLine.viewSeperator
        v.addSubview(line)
        line.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        return v
    }()
    
    lazy var listContainerView: JXSegmentedListContainerView = {
        let v = JXSegmentedListContainerView(dataSource: self, type: .scrollView)
        return v
    }()
    
    
    var scrollCallback: ((UIScrollView) -> ())?
    
    var scrollView: UIScrollView = UIScrollView()
    
    var viewModel: EXKlineDetailNewViewModel?
    
    required init(viewModel: EXViewModelProtocol?) {
        self.viewModel = viewModel as? EXKlineDetailNewViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setupView() {
        super.setupView()
        addSubViews([segmentedView, listContainerView])
        segmentedView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16).priority(.medium)
            make.right.equalToSuperview().offset(-16).priority(.medium)
            make.height.equalTo(46)
        }
        listContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        segmentedView.listContainer = listContainerView
        segmentedView.defaultSelectedIndex = 0
        listContainerView.defaultSelectedIndex = 0
        segmentedView.reloadData()
        listContainerView.reloadData()
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

extension EXKlineDetailWarehouseView: JXSegmentedViewDelegate{
    
}

extension EXKlineDetailWarehouseView: JXSegmentedListContainerViewDataSource{
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let _dataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return _dataSource.dataSource.count
        }
        return 0
    }
    
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        
        if index == 0 {
            let view =  EXKlineDetailWarehouseRuleView(viewModel: self.viewModel)
            view.scrollCallback = { [weak self] scrollView in
                guard let `self` = self else { return }
                self.scrollView = scrollView
                self.scrollCallback?(scrollView)
            }
            return view
            
        } else {
            let view =  EXKlineDetailWarehouseRecordView(viewModel: self.viewModel)
            view.scrollCallback = { [weak self] scrollView in
                guard let `self` = self else { return }
                self.scrollView = scrollView
                self.scrollCallback?(scrollView)
            }
            return view
        }
        
    }
    
}



// MARK:JXPagingViewListViewDelegate
extension EXKlineDetailWarehouseView: JXPagingViewListViewDelegate {
    func listView() -> UIView {
        return self
    }
    func listScrollView() -> UIScrollView {
        return self.scrollView
    }
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.scrollCallback = callback
    }
}
