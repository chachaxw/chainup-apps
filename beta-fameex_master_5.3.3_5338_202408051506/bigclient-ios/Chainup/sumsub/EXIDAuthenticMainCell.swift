//
//  EXIDAuthenticItemView.swift
//  Chainup
//
//  Created by cwd on 2023/11/1.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXIDAuthenticMainCell: EXBaseCell {
    private let sectionId = "EXIDAuthenticSectionHeaderView"
    var model: EXIDAuthenticModel? {
        didSet{
            tableViewHeader.model = model
            tableView.reloadData()
        }
    }
    
    
    class func getCellHeight(model: EXIDAuthenticModel?) -> CGFloat{
        guard let model = model else {return 0}
        var height = 16.0 //topSpace
        height += EXIDAuthenticStatusView.viewHeight // tableHeader
        for sectionKey in model.sectionArr{
            height += EXIDAuthenticSectionHeaderView.getViewHeight(type: sectionKey) // sectionHeader
            if let dataList = model.dataList[sectionKey] {
                for data in dataList{
                    if data.type == .btn {
                        height += EXIDAuthenticListBtnCell.viewHeight
                    }else{
                        height += EXIDAuthenticListCell.viewHeight //cellHeight
                    }
                }
            }
        }
        
        height += 16.0 //bottomSpace
        return height
        
    }
    
    
    
    override func setUpView() {
        self.contentView.addSubview(tableView)
        
        
        self.contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.roundCorners(corners: .allCorners, radius: 4)
    }
    
    
    lazy var tableViewHeader: EXIDAuthenticStatusView = {
        let view = EXIDAuthenticStatusView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: EXIDAuthenticStatusView.viewHeight))
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .Ex.fill1
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 0
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(cellType: EXIDAuthenticListBtnCell.self)
        tableView.register(cellType: EXIDAuthenticListCell.self)
        tableView.register(EXIDAuthenticSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: sectionId)
        tableView.tableHeaderView = tableViewHeader
        return tableView
    }()
    
    
}

extension EXIDAuthenticMainCell: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.model?.sectionArr.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionKey = self.model?.sectionArr[section] else{
            return 0
        }
        guard let dataList = self.model?.dataList[sectionKey] else{
            return 0
        }
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
   
        if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionId) as? EXIDAuthenticSectionHeaderView{
            view.type = self.model?.sectionArr[section] ?? .right
            return view
        }
        return nil
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let sectionKey = self.model?.sectionArr[indexPath.section] else{
            return UITableViewCell()
        }
        guard let dataList = self.model?.dataList[sectionKey] else{
            return UITableViewCell()
        }
        let data = dataList[indexPath.row]
        
        if data.type == .btn {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EXIDAuthenticListBtnCell.self)
            cell.model = data
            cell.gotoKycBlock = { [weak self] in
                guard let `self` = self else { return }
                EXAuthenticManagerTool.gotoKyc(authModel: data)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EXIDAuthenticListCell.self)
        cell.model = data
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionKey = self.model?.sectionArr[section] else{
            return 0
        }
        return EXIDAuthenticSectionHeaderView.getViewHeight(type: sectionKey)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionKey = self.model?.sectionArr[indexPath.section] else{
            return 0
        }
        guard let dataList = self.model?.dataList[sectionKey] else{
            return 0
        }
        let data = dataList[indexPath.row]
        if data.type == .btn {
            return EXIDAuthenticListBtnCell.viewHeight
        }
        return EXIDAuthenticListCell.viewHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

