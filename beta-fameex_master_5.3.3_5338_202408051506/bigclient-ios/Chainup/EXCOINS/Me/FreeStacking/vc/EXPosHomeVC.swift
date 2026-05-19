//
//  EXPosHomeVC.swift
//  Chainup
//
//  Created by lcus on 2023/9/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//home page

import UIKit
import RxSwift
import JXPagingView
import JXSegmentedView
import Swap
import EXKit
class EXPosHomeVC: NavCustomVC{

    var allDataCopy:[EXPosHomeProjectEntity] = []
    var dataSource: [[EXPosHomeProjectEntity]] = []
    var viewModel:EXPosHomeVM = {
        let viewModel = EXPosHomeVM()
        return viewModel
    }()
    var maibutton = RepeatButton()
    var typeEnity:EXPosHomeTypesEntity?
    var bannerURL:String?
    var allDatas:[EXPosHomeProjectEntity] = []
    var titleButton = RepeatButton()
    var pagingView:JXPagingView!
    var userHeaderView:UIImageView!
    var titles:[String] = []
    var listViews: [EXPosHomeProListView] = []
    var headerContainer = UIView()
    let tableHeaderViewHeight :Int = Int(150) + 10
    let headerInsectionHeight:Int = 44
    var scrollDistance = 234 - NAV_SCREEN_HEIGHT
    
    lazy var categoryDataSource: JXSegmentedTitleDataSource = {
        let source = JXSegmentedTitleDataSource()
        source.titles = titles
        source.titleNormalColor = UIColor.ThemeLabel.colorMedium
        source.titleSelectedColor = UIColor.ThemeLabel.colorLite
        source.titleNormalFont    = UIFont.ThemeFont.BodyRegular
        source.titleSelectedFont  = UIFont.ThemeFont.BodyBold
        source.isItemSpacingAverageEnabled = false
        source.itemSpacing = 30
        return source
    }()
    lazy var categoryView: JXSegmentedView = {
        let v = JXSegmentedView(frame: .init(x: 0, y: 0, width: Int(SCREEN_WIDTH), height: headerInsectionHeight))
        v.dataSource = categoryDataSource
        v.contentEdgeInsetLeft = 16
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth  = 40
        indicator.indicatorHeight = 2
        indicator.lineStyle       = .normal
        indicator.indicatorColor  = UIColor.ThemeView.highlight
        v.indicators = [indicator]
        return v
    }()
    
    
    //MARK:lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
         configeUI()
         loadProjectListData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.view.bringSubviewToFront(self.navCustomView)
        pagingView.frame = self.view.bounds
        pagingView.frame = CGRect(x: 0, y: NAV_SCREEN_HEIGHT, width: Device_W, height: Device_H - NAV_SCREEN_HEIGHT )
    }
    
    
    
    //MARK: customMethods
    func loadProjectListData()  {
        viewModel.loadTypesData { [weak self] (enity) in
            self?.typeEnity = enity
            self?.bannerURL = enity.url
            if enity.url.hasPrefix("https"){
                self?.maibutton.isHidden = false
                self?.relayout(showMail: true)
            }
            
            if let url = URL(string: enity.banner) {
                self?.userHeaderView.yy_setImage(with: url, placeholder: UIImage(named: "banenr"))
            }
            self?.configTypes(enity: enity)
            self?.titleButton.setTitle(enity.tipMine, for: .normal)
    
            EXPosDetailServer.sharedInstance.tipMine = enity.tipMine
            self?.viewModel.loadProjectList(listCallBack: { [weak self] (listDatas) in
                self?.allDatas = listDatas
                let indexData = self?.dataSource[0]
                if indexData?.count == 0{
                    self?.dataSource[0] = listDatas
                }
                self?.refreshBottomList(index: 0)
            })
            
        }
    }
    //MARK: Get all types
    func configTypes(enity:EXPosHomeTypesEntity) {
        var titles = enity.typeConfig.map{$0.typeName}
        if titles.count > 0 {
            titles .insert("common_action_sendall".localized(), at: 0)
        }
        self.titles = titles
        self.categoryDataSource.titles = titles
        listViews.removeAll()
        for _ in 0..<titles.count {
            dataSource.append([])
            let list = EXPosHomeProListView()
            listViews.append(list)
            
        }
        categoryView.reloadData()
    }

    func categoryDideSelect(index:Int,type:String)  {
        let data = type == "all" ? self.allDataCopy
        :self.viewModel.fitterDatas(list: self.allDatas, type: type)
        let indexData = self.dataSource[index]
        if indexData.count == 0{
            self.dataSource[index] = data
        }
        refreshBottomList(index: index)
    }
    //MARK: Refresh bottom list
    func refreshBottomList(index: Int){
        let list = listViews[index]
        list.allDataCopy = self.dataSource[index]
        list.dataSource = self.dataSource[index]
        list.tableView.reloadData()
    }
    
    //MARK:UI
    func configeUI()  {
        
        headerContainer = UIView()
        headerContainer.backgroundColor = UIColor.ThemeView.bg
        
        
        userHeaderView = UIImageView()
        userHeaderView.backgroundColor = .clear
        userHeaderView.contentMode = UIView.ContentMode.scaleAspectFill
        let x:Int = 15
        userHeaderView.frame = CGRect(x: Int(x), y: 0, width:Int(Device_W) - 30, height: tableHeaderViewHeight)
        userHeaderView.clipsToBounds = true
        userHeaderView.extSetCornerRadius(4)

        
        headerContainer.addSubview(userHeaderView)
        categoryView.delegate = self
        pagingView =  EXPagingView(delegate: self, listContainerType: .scrollView)
        pagingView.backgroundColor = UIColor.ThemeView.bg
//        pagingView.pinSectionHeaderVerticalOffset = Int(NAV_SCREEN_HEIGHT)
        self.view.addSubview(pagingView)
        categoryView.listContainer = pagingView.listContainerView
    }
    

    override func setNavCustomV() {
        self.navCustomView.backgroundColor = UIColor.clear
        
        let img =  UIImage.svgImage(named: "personal_mail",version: .five)
        maibutton.setImage(img, for: .normal)
        maibutton.addTarget(self, action: #selector(noticeInfoClick), for: .touchUpInside)
        navCustomView.backView.addSubview(maibutton)
        maibutton.isHidden = true
        let posbutton = RepeatButton()
        self.titleButton = posbutton
        posbutton.setTitleColor(UIColor.Ex.text1, for: .normal)
        posbutton.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        posbutton.addTarget(self, action: #selector(recordButtonClick), for: .touchUpInside)
        navCustomView.backView.addSubview(posbutton)
        self.relayout(showMail: false)
    }
    
    
    func relayout(showMail: Bool){
        if showMail{
            maibutton.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-15)
                make.width.lessThanOrEqualTo(100)
                make.centerY.equalToSuperview()
                make.height.equalTo(20)
            }
            self.titleButton.snp.remakeConstraints { (make) in
                make.right.equalTo(maibutton.snp.left).offset(-20)
                make.width.lessThanOrEqualTo(100)
                make.centerY.equalToSuperview()
                make.height.equalTo(20)
            }
        }else{
            self.titleButton.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-20)
                make.width.lessThanOrEqualTo(100)
                make.centerY.equalToSuperview()
                make.height.equalTo(20)
            }
        }
        
    }
    
    ///MAKR:action
    @objc func recordButtonClick() {
        
        if XUserDefault.getToken() == nil{
            BusinessTools.modalLoginVC()
            return
        }
        let poshistory =  EXPosHistoryVC.instanceFromStoryboard(name: "FreeStacking")
        poshistory.postInfoType = "3"
        self.navigationController?.pushViewController(poshistory, animated: true)
    }
    @objc func noticeInfoClick() {
        
        if let url = self.bannerURL{
            let webVC = WebVC()
            webVC.loadUrl(url)
            self.navigationController?.pushViewController(webVC, animated: true)
            
        }
    
    }
    func mainTableViewDidScroll(_ scrollView: UIScrollView) {
        let percent = scrollView.contentOffset.y
//        if percent >= scrollDistance {
//            self.navCustomView.backgroundColor = UIColor.ThemeNav.bg
//        }else{
//            self.navCustomView.backgroundColor = UIColor.clear
//        }
    }
    
}



extension EXPosHomeVC: JXSegmentedViewDelegate{
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
        let listData = self.dataSource[index];
        if listData.count == 0 {
            if index == 0 {
                self.categoryDideSelect(index: index,type: "all")
                return
            }
            let indexInfo = typeEnity?.typeConfig[index-1]
            self.categoryDideSelect(index: index,type: indexInfo?.typeSn ?? "")
        }
        
        
    }
    
}

extension EXPosHomeVC: JXPagingMainTableViewGestureDelegate{
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == categoryView.collectionView.panGestureRecognizer {
            return false
        }
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}

extension EXPosHomeVC :JXPagingViewDelegate {
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        
        return headerContainer
    }
    
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        
        return headerInsectionHeight
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        
        return categoryView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return titles.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        
        let list = listViews[index]
        let indexDataSouce:[EXPosHomeProjectEntity] = dataSource[index];
        list.setFootView(enity: self.typeEnity!)
        list.dataSource = indexDataSouce
        list.allDataCopy = indexDataSouce
        return list
    }
    
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        
        return tableHeaderViewHeight
    }

}

