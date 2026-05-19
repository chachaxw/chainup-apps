//
//  EXAppMailView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

class EXAppMailView: UIView {
    
    var tableViewRowDatas : [EXAppMailEntity] = []
        
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXAppMailTC.classForCoder()], ["EXAppMailTC"])
        tableView.estimatedRowHeight = 100
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView])
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EXAppMailView : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXAppMailTC = tableView.dequeueReusableCell(withIdentifier: "EXAppMailTC") as! EXAppMailTC
        cell.setCell(entity)
        return cell
    }
    
}
