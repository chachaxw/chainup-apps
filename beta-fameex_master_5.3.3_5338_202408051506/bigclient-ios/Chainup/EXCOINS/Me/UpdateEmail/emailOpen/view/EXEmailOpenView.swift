//
//  EXEmailOpenView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXEmailOpenView: UIView {

    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXEmailOpenTC.classForCoder()], ["EXEmailOpenTC"])
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

extension EXEmailOpenView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : EXEmailOpenTC = tableView.dequeueReusableCell(withIdentifier: "EXEmailOpenTC") as! EXEmailOpenTC
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EXEmailBindingVC()
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
