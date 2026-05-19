//
//  EXPosIncomeVC.swift
//  Chainup
//
//  Created by lcus on 2023/9/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//Revenue List

import UIKit
import EXKit
class EXPosIncomeVC: UIViewController,StoryBoardLoadable,NavigationPlugin,EXEmptyDataSetable{
    
    var dataSouce:[UserGainList] = []
    
    var baseCoin: String = ""
    
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll:self.tableView, presenter: self)
        return nav
    }()
    func largeTitleValueChanged(height: CGFloat) {
         self.top.constant = height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.separatorColor = UIColor.ThemeNav.bg
        tableView.register(UINib.init(nibName: "EXPosIncomeTitleCell", bundle: nil), forCellReuseIdentifier: "EXPosIncomeTitleCell")
        let userAgernt = UserGainList()
        tableView.separatorStyle = .none
        if dataSouce.count > 0 {
          
            userAgernt.special = "title"
            userAgernt.gainTime = "pos_string_timeEarn".localized()
            userAgernt.gainAmount = "pos_string_earnNumber".localized() + (baseCoin.isEmpty ? "" : "(\(baseCoin))")
            dataSouce.insert(userAgernt, at: 0)
        }
      
        self.configNavigation()
        self.exEmptyDataSet(self.tableView)
    }
    func configNavigation() {
        
        self.navigation.setTitle(title: "pos_string_earnDetail".localized())
        self.navigation.navtype = .list
    }

   

}

extension EXPosIncomeVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSouce.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userAgent = dataSouce[indexPath.row]
        
        if userAgent.special != nil {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosIncomeTitleCell") as! EXPosIncomeTitleCell
            cell.setCellData(enity: userAgent)
            return cell

        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "income") as! EXIncomeCell
        cell.setCellData(enity: userAgent)
        return cell
        
    }
    
}

