//
//  ReLoginVC.swift
//  Chainup
//
//  Created by xue on 2018/11/19.
//  Copyright © 2018 zewu wang. All rights reserved.
//

import UIKit

class ReLoginVC: NavCustomVC {

    @IBOutlet weak var titleL: UILabel!
   
    @IBOutlet weak var contentL: UILabel!
    
    @IBOutlet weak var click: UIButton!
    
    
    lazy var navRightBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.extSetTitle(LanguageTools.getString(key: "login_account"), 14, UIColor.ThemeView.highlight, UIControlState.normal)
        btn.extSetAddTarget(self, #selector(clickNavRightBtn))
        return btn
    }()
    override func setNavCustomV() {
        navCustomView.addSubview(navRightBtn)
       
        navRightBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(17)
            make.width.lessThanOrEqualTo(200)
        }
    }
    
    //MARK: Click on the fund flow
    @objc func clickNavRightBtn(){

        popBack()
        BusinessTools.modalLoginVC("1")
        
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentView.isHidden = true
        
        self.clickCert(click)
        FingerPrintVerify.fingerIsSupportCallBack { (type) in
            
            
            if type == "1"{
                
                self.titleL.text = LanguageTools.getString(key: "Fingerprint_identification")
                self.contentL.text = LanguageTools.getString(key: "click_fingerprint_identification")
                self.click.setImage(UIImage.init(named: "ic_fingerprint_identification"), for: UIControlState.normal)
            }else if type == "2"{
                self.titleL.text = LanguageTools.getString(key: "Face_recognition")
                self.contentL.text = LanguageTools.getString(key: "click_face_recognition")
                self.click.setImage(UIImage.init(named: "ic_face_recognition"), for: UIControlState.normal)

            }
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func clickCert(_ sender: Any) {
   
        
        FingerPrintVerify.fingerPrintLocalAuthenticationFallBackTitle(LanguageTools.getString(key: "login_action_oneClick"), localizedReason: LanguageTools.getString(key: "login_action_oneClick")) { (success, error, errorStr) in
            print("---------")
            
            if success == true{
                
                var params : [String:Any] = [:]
                
                let entity = UserInfoEntity.sharedInstance()
                
                params["countryCode"] = entity.countryCode
                params["mobileNumber"] = XUserDefault.getVauleForKey(key: XUserDefault.mobileNumber)

                let param = NetManager.sharedInstance.handleParamter(params)
                let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.user, action: NetDefine.login_AI)

//                let url = NetManager.sharedInstance.url(NetDefine.http_host_url, model: NetDefine.user, action: NetDefine.login_AI)
                
                NetManager.sharedInstance.sendRequest(url,parameters : param, success: { (result, response, entity) in
                        if let result = result as? [String : Any]{
                            
                            
                            if let data = result["data"] as? [String : Any]{
                                
                                if let token = data["token"] as? String{
                                   
                                    XUserDefault.setLoginTime()//Set login time

                                    XUserDefault.setValueForKey(token, key: XUserDefault.token)
                                    XUserDefault.setFaceIdOrTouchId("100")

                                    self.dismiss(animated: true, completion: nil)
                                    ProgressHUDManager.showSuccessWithStatus(errorStr ?? "")

                                }else{
                                    ProgressHUDManager.showFailWithStatus(errorStr ?? "")

                                }
                            }else{
                                ProgressHUDManager.showFailWithStatus(errorStr ?? "")

                            }
                            

                        }
                    }, fail: { (state, error, any) in
                        
                })
                
            }else{
                ProgressHUDManager.showFailWithStatus(errorStr ?? "")

            }
            
            print(error)
        }
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

