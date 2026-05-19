//
//  EXKlineDetailBriefView.swift
//  Chainup
//
//  Created by youbin on 2023/6/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXPagingView

class EXKlineDetailBriefView: EXTableView {
    
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
        tableView.register(EXKlineCoinBriefCell.self, forCellReuseIdentifier: NSStringFromClass(EXKlineCoinBriefCell.self))
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        self.viewModel?.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            
            case .KLineCoinBrief(_):
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
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

extension EXKlineDetailBriefView {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(EXKlineCoinBriefCell.self), for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let briefCell = cell as! EXKlineCoinBriefCell
        briefCell.setCoinBrief(brief:self.viewModel?.coinBrief)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var text = ""
        if let _brief = self.viewModel?.coinBrief {
            text = _brief.introduction
        }
        return EXKlineCoinBriefCell.getHeightByContent(text)
    }

}






extension EXKlineDetailBriefView: JXPagingViewListViewDelegate{
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
       
        if let _brief = self.viewModel?.coinBrief, _brief.coinSymbol.isEmpty {
            self.viewModel?.requestCoinBrief()
        }
    }
    
}
