//
//  EXKlineDetailNewView.swift
//  Chainup
//
//  Created by youbin on 2023/6/14.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXPagingView
import JXSegmentedView
import EXKit
import Swap
class EXKlineDetailNewView: EXView {
    
    lazy var pagingView: EXPagingView = {
        let v = EXPagingView(delegate: self, listContainerType: .scrollView)
        v.extUseAutoLayout()
        v.backgroundColor = .Ex.kLine.fill2
        v.mainTableView.gestureDelegate = self
        v.mainTableView.mj_header = EXRefreshHeaderView(refreshingBlock: { [weak self]  in
            guard let `self` = self else { return }
            self.viewModel?.reconnectSocket()
        })
        return v
    }()
    
    lazy var pagingHeader: EXKlineDetailHeader = {
        let v = EXKlineDetailHeader(viewModel: self.viewModel)
        v.extUseAutoLayout()
        v.backgroundColor = UIColor.clear
        
        return v
    }()
    
    lazy var dataSource: JXSegmentedTitleDataSource = {
        let source = JXSegmentedTitleDataSource()
        source.titles = []
        source.titleNormalColor = UIColor.ThemekLine.labcolorMedium
        source.titleSelectedColor = UIColor.ThemekLine.labcolorHighlight
        source.titleNormalFont    = UIFont.ThemeFont.HeadRegular
        source.titleSelectedFont = UIFont.ThemeFont.HeadBold
        return source
    }()
    
    lazy var segmentedView: JXSegmentedView = {
        let v = JXSegmentedView(frame: .init(x: 0, y: 0, width: SCREEN_WIDTH, height: 56))
        v.dataSource = dataSource
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth  = 20
        indicator.indicatorHeight = 3
        indicator.lineStyle       = .normal
        indicator.indicatorColor  = UIColor.ThemeView.highlight
        v.indicators = [indicator]
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
    
    lazy var footer:EXKlineFooter = {
        let footer = EXKlineFooter.init(type: self.viewModel?.kDetailType ?? .coin)
        return footer
    }()
    
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
        addSubViews([pagingView, footer])
        pagingView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        footer.snp.makeConstraints { make in
            make.top.equalTo(pagingView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(isiPhoneX ? TABBAR_BOTTOM + 74 : 74)
        }
        reloadPagingLayout()
    }
    
    
    ///Refresh PagingView
    func reloadPagingLayout() {
        segmentedView.listContainer = pagingView.listContainerView
        segmentedView.defaultSelectedIndex = 0
        pagingView.defaultSelectedIndex    = 0
        if let _entity = self.viewModel?.entity {
            var titles = ["kline_action_entrustMentOrder".localized(),
                          "kline_action_dealHistory".localized()]
            if _entity.etfOpen == "1" {
                titles.append("market_text_tab_etf_info".localized())
                titles.append("market_text_tab_etf_rule".localized())
            } else {
                if let _brief = self.viewModel?.coinBrief, _brief.coinSymbol.count > 0 {
                    let text = "market_text_coinInfo".localized()
                    if titles.contains(text) == false {
                        titles.append(text)
                    }
                }
            }
            dataSource.titles = titles
        }
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.segmentedView.reloadData()
            self.pagingView.resizeTableHeaderViewHeight()
            self.pagingView.reloadData()
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.pagingHeader.heightCallback = { [weak self] height in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.pagingHeader.frame.size.height = height
                self.pagingView.resizeTableHeaderViewHeight()
            }
        }
        
        self.viewModel?.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            if self.pagingView.mainTableView.mj_header.isRefreshing {
                self.pagingView.mainTableView.mj_header.endRefreshing()
            }
            switch event {
            case .KLineChangedEntity(_):
                self.reloadPagingLayout()
            case .KLineCoinBrief(_):
                self.reloadPagingLayout()
            default:
                break
            }
        }).disposed(by: self.disposeBag)
        
        self.footer.buyBtn.addTarget(self, action: #selector(buyAction), for: .touchUpInside)
        self.footer.sellBtn.addTarget(self, action: #selector(sellAction), for: .touchUpInside)
        
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

extension EXKlineDetailNewView {
    
    //business
    @objc func buyAction() {
        
        guard let _entity = self.viewModel?.entity else { return }
        guard let _kDetailType = self.viewModel?.kDetailType else { return }
        
        if _kDetailType == .coin{
            EXNavigationHandler.sharedHandler.commandTradingCoin(_entity.symbol, "buy")
        }else if _kDetailType == .lever{
            EXNavigationHandler.sharedHandler.commandTradingCoin(_entity.symbol, "leverBuy")
        }else if _kDetailType == .quant {
            EXNavigationHandler.sharedHandler.commandTradingCoin(_entity.symbol, "quant")
        }
    }
    
    @objc func sellAction() {
        
        guard let _entity = self.viewModel?.entity else { return }
        guard let _kDetailType = self.viewModel?.kDetailType else { return }
        
        if _kDetailType == .coin{
            EXNavigationHandler.sharedHandler.commandTradingCoin(_entity.symbol, "sell")
        }else if _kDetailType == .lever{
            EXNavigationHandler.sharedHandler.commandTradingCoin(_entity.symbol, "leverSell")
        }else if _kDetailType == .quant {
            EXNavigationHandler.sharedHandler.commandTradingCoin(_entity.symbol, "quant")
        }
    }
}





extension EXKlineDetailNewView: JXPagingMainTableViewGestureDelegate{
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == segmentedView.collectionView.panGestureRecognizer {
            return false
        }
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}

extension EXKlineDetailNewView: JXPagingViewDelegate{
    
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return Int(self.pagingHeader.frame.size.height)
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return self.pagingHeader
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return Int(segmentedView.frame.height)
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segmentedView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return dataSource.titles.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        switch index {
        case 0:
            let v = EXKlineDetailDepthView(viewModel: self.viewModel)
            return v
        case 1:
            let v = EXKlineDetailDealView(viewModel: self.viewModel)
            return v
        case 2:
            let titles = self.dataSource.titles
            let text = "market_text_coinInfo".localized()
            if let _entity = self.viewModel?.entity, _entity.etfOpen != "1", titles.contains(text) {
                let v = EXKlineDetailBriefView(viewModel: self.viewModel)
                return v
            } else {
                let v = EXKlineDetailETFInfoView(viewModel: self.viewModel)
                return v
            }
        case 3:
            let v = EXKlineDetailWarehouseView(viewModel: self.viewModel)
            return v
        default:
            let v = EXKlineDetailDealView(viewModel: self.viewModel)
            return v
        }
    }
    
    func pagingView(_ pagingView: JXPagingView, mainTableViewWillBeginDragging scrollView: UIScrollView) {
        self.viewModel?.isScrolling = true
        
    }
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidEndDragging scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.viewModel?.isScrolling = false
    }
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidScroll scrollView: UIScrollView) {
        self.viewModel?.isScrolling = true
    }
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidEndDecelerating scrollView: UIScrollView) {
        debugPrint(#function)
        self.viewModel?.isScrolling = false
    }
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidEndScrollingAnimation scrollView: UIScrollView) {
        self.viewModel?.isScrolling = false
    }
    
}



