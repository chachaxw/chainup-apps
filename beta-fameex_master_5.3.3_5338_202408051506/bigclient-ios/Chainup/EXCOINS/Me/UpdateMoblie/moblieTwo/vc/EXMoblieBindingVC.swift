//
//  EXMoblieTwoVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXMoblieBindingVC : NavCustomVC {

     typealias ClickBlock = () -> ()
     var clickBlock : ClickBlock?
    
    lazy var mainView : EXMoblieBindingView = {
        let view = EXMoblieBindingView()
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
    }
    
    override func setNavCustomV() {
        if UserInfoEntity.sharedInstance().mobileNumber == ""{
            /*
If only email registration is enabled and no phone is bound, and Google is not bound, pop up the box
             */
            if EXAppConfigManager.sharedInstance.getSupportRegistTypes() == ["2"] && UserInfoEntity.sharedInstance().didBindGoolge() == false{
                bindGoogleOrMobliePrompt()
            }
            self.setTitle(LanguageTools.getString(key: "otcSafeAlert_action_bindphone"))
        }else{
            self.setTitle(LanguageTools.getString(key: "safety_action_editPhone"))
        }
        self.xscrollView = mainView.tableView
        self.lastVC = true
    }
    
    //Bind Google or mobile prompts
    func bindGoogleOrMobliePrompt(){
        
        let view = EXNormalAlert()
        view.configAlert(title: "",message:"common_tip_logoutDesc".localized())
        view.configAlert(title: "", message: "common_text_bindPhonePrompt".localized(), passiveBtnTitle: "common_text_stillBindPhone".localized(), positiveBtnTitle: "otcSafeAlert_action_bindGoogle".localized())
        view.alertCallback = {[weak self](tag) in
            if tag == 0{
                self?.navigationController?.popViewController(animated: false)
                self?.clickBlock?()
            }
        }
        EXAlert.showAlert(alertView: view)
        
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

