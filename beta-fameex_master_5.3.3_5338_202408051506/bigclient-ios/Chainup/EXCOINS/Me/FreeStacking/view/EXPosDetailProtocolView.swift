//
//  EXPosDetailProtocolView.swift
//  Chainup
//
//  Created by lcus on 2023/10/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPosDetailProtocolView: UIView {

    var dataEnity:EXPosDetailProtocolEnity = EXPosDetailProtocolEnity()
    var dataSouce:[[String:String]] = []{
        didSet {
            self.tableView.reloadData()
            self.setTableFootView()
        }
    }
    var tableView:UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        self .addSubview(tableView)
        
    
        let nibs = ["EXPosProjectInfoCell","EXPosProjectDesInfoCell","EXPosProgressCell","EXPosHeaderCell","EXPosNumberLockCell","EXPosCalculationCell","EXPosIncomeCell","EXPosWllIncomeCell","EXPosIncomeTitleCell","EXPosEmptyCell"]
        for celltype in nibs {
            tableView.register(UINib.init(nibName: celltype, bundle: nil), forCellReuseIdentifier: celltype)
        }
        
        tableView.register(EXPosSetpCell.self, forCellReuseIdentifier: "EXPosSetpCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        

    }
    func setTableFootView(){
     
//        if tableView.tableFooterView != nil && (self.dataEnity.activeStatus == 1 && self.dataEnity.isShowBuy == 1){
//            return
//
//        }
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
extension EXPosDetailProtocolView:UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let indexData =  self.dataSouce[indexPath.row]
        let h = EXPosDetailProtocolView.cellHeight(cellData: indexData)
        return h
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let indexData =  self.dataSouce[indexPath.row]
        
        let cell = configData(tableView: tableView, cellData: indexData)
        
        return cell
        
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
            cell.setCellData(enity:dataEnity)
            return cell
        case "header":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosHeaderCell") as! EXPosHeaderCell
            cell.setCellData(enity: dataEnity, header: cellData)
            return cell
        case "setp":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosSetpCell") as! EXPosSetpCell
            cell.setCellData(enity: dataEnity)
            return cell
        case "calculation":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosCalculationCell") as! EXPosCalculationCell
            cell.setPorotolCellData(enity:dataEnity)
            return cell
        case "NumberLock":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosNumberLockCell") as! EXPosNumberLockCell
//            cell.setPostionCellData(enity: dataEnity)
            cell.setProtocol(enity: dataEnity, dataConfig: cellData)
            return cell
        case "income":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosIncomeCell") as! EXPosIncomeCell
            cell.setCellData(cellData:cellData)
            return cell
        case "willicome":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosWllIncomeCell") as! EXPosWllIncomeCell
            cell.setCelleData(enity: dataEnity)
            return cell
        case "incomeTitle":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosIncomeTitleCell") as! EXPosIncomeTitleCell
            cell.setCellConfig(config: cellData)
            return cell
        case "empty":
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXPosEmptyCell") as! EXPosEmptyCell
            return cell
        default:
            
            return tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
            
        }
    }
    
    
    class func cellHeight(cellData:[String:String]) -> CGFloat {
        let cellType = cellData["cellKey"]
        var height: CGFloat = 44
        switch cellType {
        case "coinInfo":
            height = 85 //EXPosProjectInfoCell
        case "projectInfo":
            height = 72 //EXPosProjectDesInfoCell
        case "progress":
            height = 95 //EXPosProgressCell
        case "header":
            height = 60 //EXPosHeaderCell
        case "setp":
            height = 75 //EXPosSetpCell
        case "calculation":
            height = UITableView.automaticDimension
            /*height = 150*/ //EXPosCalculationCell
        case "NumberLock":
            height = 86 //EXPosNumberLockCell
        case "income":
            height = 44 // EXPosIncomeCell
        case "willicome":
            height = 44.5 // EXPosWllIncomeCell
        case "incomeTitle":
            height = 44 //
        case "empty":
            height = 160 //   EXPosEmptyCell
        default:
            break
            
        }
        return height
    }
}
