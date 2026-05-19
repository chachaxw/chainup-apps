//
//  EXBtoCwithDrawAccountListVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXBtoCwithDrawAccountListVC: NavCustomVC {
    
    lazy var mainView : EXBtoCwithDrawAccountListV = {
        let mainView = EXBtoCwithDrawAccountListV()
        mainView.extUseAutoLayout()
        return mainView
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
        self.xscrollView = mainView.tableView
        self.navtype = .list
        self.setTitle("b2c_text_withdrawAccountList".localized())
        let addBtn = UIButton()
        addBtn.extUseAutoLayout()
        addBtn.layoutIfNeeded()
        addBtn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        addBtn.setTitle("payMethod_action_addnew".localized(), for: UIControl.State.normal)
        addBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
        navCustomView.addSubview(addBtn)
        addBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(navCustomView.popBtn)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(20)
        }
        addBtn.extSetAddTarget(self, #selector(clickAddBtn))
    }
    
    //Click on the add button
    @objc func clickAddBtn(){
        let vc = EXBtoCwithDrawAddAccountVC()
        vc.mainView.needContentBlock = {[weak self] in
            self?.mainView.headRefresh()
        }
        vc.mainView.symbol = mainView.entity.symbol
        vc.type = .add
        vc.setTitle("b2c_text_addWithdrawAccount".localized())
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

