//
//  EXBtoCwithDrawAddAccountVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXBtoCwithDrawAddAccountType {
    case editor//edit
    case add//Add
}

class EXBtoCwithDrawAddAccountVC: NavCustomVC {
    
    var type = EXBtoCwithDrawAddAccountType.add
    {
        didSet{
            self.mainView.type = self.type
            mainView.setData()
            mainView.getData()
        }
    }
    
    var titleStr = ""
    {
        didSet{
            self.setTitle(titleStr)
        }
    }
    
    lazy var deleteBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
        btn.setTitle("address_action_delete".localized(), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickDeleteBtn))
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.layoutIfNeeded()
        return btn
    }()

    lazy var mainView : EXBtoCwithDrawAddAccountV = {
        let mainView = EXBtoCwithDrawAddAccountV()
        mainView.extUseAutoLayout()
        return mainView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.addSubViews([mainView])
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        mainView.setView()
    }
    
    override func setNavCustomV() {
        if type == .editor{
            self.navCustomView.addSubview(deleteBtn)
            deleteBtn.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalTo(self.navCustomView.popBtn)
                make.height.equalTo(17)
            }
        }
        self.lastVC = true
        self.navtype = .list
        self.xscrollView = mainView.tableView
    }
    
    //Click the delete button
    @objc func clickDeleteBtn(){
        appApi.rx.request(.deleteUserBank(id: mainView.id)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: {[weak self] (m) in
            EXAlert.showSuccess(msg: "b2c_text_deleteSuccess".localized())
            self?.mainView.needContentBlock?()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.navigationController?.popViewController(animated: true)
            }
        }) { (erro) in
            
            }.disposed(by: disposeBag)
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

