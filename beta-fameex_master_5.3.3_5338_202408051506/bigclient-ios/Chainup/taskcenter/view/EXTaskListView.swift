//
//  EXTaskListView.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXPagingView

class EXTaskListView: EXTableView {
//    var collectionRewardCallBack: ((EXTaskItemModel?) -> ())?
    var taskType:  TaskType = .all
    var vm:EXTaskViewModel?
    var tasklist: [EXTaskItemModel?]? {
        switch self.taskType {
        case .all:
            return self.vm?.allTasklist
        case .novice:
            return self.vm?.noviceTasklist
        case .daily:
            return self.vm?.dailyTasklist
        }
    }
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
        tableView.register(cellType: EXTaskDescribeCell.self)
        tableView.register(cellType: EXNoviceTaskCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
    }

}


extension EXTaskListView{
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.taskType == .all {
            var count = (self.tasklist?.count ?? 0 )
            if count > 0 {
                count += 1 //all need title as spaceView
            }
            return count
        }else{
            var count = (self.tasklist?.count ?? 0 )
            if count > 0 {
                count += 1
            }
            return count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EXTaskDescribeCell.self)
            cell.content = self.vm?.taskHome?.getTaskDescribe(taskType: self.taskType)
            cell.bgview.isHidden = self.taskType == .all
            return cell
        }
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EXNoviceTaskCell.self)
        cell.taskItem = self.tasklist?[indexPath.row-1]
        cell.collectionRewardCallBack = { [weak self] selectedTask  in
            guard let `self` = self else { return }
//            self.collectionRewardCallBack?(selectedTask)
            self.vm?.collectTaskRewards(taskid: String(selectedTask?.id ?? 0))
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.taskType == .all {
            if indexPath.row == 0 {
                return 20
            }
        }
        return UITableView.automaticDimension
    }
}


extension EXTaskListView: JXPagingViewListViewDelegate{
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

extension EXTaskListView {
 
    override func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "rewardCenter_text20".localized() + "\n" + "rewardCenter_text21".localized()
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

