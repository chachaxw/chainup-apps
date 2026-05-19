//
//  EXBtoCWithDrawVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXBtoCWithDrawVC: NavCustomVC {
    
    var entity = B2CCoinMapItem()
    {
        didSet{
            mainView.entity = entity
        }
    }
    
    lazy var mainView : EXBtoCwithDrawView = {
        let view = EXBtoCwithDrawView()
        view.extUseAutoLayout()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.addSubViews([mainView])
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        mainView.getFiltBlance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView.getUserBank()
    }
    
    override func setNavCustomV() {
        self.navtype = .list
        self.setTitle("b2c_text_withdraw".localized())
        self.xscrollView = mainView.tableView
        let btn = UIButton()
        btn.setTitle("b2c_text_withdrawRecord".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.layoutIfNeeded()
        btn.extUseAutoLayout()
        self.navCustomView.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.centerY.equalTo(self.navCustomView.popBtn)
            make.right.equalToSuperview().offset(-15)
        }
        btn.extSetAddTarget(self, #selector(clickBtn))
    }
    
    //Click on the button
    @objc func clickBtn(){
        let vc = BtoCwithDrawRecordVC()
        vc.type = "1"
        vc.symbol = entity.symbol
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

