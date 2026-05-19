//
//  EXRewardListView.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXPagingView
import EXKit

class EXRewardListView: EXTableView {
    var rewadType: RewardType = .waitTowithDraw
    var vm: EXTaskViewModel?
    
    required init(viewModel: EXViewModelProtocol?) {
        self.vm = viewModel as? EXTaskViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    override func setupView() {
        super.setupView()
        self.backgroundColor = .Ex.fill2
        tableView.register(cellType: EXWaitToWithdrawCell.self)
        tableView.register(cellType: EXRewardDetailsCell.self)
        tableView.register(cellType: EXWithdrawRecoadCell.self)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 65
        tableView.mj_footer = EXRefreshFooterView (refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            self.vm?.getRewardCenterData(reward: self.rewadType)
        })
    }
}


extension EXRewardListView{
    
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rewadType == .rewadDetail {
            return vm?.userRewardRecoardData?.list?.count ?? 0
        }else if rewadType == .waitTowithDraw{
            return vm?.userRewardUnWithdrawalData?.unWithdrawList?.count ?? 0
        }else{
            return vm?.userRewardWithdrawalData?.list?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if rewadType == .rewadDetail {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EXRewardDetailsCell.self)
            cell.item = self.vm?.userRewardRecoardData?.list?[indexPath.row]
            return cell
        }else if rewadType == .waitTowithDraw{
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EXWaitToWithdrawCell.self)
            cell.item = self.vm?.userRewardUnWithdrawalData?.unWithdrawList?[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EXWithdrawRecoadCell.self)
            cell.withdraw = self.vm?.userRewardWithdrawalData?.list?[indexPath.row]
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if rewadType == .rewadDetail {
            return UITableView.automaticDimension
        }else{
            return 59
        }
    }
    
}


extension EXRewardListView: JXPagingViewListViewDelegate{
    func listView() -> UIView {
        return self
    }
    
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.scrollCallback = callback
    }
    func listWillAppear() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.tableView.reloadData()
        }
    }
    func listDidAppear(){
//        print("====>>>>>>>>>listDidAppear %@", transactionPriceType)
    }
    
    func listDidDisappear() {
//        print("====>>>>>>>>>listDidDisappear %@", transactionPriceType)
    }
    
    
}


extension EXRewardListView {
    
    override func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    
        let text = EXUIDatasource.shared.common_tip_nodata
        let attributeText = NSMutableAttributedString.init(string: text)
        let count = text.count
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center      //文本对齐方向
        var font = UIFont.Ex.medium(12)
    
        if let tipFont = scrollView.exemptyAttributeDict?[.tipFont] as? UIFont {
            font = tipFont
        }
        
        attributeText.addAttributes([kCTFontAttributeName as NSAttributedString.Key: font], range: NSMakeRange(0, count))
        
        var color = scrollView.fromKline ? UIColor.ThemekLine.labcolorDark : UIColor.ThemeLabel.colorDark
        if let tipColor = scrollView.exemptyAttributeDict?[.tipColor] as? UIColor {
            color = tipColor
        }
        attributeText.addAttributes([NSAttributedString.Key.foregroundColor as NSAttributedString.Key:color], range: NSMakeRange(0, count))
        return attributeText
    }
    
    
}
