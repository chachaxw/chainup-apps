//
//  EXTableView.swift
//  Chainup
//
//  Created by youbin on 2023/6/14.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class EXTableView: EXView {
    
    //Scroll callback block
    public var scrollCallback: ((UIScrollView) -> ())?
    
    lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.extUseAutoLayout()
        v.delegate   = self
        v.dataSource = self
        v.emptyDataSetDelegate = self
        v.emptyDataSetSource   = self
        v.estimatedRowHeight = 0
        v.estimatedSectionHeaderHeight = 0
        v.estimatedSectionFooterHeight = 0
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.backgroundColor = .clear
        v.separatorStyle  = .none
        v.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        return v
    }()
    
    override func setupView() {
        super.setupView()
        addSubViews([tableView])
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension EXTableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView)
    }
}


extension EXTableView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0.0
    }
    
}
