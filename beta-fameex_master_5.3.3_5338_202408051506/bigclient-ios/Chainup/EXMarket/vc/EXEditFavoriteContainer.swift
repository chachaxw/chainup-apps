//
//  EXEditFavoriteContainer.swift
//  Chainup
//
//  Created by cwd on 2022/7/21.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit

class EXEditFavoriteContainer: BaseVC,NavigationPlugin{
    var currentIdx:Int = 0
    
    @objc lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(font:16,affectScroll: nil, presenter: self,customHandleBack: true)
        return nav
    }()
    
    let segmentedView = JXSegmentedView()
    lazy var segmentedDataSource: EKMaskSegmentDatasource = {
        let source = EKMaskSegmentDatasource()
        return source
    }()
    lazy var indicatorLienView: EKMaskSegmentIndicator = {
        let view = EKMaskSegmentIndicator()
        return view
    }()
    
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavi()
        var names:[String] = []
        if EXAppConfigManager.sharedInstance.didOpenContract() {
            names = ["mainTab_text_transaction".localized(),
                     "mainTab_text_contract".localized()]
        }else {
            names = ["mainTab_text_transaction".localized()]
        }
        segmentedDataSource.titles = names
        self.segmentedView.dataSource = segmentedDataSource
        self.segmentedView.indicators = [self.indicatorLienView]
        self.segmentedView.delegate = self
        
        let height: CGFloat = names.count == 1 ? 0 : 46//Do not display tabbar columns
        self.segmentedView.frame = CGRect(x: 0, y:NAV_SCREEN_HEIGHT, width: SCREEN_WIDTH, height: height)
        self.view.addSubview(self.segmentedView)
        self.view.addSubview(self.listContainerView)
        let y =  (self.segmentedView.frame.maxY)
        self.listContainerView.frame = CGRect(x: 0, y:y, width: SCREEN_WIDTH, height:self.view.frame.height - height - NAV_SCREEN_HEIGHT)
        segmentedView.listContainer = self.listContainerView
        if currentIdx != 0 {
            self.segmentedView.defaultSelectedIndex = currentIdx
        }
    }
}

extension EXEditFavoriteContainer{
    func configNavi() {
        self.navigation.isLastNavigationStyle = true
        self.navigation.setTitle(title: "market_title_edit_like".localized())
        self.navigation.setdefaultType(type: .listtitle)
        self.navigation.configRightItems(["market_text_custom_finish".localized()],isImageName: false, btnColor: UIColor.ThemeLabel.colorHighlight)
//        self.navigation.updateLeftBtn(title: "market_text_custom_add".localized())
        //Complete editing
        self.navigation.rightItemCallback = {[weak self] tag in
            guard let strong = self  else { return  }
            strong.navigationController?.popViewController(animated: true)
        }
        
        self.navigation.popBtn.isHidden = true
        //Add
//        self.navigation.customBackCallback = {[weak self] in
////            self?.beginSearch()
//            guard let strong = self  else { return  }
//            strong.navigationController?.popViewController(animated: true)
//        }
    }
    
//    @objc func beginSearch() {
//        EXNavigationHandler.sharedHandler.commonJumpCommand(EXRouterActionKey.appSearch.rawValue)
//    }
    
    @objc func editClick(){
        let v = EXEditFavoriteContainer()
        self.navigationController?.pushViewController(v, animated: true)
    }
}


extension EXEditFavoriteContainer:JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if currentIdx != index {
            currentIdx = index
        }
    }
}

extension EXEditFavoriteContainer: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if EXAppConfigManager.sharedInstance.didOpenContract() {
            if index == 0 {
                return EXEditFavoritesVC()
            }else {
                let vc = EXEditFavoritesVC()
                vc.contractType = true
                return vc
            }
        }else {
            return EXEditFavoritesVC()
        }
    }
}


