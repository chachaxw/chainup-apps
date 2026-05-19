//
//  EXPaylistView.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/28.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXPaylistView: UIView {
    
   private let cellid: String = "EXPayItemCell"
    var currentCell: EXPayItemCell?
    var vm = EXCreditCardViewModel(){
        didSet{
            tableView.reloadData()
        }
    }
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.Ex.fill2
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
//        tableView.rowHeight = 270
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 270
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(EXPayItemCell.self, forCellReuseIdentifier: cellid)
        return tableView
    }()
    override init(frame: CGRect){
        super.init(frame: frame)
        self.addSubViews([tableView])
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buy(){
        
    }
    
}
extension EXPaylistView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.payListData?.paycard_list?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath) as! EXPayItemCell
        let m = self.vm.payListData?.paycard_list?[indexPath.row]
        cell.vm = self.vm
        cell.model = m
        cell.buyBlock = { [weak self,weak cell] item in
            
            guard let strong = self else {return}
            guard let newCell = cell else {return}
            newCell.buyBtn.isEnabled = false
            strong.currentCell = newCell
            strong.submit(model: item)
        }
        return cell
    }
    
    func submit(model: EXPayServiceinfo){
        vm.submitOrder(pay: model, success: {
            [weak self]  in
               guard let `self` = self else { return }
              self.currentCell?.buyBtn.isEnabled = true
               let vc = EXJumpTipViewController()
               self.vm.payResult?.serviceName = model.name
               vc.model = self.vm.payResult
               TopVC()?.navigationController?.pushViewController(vc, animated: true)
        }) {
            [weak self]  in
             guard let `self` = self else { return }
            self.currentCell?.buyBtn.isEnabled = true
        }
    }
}
