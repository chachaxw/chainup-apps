//
//  EXKlineDetailWarehouseRuleView.swift
//  Chainup
//
//  Created by youbin on 2023/6/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView

class EXKlineDetailWarehouseRuleView: EXTableView {
    
    var viewModel: EXKlineDetailNewViewModel?
    
    required init(viewModel: EXViewModelProtocol?) {
        self.viewModel = viewModel as? EXKlineDetailNewViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        tableView.register(EXKlineWarehouseRuleCell.self, forCellReuseIdentifier: NSStringFromClass(EXKlineWarehouseRuleCell.self))
        
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel?.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .KLineNetworth(let item):
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EXKlineWarehouseRuleCell {
                    cell.bindNetworth(item.1)
                }
                return
            default:
                break
            }
        }).disposed(by: self.disposeBag)

    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension EXKlineDetailWarehouseRuleView {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(EXKlineWarehouseRuleCell.self), for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return EXKlineWarehouseRuleCell.getHeightByContent("etf_notes_manual_lever_tran_info".localized())
    }
    
}


extension EXKlineDetailWarehouseRuleView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}

