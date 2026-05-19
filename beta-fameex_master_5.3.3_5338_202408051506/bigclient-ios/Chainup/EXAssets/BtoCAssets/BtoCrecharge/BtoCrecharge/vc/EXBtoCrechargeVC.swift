//
//  EXBtoCrechargeVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXBtoCrechargeVC: NavCustomVC {
    
    var entity = B2CCoinMapItem()
    {
        didSet{
            mainView.entity = self.entity
        }
    }
    
    lazy var mainView : EXBtoCrechargeV = {
        let view = EXBtoCrechargeV()
        view.extUseAutoLayout()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        mainView.getData()
    }
    
    override func setNavCustomV() {
        self.navtype = .list
        self.xscrollView = mainView.tableView
        self.setTitle("b2c_text_recharge".localized())
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setTitle("b2c_text_rechargeRecord".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.layoutIfNeeded()
        self.navCustomView.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(self.navCustomView.popBtn)
            make.height.equalTo(20)
        }
        btn.extSetAddTarget(self, #selector(clickBtn))
    }
    
    @objc func clickBtn(){
        let vc = EXBtoCrechargeRecordVC()
        vc.type = "0"
        vc.symbol = entity.symbol
        self.navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
