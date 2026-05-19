//
//  EXIDAuthenticView.swift
//  Chainup
//
//  Created by cwd on 2023/11/1.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXIDAuthenticMainView: EXCustomBaseView {
    var dataList: [EXIDAuthenticModel]? {
        didSet{
            tableView.reloadData()
        }
    }
    
    
    override func setSubView() {
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .Ex.fill2
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 0
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(cellType: EXIDAuthenticMainCell.self)
        return tableView
    }()

}

extension EXIDAuthenticMainView: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EXIDAuthenticMainCell.self)
        cell.model = self.dataList?[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = self.dataList?[indexPath.row]
        return EXIDAuthenticMainCell.getCellHeight(model: data)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

