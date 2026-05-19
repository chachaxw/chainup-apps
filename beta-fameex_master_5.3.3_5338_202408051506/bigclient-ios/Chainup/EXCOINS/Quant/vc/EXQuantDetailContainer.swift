//
//  EXQuantDetailContainer.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/5.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXQuantDetailContainer: BaseVC,NavigationPlugin {

    var strategyID:String
    var currentIdx:Int = 0
    
    var currentVC :EXQuantPendingVC
    var historyVC :EXQuantDoneVC
    
    var pageContentView = SGPageContentCollectionView()
    var pageTitleView = SGPageTitleView()
    
    
    private var symbol:String
    private var pendingCount:String
    private var doneCount:String
    var listItem:EXQuantStrategyListItem
    
    var close:String = ""
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil, presenter: self)
        return nav
    }()
    
    func configNavi() {
        self.navigation.isLastNavigationStyle = true
        self.navigation.setTitle(title: self.symbol.aliasCoinMapName() + "quant_pending_detail".localized())
        self.navigation.setdefaultType(type: .listtitle)
        
        self.navigation.middleTitle.snp.remakeConstraints { (make) in
            make.centerY.equalTo(self.navigation.popBtn)
            make.height.equalTo(33)
            make.left.equalTo(self.navigation.popBtn.snp.right).offset(10)
            make.width.lessThanOrEqualTo(SCREEN_WIDTH - 100)
        }
    }
    
    required init(strategyID:String,listItem:EXQuantStrategyListItem) {
        self.strategyID = strategyID
        self.symbol = listItem.symbol
        self.listItem = listItem
        self.pendingCount = listItem.orderingCount
        self.doneCount = listItem.finishCount
        self.currentVC = EXQuantPendingVC.init(strategyID: strategyID,item: listItem)
        self.historyVC = EXQuantDoneVC.init(strategyID: strategyID,symbol: symbol)
        self.historyVC.listItem = self.listItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavi()
        self.automaticallyAdjustsScrollViewInsets = false
        configQuantContainers()
        self.currentVC.currentPrice = close
        historyVC.orderCountChange = {[weak self] count in
            self?.pageTitleView.resetTitle( "quant_ordered".localized() + "(\(count))", for: 1)
        }
        
        currentVC.orderCountChange = {[weak self] count in
            self?.pageTitleView.resetTitle( "quant_ordering".localized() + "(\(count))", for: 0)
        }
        // Do any additional setup after loading the view.
    }
    
    func configQuantContainers() {
        let configure = SGPageTitleViewConfigure.init()
        configure.indicatorStyle = SGIndicatorStyle.init(2)
        configure.indicatorColor = .Ex.main1
        configure.indicatorHeight = 4
        configure.showBottomSeparator = true
        configure.bottomSeparatorColor = .Ex.fill4
        configure.titleFont = .Ex.regular(16)
        configure.titleSelectedFont = .Ex.medium(16)
        configure.titleColor = .Ex.text2
        configure.titleSelectedColor = .Ex.text1
        configure.titleAdditionalWidth = 22
        configure.equivalence = false
        let titlePending = "quant_ordering".localized() + "(\(self.pendingCount))"
        let titleDone = "quant_ordered".localized() + "(\(self.doneCount))"

        self.pageTitleView = SGPageTitleView.init(frame: CGRect(x: 0, y: NAV_SCREEN_HEIGHT, width: SCREEN_WIDTH, height: menuBarHeight),delegate: self,titleNames: [titlePending,titleDone],configure: configure)
        
        pageTitleView.backgroundColor = UIColor.ThemeView.bg
        pageTitleView.selectedIndex = currentIdx
        view.addSubview(pageTitleView)
        
        self.pageContentView = SGPageContentCollectionView.init(frame: CGRect(x: 0, y: menuBarHeight + NAV_SCREEN_HEIGHT, width: SCREEN_WIDTH, height: CONTENTVIEW_HEIGHT - menuBarHeight ), parentVC: self, childVCs: [currentVC,historyVC])
        pageContentView.backgroundColor = UIColor.ThemeView.bg
        pageContentView.setPageContentCollectionViewCurrentIndex(currentIdx)
        pageContentView.delegatePageContentCollectionView = self
        view.addSubview(pageContentView)
        
    }
}


//MARK: delegate

extension EXQuantDetailContainer :SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate {
    
    func pageContentCollectionViewWillBeginDragging() {}
    func pageContentCollectionViewDidEndDecelerating() {}

    
    func pageTitleView(_ pageTitleView: SGPageTitleView!, selectedIndex: Int) {
        handleCurrentIdx(idx: selectedIndex)
        pageContentView.setPageContentCollectionViewCurrentIndex(selectedIndex)
    }
    
    func pageContentCollectionView(_ pageContentCollectionView: SGPageContentCollectionView!, index: Int) {
        handleCurrentIdx(idx:index)
    }
    
    func pageContentCollectionView(_ pageContentCollectionView: SGPageContentCollectionView!, progress: CGFloat, originalIndex: Int, targetIndex: Int) {
        pageTitleView.setPageTitleViewWithProgress(progress, originalIndex: originalIndex, targetIndex: targetIndex)
    }
     
    func handleCurrentIdx(idx:Int) {
        if currentIdx != idx {
            currentIdx = idx
            
        }
    }
    
}
