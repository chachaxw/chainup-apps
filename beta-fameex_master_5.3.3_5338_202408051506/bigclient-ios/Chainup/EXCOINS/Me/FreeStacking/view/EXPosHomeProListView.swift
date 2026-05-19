//
//  EXPosHomeProListView.swift
//  Chainup
//
//  Created by lcus on 2023/10/24.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import JXPagingView
import EXKit
class EXPosHomeProListView: UIView {
    
    var FitterButton:UIButton?
    var tableView: UITableView!
   
    var allDataCopy:[EXPosHomeProjectEntity]?
    var dataSource: [EXPosHomeProjectEntity]?{
        didSet {
//              self.tableView.tableFooterView?.isHidden =  self.dataSource?.count == 0
        }
    }
    
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    var lastSelectedIndexPath: IndexPath?
    var isHeaderRefreshed = false
    
    deinit {
        listViewDidScrollCallback = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView = UITableView(frame: frame, style: .grouped)
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.separatorColor = UIColor.ThemeNav.bg
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableHeaderView = getHeaderActionView()
        tableView.register(UINib(nibName: "EXPosProtocolCell", bundle: nil), forCellReuseIdentifier: "EXPosProtocolCell")
        tableView.register(UINib(nibName: "EXPosPositionCell", bundle: nil), forCellReuseIdentifier: "EXPosPositionCell")
        tableView.register(UINib.init(nibName: "EXPosEmptyCell", bundle: nil), forCellReuseIdentifier: "EXPosEmptyCell")
        addSubview(tableView)
    }
    
    
    func setFootView (enity:EXPosHomeTypesEntity){
        
        let footView = EXHomeFootView()
        footView.setFootData(enitey:enity)
        let size = footView.systemLayoutSizeFitting(CGSize(width:UIScreen.main.bounds.size.width, height: 10000))
        footView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: size.height)
        
        tableView.tableFooterView = footView
    }
    
    func getHeaderActionView() -> UIView {
        let actionView  = UIView()
        actionView.backgroundColor = UIColor.ThemeView.bg
        actionView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 43)
        let button = UIButton()
        button.setTitle("common_action_sendall".localized(), for: .normal)
        button.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        button.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        button .addTarget(self, action: #selector(didClickAction), for: .touchUpInside)
        let imageView = UIImageView(image: UIImage.themeImageNamed(imageName: "personal_dropdown"))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClickAction)))
        let lineView = UIView()
        lineView.backgroundColor = UIColor.ThemeNav.bg
        actionView.addSubViews([button,imageView,lineView])
        
        button.snp.makeConstraints { (make) in
            make.left.equalTo(actionView).offset(15)
            make.centerY.equalTo(actionView)
            make.width.lessThanOrEqualTo(100)
            make.height.equalTo(23)
        }
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(button.snp.right).offset(5)
            make.centerY.equalTo(button)
            make.width.equalTo(8)
            make.height.equalTo(6)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(actionView)
            make.height.equalTo(1)
        }
        self.FitterButton = button
        
        return actionView
    }
    
    @objc func didClickAction() {
        
        let sheet = EXOldActionSheetView()
        
        let buttonTitles = [LanguageTools.getString(key: "pos_state_end"),LanguageTools.getString(key: "pos_state_processing"),LanguageTools.getString(key: "pos_state_start"),LanguageTools.getString(key: "common_action_sendall")]
        
        let choosTitle = self.FitterButton?.currentTitle
        var idx = 0
        for i in 0..<buttonTitles.count {
            
            if choosTitle == buttonTitles[i] {
                
                idx = i
                break
            }
        }
        
        sheet.configButtonTitles(buttons: buttonTitles, selectedIdx: idx)
        sheet.actionIdxCallback = {[weak self] tag in
            let fitterDataSource = self?.fitterDataSouce(type:tag)
            self?.FitterButton?.setTitle(buttonTitles[tag], for: .normal)
            self?.dataSource = fitterDataSource
            self?.tableView.reloadData()
        }
        
        EXAlert.showSheet(sheetView:sheet)
    }
    
    func fitterDataSouce(type:Int) -> [EXPosHomeProjectEntity] {
        
        var fitterDataSouce:[EXPosHomeProjectEntity] = []
        
        switch type {
        case 0:
            fitterDataSouce = self.allDataCopy?.filter{
                ($0.projectType == 3 && ($0.status == 2||$0.status == 3||$0.status == 4 || $0.status == 5||$0.status == 6)) || ($0.projectType == 1 && ($0.status == 3))
                } ?? []
        //The fundraising is ongoing
        case 1:
            fitterDataSouce = self.allDataCopy?.filter{ ($0.projectType == 3 && ($0.status == 1)) || ($0.projectType == 1 && ($0.status == 2))} ?? []
            
        case 2:
            fitterDataSouce = self.allDataCopy?.filter{($0.projectType == 3 && $0.status == 0)||($0.projectType == 1 && $0.status == 1)} ?? []
        default:
            fitterDataSouce = self.allDataCopy ?? []
        }
        
        return fitterDataSouce
        
    }
    
    func beginFirstRefresh() {
        self.tableView.reloadData()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.frame = self.bounds
    }
    


}
extension EXPosHomeProListView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.dataSource?.count ?? 0) == 0 {
            return 1
        }
        return dataSource?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (self.dataSource?.count ?? 0) == 0 {
            return 260
        }
        let indexItem :EXPosHomeProjectEntity = self.dataSource![indexPath.row]
        if indexItem.projectType == 3 {
            return 118
        }else{
            return 66
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.dataSource?.count ?? 0) == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosEmptyCell") as! EXPosEmptyCell
            return cell
        }
     
        let indexItem :EXPosHomeProjectEntity = self.dataSource![indexPath.row];
        
        if indexItem.projectType == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosProtocolCell") as! EXPosProtocolCell
            cell.setCellData(indexItem)
            return cell
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosPositionCell") as! EXPosPositionCell
        cell.setCellData(indexItem)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.dataSource?.count ?? 0) == 0{
            return
        }
        let indexItem :EXPosHomeProjectEntity = self.dataSource![indexPath.row];
        if indexItem.projectType == 3 {
            
            let protocolVC = EXPosProtocolDetailVC()
            protocolVC.projectID = String(indexItem.id)
            EXPosDetailServer.sharedInstance.projectId = String(indexItem.id)
            self.yy_viewController?.navigationController?.pushViewController(protocolVC, animated: true)
            
        }else {
            let positionVC = EXPosPositionDetailVC()
            positionVC.projectID = String(indexItem.id)
            self.yy_viewController?.navigationController?.pushViewController(positionVC, animated: true)
        }
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.listViewDidScrollCallback?(scrollView)
    }
}

extension EXPosHomeProListView: JXPagingViewListViewDelegate {
    public func listView() -> UIView {
        return self
    }
    
    public func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallback = callback
    }
    
    public func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    public func listDidDisappear() {
        print("listDidDisappear")
    }
    
    public func listDidAppear() {
        print("listDidAppear")
    }
}

