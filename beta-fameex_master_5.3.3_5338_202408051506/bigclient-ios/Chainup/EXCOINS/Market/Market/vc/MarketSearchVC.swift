//
//  MarketSearchVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/27.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class MarketSearchVC: NavCustomVC {
    var currentVC:UIViewController?
    let topSearch:EXTopSearchVC = EXTopSearchVC()
    let topSearchRst:EXTopSearchResultVC = EXTopSearchResultVC()
    var selectContract = false
    //Search bar
    lazy var searchNavi : EXSearchBarView = {
        let v = EXSearchBarView()
        v.placeHolder = "market_search_ex".localized()
        v.backgroundColor = .clear
        v.contentInsets = .zero
        v.searchContainerInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        v.searchContainer.backgroundColor = .Ex.fill3
        v.isShowCancel = true
        return v
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareGuides()
    }
    
    override func setNavCustomV() {
        super.setNavCustomV()
        self.navCustomView.popBtn.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(searchNavi)
        searchNavi.snp.makeConstraints { (make) in
            let topOffset = (NAV_STATUS_HEIGHT + 6)
            make.top.equalToSuperview().offset(topOffset)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        }
        
        self.currentVC = self.topSearch
        
        self.addChild(self.topSearch)
        topSearch.view.frame =  CGRect(x: 0, y: NAV_SCREEN_HEIGHT, width: SCREEN_WIDTH, height: CONTENTVIEW_HEIGHT)
        self.view.addSubview(topSearch.view)
        
        self.addChild(self.topSearchRst)
        topSearchRst.view.frame =  CGRect(x: 0, y: NAV_SCREEN_HEIGHT, width: SCREEN_WIDTH, height: CONTENTVIEW_HEIGHT)
        self.topSearch.didMove(toParent:self)
        
        if self.selectContract {
//            print("self.selectContract = \(self.selectContract)")
            topSearchRst.titleV.defaultSelectedIndex = 1
            topSearchRst.currentIdx = 1
        }
        
        handleSearchActions()
        rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
            .take(1)
            .subscribe(onNext: {[weak self] _ in
            self?.searchNavi.textField.becomeFirstResponder()
        }).disposed(by: disposeBag)
    }
    
    func handleSearchActions() {
        searchNavi.cancelCallback = {[weak self] in
            guard let self else { return }
            self.searchDismiss()
        }
        searchNavi.textDidChange = { [weak self] value in
            guard let self else { return }
            self.searchForKey(value ?? "")
        }
        topSearch.tagSignal
            .subscribe(onNext:{[weak self] tag in
                guard let `self` = self else {return}
                if tag.count > 0 {
                    self.searchNavi.text = tag
                    self.searchForKey(tag)
                }
            }).disposed(by: self.exs_disposeBag)
    }
    
    @objc func searchDismiss() {
        self.popBack()
    }
    
    func searchForKey(_ searchText:String) {
        if searchText.isEmpty {
            self.changeController(from: self.topSearchRst, to: self.topSearch)
        }else {
            self.topSearchRst.handleSearchAction(searchText)
            self.changeController(from: self.topSearch, to: self.topSearchRst)
        }
    }
    
    func changeController(from old:UIViewController,to new:UIViewController) {
        if currentVC != new {
            self.transition(from: old, to: new, duration: 0.2, options: .transitionCrossDissolve, animations: nil) { (finished) in
                if finished {
                    new.didMove(toParent: self)
                    old.willMove(toParent: nil)
                    self.currentVC = new
                }
            }
        }
    }
    
}

extension MarketSearchVC {
    func prepareGuides () {
        //        if EXAppCache.sharedCache.getAppGuideFirstShow(byType: .search) {
        //            if let headerV = searchView.getHotHeaderView() {
        //                var showItems:[EXHomeGuideBase] = []
        //                var baseView:[UIView] = []
        //                var alignments:[GuideViewAliemnts] = []
        //
        //                let guideA = EXHomeGuideBase.init(guideIcon: "", guideTitle: "common_guide_coin_recommend_hint".localized(),hasSkipNext: false,justShowTitle: true)
        //                guideA.xOffset = 10
        //                showItems.append(guideA)
        //                baseView.append(headerV)
        //                alignments.append(.bottomLeft)
        //
        //                let guideview = EXGuideMaskView.init()
        //                guideview.handleGuides(viewitems: showItems,
        //                                       transparentItems: baseView,
        //                                       aligments: alignments,
        //                                       transItemInsets: [.zero])
        //                guideview.guideCallback = {
        //                    EXAppCache.sharedCache.setAppGuideDidShow(byType: .search)
        //                }
        //                guideview.showGuideView()
        //            }
        //
        //        }
    }
    
}

