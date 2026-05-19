//
//  EXPosDetailPostionView.swift
//  Chainup
//
//  Created by lcus on 2023/10/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPosDetailPostionView: UIView {
    
    
    var dataEnity:EXPosDetailPostionEnity = EXPosDetailPostionEnity(){
        didSet {
            
            self.setTableFootView()
        }
    }
    var dataSouce:[[String:String]] = []{
        didSet {
            self.tableView.reloadData()
            
        }
    }
    var tableView:UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .plain)
//        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.ThemeNav.bg
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 80
        self .addSubview(tableView)

     
        let nibs = ["EXPosProjectInfoCell","EXPosProjectDesInfoCell","EXPosProgressCell","EXPosHeaderCell","EXPosNumberLockCell","EXPosCalculationCell","EXPosIncomeCell","EXPosIncomeTitleCell","EXPosEmptyCell"]
        for celltype in nibs {
            tableView.register(UINib.init(nibName: celltype, bundle: nil), forCellReuseIdentifier: celltype)
        }
        
        tableView.register(EXPosSetpCell.self, forCellReuseIdentifier: "EXPosSetpCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    
    }
    func setTableFootView(){
        
        let footView = EXPosDetailFootView()
        footView.setFootData(enity:dataEnity)
        let size = footView.systemLayoutSizeFitting(CGSize(width:UIScreen.main.bounds.size.width, height: 10000))
        footView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: size.height)
        
        tableView.tableFooterView = footView
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension EXPosDetailPostionView:UITableViewDataSource,UITableViewDelegate{
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let indexData =  self.dataSouce[indexPath.row]
        
        let cell = configData(tableView: tableView, cellData: indexData)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let indexData =  self.dataSouce[indexPath.row]
        let cellType = indexData["cellKey"]
        if cellType == "projectInfo"{
            return UITableView.automaticDimension
        }
        let h = EXPosDetailProtocolView.cellHeight(cellData: indexData)
        return h
        
    }
    func configData(tableView:UITableView,cellData:[String:String]) -> UITableViewCell {
        
        let cellType = cellData["cellKey"]
        
        switch cellType {
        case "coinInfo":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosProjectInfoCell") as! EXPosProjectInfoCell
            cell.setCellData(enity: dataEnity)
            return cell
        case "projectInfo":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosProjectDesInfoCell") as! EXPosProjectDesInfoCell
            cell.setCellData(enity: dataEnity)
            return cell
        case "progress":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosProgressCell") as! EXPosProgressCell
            return cell
        case "header":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosHeaderCell") as! EXPosHeaderCell
            cell.setCellData(enity: dataEnity, header: cellData)
            return cell
        case "NumberLock":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosNumberLockCell") as! EXPosNumberLockCell
            cell.setPostionCellData(enity: dataEnity)
            return cell
        case "income":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosIncomeCell") as! EXPosIncomeCell
            cell.setCellData(cellData:cellData)
            return cell
        case "incomeTitle":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosIncomeTitleCell") as! EXPosIncomeTitleCell
            cell.setCellConfig(config: cellData)
            return cell
        case "empty":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosEmptyCell") as! EXPosEmptyCell
            return cell
            
        default:
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
           return cell

        }
    }
    
    
    
}
