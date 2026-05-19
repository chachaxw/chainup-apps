//
//  EXReLoginVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXReLoginVC: NavCustomVC {
    
    //Cancel button
    lazy var cancelBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
        btn.setTitle(LanguageTools.getString(key: "common_text_btnCancel"), for: UIControl.State.normal)
        btn.contentHorizontalAlignment = .left
        btn.extSetAddTarget(self, #selector(clickCancelBtn))
        return btn
    }()
    
    lazy var mainView : EXReLoginView = {
        let view = EXReLoginView()
        view.extUseAutoLayout()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func setNavCustomV() {
        self.navCustomView.backgroundColor = UIColor.ThemeView.bg
        self.navCustomView.popBtn.isHidden = true
        self.navCustomView.backView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(200)
            make.height.equalTo(16)
        }
    }
    
    @objc func clickCancelBtn(){
//        UserInfoEntity.sharedInstance().clearQuickToken()
        guard let _ = BusinessTools.getRootNavBar()else{
            return
        }
        if let _ = BusinessTools.getRootTabbar(){
            if XUserDefault.getToken() == nil{
                popBack()
            }else{
                popBack()
            }
        }else{
            popBack()
        }
        BusinessTools.logoutNet()
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

