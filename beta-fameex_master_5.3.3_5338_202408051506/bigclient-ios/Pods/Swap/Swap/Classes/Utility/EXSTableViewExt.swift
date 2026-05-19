//
//  TableViewExt.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/7.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit

extension UITableView{
    
    public func ext_SetTableView(_ delegate : Any ,_ dataSource : Any ,_ backgroundColor : UIColor = UIColor.ThemeView.bg , _ sepStyle :UITableViewCell.SeparatorStyle  = .none){
        self.delegate = delegate as? UITableViewDelegate
        self.dataSource = dataSource as? UITableViewDataSource
        self.backgroundColor = backgroundColor
        self.separatorStyle = sepStyle
    }
    
    public func ext_RegistCell(_ cells : [AnyClass] , _ identifiers : [String]){
        for i in 0..<cells.count{
            self.register(cells[i], forCellReuseIdentifier: identifiers[i])
        }
    }
    
}

extension UITableViewCell{
   public func ext_SetCell(_ backgroundColor : UIColor = UIColor.ThemeView.bg , selStyle : UITableViewCell.SelectionStyle = .none){
        self.contentView.backgroundColor = backgroundColor
        self.selectionStyle = selStyle
    }
}

