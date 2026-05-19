//
//  EXKlineDetailETFInfoView.swift
//  Chainup
//
//  Created by youbin on 2023/6/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXPagingView

class EXKlineDetailETFInfoView: EXTableView {
    
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
        tableView.register(TransactionETFInfoCell.self, forCellReuseIdentifier: NSStringFromClass(TransactionETFInfoCell.self))
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel?.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .KLineNetworth(let item):
                self.updateTable(item)
            default: break
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


extension EXKlineDetailETFInfoView {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TransactionETFInfoCell.self), for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionETFInfoCell.getHeightByContent("")
    }
}



extension EXKlineDetailETFInfoView {
    
    func updateTable(_ item:(CoinMapEntity, EXETFNetValueModel)) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TransactionETFInfoCell {
            cell.bindModel(item)
        }
    }
}




////////////////////////////////////////////////////////////
//MARK: JXPagingViewListViewDelegate
extension EXKlineDetailETFInfoView: JXPagingViewListViewDelegate {
    func listView() -> UIView {
        return self
    }
    
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.scrollCallback = callback
    }
    
    func listWillAppear() {
        if let _entity = self.viewModel?.entity {
            self.updateTable((_entity, self.viewModel?.networth ?? EXETFNetValueModel()))
        }
    }
}

