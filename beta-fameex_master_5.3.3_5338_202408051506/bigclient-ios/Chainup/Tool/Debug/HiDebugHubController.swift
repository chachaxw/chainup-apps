//
//  HiDebugHubController.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class HiDebugHubController: UIViewController,StoryBoardLoadable {
    
    @IBOutlet var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "debug"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableview  .reloadData()
    }
    
    @IBAction func close(_ sender: Any) {
    self.navigationController? .dismiss(animated: true, completion: nil)
    }
}



extension HiDebugHubController : UITableViewDelegate {
    
}

extension HiDebugHubController : UITableViewDataSource {
    
    func hidebugSources() -> [String] {
        return [""]
    }
    
    func hidebugValues() -> [String] {
        return ["",
                "","","",""]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hidebugSources().count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = self.hidebugSources()[indexPath.row]
        let detail = self.hidebugValues()[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "HiDebugHubCell", for: indexPath) as! HiDebugHubCell
        cell.titleLabel.text = title
        cell.detailLabel.text = detail
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            self .performSegue(withIdentifier: "ui_segue_key", sender: nil)
        }else if indexPath.row == 2 {

            let testv = EXCapchaView()
            EXAlert.showAlert(alertView: testv)
        }else if indexPath.row == 0 {
//            fatalError()
            EXNetworkDoctor.sharedManager.configNetWork()
        }else if indexPath.row == 3 {
            let datavc = EXPublicInfo.init()
            self.navigationController?.pushViewController(datavc, animated: true)
        }else if indexPath.row == 4 {
            let datavc = HiDebugApiVC.init()
            self.navigationController?.pushViewController(datavc, animated: true)
        }else {
            self .performSegue(withIdentifier: "api_segue_key", sender: nil)
        }
    }
}

