//
//  TableViewExt.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/7.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func adjustBehaviorDisable() {
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }else {
            
        }
    }
}

extension UITableView{
    
    func extSetTableView(_ delegate : Any ,_ dataSource : Any ,_ backgroundColor : UIColor = UIColor.ThemeView.bg , _ sepStyle : UITableViewCellSeparatorStyle = .none){
        self.delegate = delegate as? UITableViewDelegate
        self.dataSource = dataSource as? UITableViewDataSource
        self.backgroundColor = backgroundColor
        self.separatorStyle = sepStyle
    }
    
    func extRegistCell(_ cells : [AnyClass] , _ identifiers : [String]){
        for i in 0..<cells.count{
            self.register(cells[i], forCellReuseIdentifier: identifiers[i])
        }
    }
    
}

extension UITableViewCell{
    func extSetCell(_ backgroundColor : UIColor = UIColor.ThemeView.bg , selStyle : UITableViewCellSelectionStyle = .none){
        self.contentView.backgroundColor = backgroundColor
        self.selectionStyle = selStyle
    }
}

extension UITableView {
    
    func scroll(to: scrollsTo, animated: Bool) {
        let numberOfSections = self.numberOfSections
        let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
        switch to{
        case .top:
            if numberOfRows > 0 {
                 let indexPath = IndexPath(row: 0, section: 0)
                 self.scrollToRow(at: indexPath, at: .top, animated: animated)
            }
            break
        case .bottom:
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
            break
        }
    }

    enum scrollsTo {
        case top,bottom
    }
    
}
