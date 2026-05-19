//
//  EXLeverLoanListVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/12/14.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXLoanListMenu:UIView {
    typealias LoanListMenuCallback = (Int)->()
    var onMenuCallback:LoanListMenuCallback?
    
    var currentPage :Int = 0
    lazy var currentBtn:UIButton = {
        let title = UIButton.init(type: .custom)
        title.setTitle("leverage_current_borrow".localized(), for: .normal)
        title.titleLabel?.font = UIFont.ThemeFont.H1Bold
        title.setTitleColor( UIColor.ThemeLabel.colorLite, for: .normal)
        title.addTarget(self, action: #selector(onTitleBtnSelcted(_:)), for:.touchUpInside)
        return title
    }()
    
    lazy var historyBtn:UIButton = {
        let title = UIButton.init(type: .custom)
        title.setTitle("leverage_history_borrow".localized(), for: .normal)
        title.titleLabel?.font = UIFont.ThemeFont.HeadMedium
        title.setTitleColor( UIColor.ThemeLabel.colorMedium, for: .normal)
        title.addTarget(self, action: #selector(onTitleBtnSelcted(_:)), for:.touchUpInside)
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configTitles()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onTitleBtnSelcted(_ sender:UIButton) {
        if sender == currentBtn {
            self.onMenuCallback?(0)
        }else if sender == historyBtn {
            self.onMenuCallback?(1)
        }
    }
    
    func configTitles() {
        self.addSubview(currentBtn)
        self.addSubview(historyBtn)
        self.selectedPage(currentPage)
        currentBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.bottom.equalToSuperview()
            make.right.equalTo(historyBtn.snp.left).offset(-16)
        }
        historyBtn.snp.makeConstraints { (make) in
            make.left.equalTo(currentBtn.snp.right).offset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    func selectedPage(_ page:Int) {
        if page == 0 {
            self.currentBtn.titleLabel?.font =  UIFont.ThemeFont.H1Bold
            self.historyBtn.titleLabel?.font =  UIFont.ThemeFont.HeadMedium
            self.currentBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
            self.historyBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
            
        }else if page == 1 {
            self.historyBtn.titleLabel?.font =  UIFont.ThemeFont.H1Bold
            self.currentBtn.titleLabel?.font =  UIFont.ThemeFont.HeadMedium
            self.historyBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
            self.currentBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        }
    }
}


class EXLeverLoanListVC: BaseVC,NavigationPlugin {
//    var entity:CoinMapEntity = CoinMapEntity()
    var pageTitleView:EXLoanListMenu = EXLoanListMenu()
    var pageContentView = SGPageContentCollectionView()
    var currentIdx:Int = 0
    var coinMapName:String = ""
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil, presenter: self)
        return nav
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigation.isLastNavigationStyle = true
        configPageContents()
        if currentIdx == 1 {
            pageTitleView.selectedPage(currentIdx)
        }
    }
    
    func configPageContents() {

        let current = EXCurrentBorrowVc.init(nibName: "EXCurrentBorrowVc", bundle: nil)
        current.coinMapName = coinMapName
        let history = EXHistoryBorrowVc.init(nibName: "EXHistoryBorrowVc", bundle: nil)
        history.coinMapName = coinMapName

        self.pageTitleView = EXLoanListMenu.init(frame: CGRect(x: 0, y: NAV_SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 36))
        self.pageTitleView.currentPage = currentIdx
        pageTitleView.onMenuCallback = {[weak self] tag in
            self?.handleMenuAction(tag: tag)
        }
        view.addSubview(pageTitleView)
        

        self.pageContentView = SGPageContentCollectionView.init(frame: CGRect(x: 0, y: NAV_SCREEN_HEIGHT + 36, width: SCREEN_WIDTH, height: CONTENTVIEW_HEIGHT - 36), parentVC: self, childVCs:[current,history])
        pageContentView.backgroundColor = UIColor.ThemeView.bg
        pageContentView.setPageContentCollectionViewCurrentIndex(currentIdx)
        pageContentView.delegatePageContentCollectionView = self
        view.addSubview(pageContentView)
        
    }
    
    func handleMenuAction(tag:Int) {
        self.pageContentView.setPageContentCollectionViewCurrentIndex(tag)
        self.currentIdx = tag
    }
}


extension EXLeverLoanListVC : SGPageContentCollectionViewDelegate {
    
    func pageContentCollectionView(_ pageContentCollectionView: SGPageContentCollectionView!, index: Int) {
        pageTitleView.selectedPage(index)
    }

}
