//
//  EXContractInfTableViewController.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/6.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
struct EXContractInfo {
    var name = ""
    var describe = ""
}
class EXContractInfoTableViewController: ListBaseViewController {

    var marginRateInfo = EXContractInfo.init(name: "cp_contract_info_text11".ex_localized(), describe: "")

    var currentItemModel:EXSwapItemModel? {
        didSet {
            EXContractNetwork.getLadderInfo(contractId: currentItemModel?.instrument_id ?? 0) { (info) in
                //没办法，这里service返回就是这样 第一个ladderList其实是字典 English: There's no way, the service returns like this. The first ladderList is actually a dictionary
                if let rate = info.ladderList.ladderList.first?.minMarginRate {
                    
                    self.marginRateInfo.describe = rate.toPercentString(2)
                }
                self.contentTableView.reloadData()
            } failure: { (error) in
                
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
        
       
    }
    
    var infoList:[EXContractInfo] {
        get {
            
            if let model =  currentItemModel,let contractInfo = model.ex_contractInfo {
                
                return [
                    EXContractInfo.init(name: "cp_contract_info_text5".ex_localized(), describe: contractInfo.showName()),
                    EXContractInfo.init(name: "cp_contract_info_text6".ex_localized(), describe: contractInfo.deliveryKindIntroduce) ,
                    EXContractInfo.init(name: "cp_contract_info_text7".ex_localized(), describe: model.symbol + "cp_contract_info_text13".ex_localized()) ,
                    EXContractInfo.init(name: "cp_contract_info_text8".ex_localized(), describe: contractInfo.marginCoin) ,
                    EXContractInfo.init(name: "cp_contract_info_text9".ex_localized(), describe:  (contractInfo.face_value)  + (contractInfo.base_coin )) ,
                    EXContractInfo.init(name: "cp_contract_info_text10".ex_localized(), describe: (contractInfo.px_unit ) + contractInfo.quote_coin),
                    marginRateInfo
                ]
            }
            return [EXContractInfo]()
        }
        
    }

    let cellReUseID = "cellReUseID"
    lazy var contentTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.rowHeight = 52
        tableView.ext_SetTableView(self, self)
//        tableView.tableHeaderView = self.tableHeaderView
        tableView.ext_RegistCell([EXSBaseInfoTC.classForCoder()], [cellReUseID])
//        tableView.mj_header = EXRefreshHeaderView(refreshingBlock: {
//            [weak self] in
//            guard let mySelf = self else { return }
//            mySelf.requestHistoryData(instrument_id: mySelf.itemMdoel?.instrument_id ?? 0, oid: self?.orderModel?.oid ?? 0)
//        })
        tableView.tableHeaderView = header
        return tableView
    }()
    
    lazy var header: UIView = {
       let v = UIView(frame: CGRect(x: 0, y: 0, width: EXSCREEN_WIDTH, height: 10))
        v.backgroundColor = UIColor.ThemeView.bg
      return v
    }()
    // MARK: - Table view data source
    private func initLayout() {
        self.view.addSubview(contentTableView)
        self.contentTableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
}

extension EXContractInfoTableViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return infoList.count
    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReUseID, for: indexPath) as! EXSBaseInfoTC
        
        cell.nameLabel.text = infoList[indexPath.row].name
        cell.infoLabel.text = infoList[indexPath.row].describe

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}

