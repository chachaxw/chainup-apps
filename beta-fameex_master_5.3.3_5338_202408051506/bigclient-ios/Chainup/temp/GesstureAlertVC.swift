//
//  GesstureAlertVC.swift
//  Chainup
//
//  Created by xue on 2023/11/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class GesstureAlertVC: BaseVC {
    
    var type = "0"
    
    lazy var titleL: UILabel = {
        let v = UILabel(font: .Ex.medium(28), textColor: .Ex.text1)
        v.extUseAutoLayout()
        return v
    }()
    
    lazy var detailL: UILabel = {
        let v = UILabel(font: .Ex.medium(20), textColor: .Ex.text1, alignment: .center)
        v.extUseAutoLayout()
        v.numberOfLines = 2
        return v
    }()
    
    lazy var IMG: UIImageView = {
        let v = UIImageView()
        v.extUseAutoLayout()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    lazy var statusLabel : UILabel = {
        let v = UILabel(font: .Ex.medium(14), textColor: .Ex.text1)
        v.extUseAutoLayout()
        v.numberOfLines = 2
        return v
    }()
    
    lazy var enableButon: EXButton = {
        let v = EXButton(type: .custom)
        v.setTitle("safety_action_activeFaceId".localized(), for: .normal)
        return v
    }()
    
    lazy var remindButton: EXButton = {
        let v = EXButton(type: .custom)
        v.selectStyle = .blueTextColor
        v.setTitle("safety_action_faceIdNextTime".localized(), for: .normal)
        return v
    }()
    
    lazy var closeButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setEnlargeEdgeWithTop(4, left: 8, bottom: 4, right: 8)
        v.setImage(EXKitBundle.image(named: "public_close"), for: .normal)
        v.imageView?.contentMode = .scaleAspectFit
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubViews([closeButton,
                          titleL, detailL,
                          IMG, statusLabel,
                          enableButon, remindButton])
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(getStatusHeight2())
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.width.lessThanOrEqualTo(44)
        }
        
        ///
        titleL.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(126)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.915)
        }
        detailL.snp.makeConstraints { make in
            make.top.equalTo(titleL.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.915)
        }
        
        ///
        IMG.snp.makeConstraints { make in
            make.top.equalTo(detailL.snp.bottom).offset(118)
            make.centerX.equalToSuperview()
            make.size.lessThanOrEqualTo(CGSize(width: 140, height: 140))
        }
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(IMG.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.915)
        }
        ///
        enableButon.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(statusLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.915)
            make.height.equalTo(44)
        }
        remindButton.snp.makeConstraints { make in
            make.top.equalTo(enableButon.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(enableButon)
            make.bottom.equalToSuperview().offset(-(max(getSafeAreaBottom(), 0) + 22))
        }
        
        //// the part of event
        FingerPrintVerify.fingerIsSupportCallBack {[weak self] (type) in
            guard let self else { return }
            if type == "1" {
                self.updateConfigDataByIfNeed("1")
                self.type = "1"
            }else if type == "2"{
                self.updateConfigDataByIfNeed("2")
                self.type = "2"
            } else {
                self.updateConfigDataByIfNeed("3")
                self.type = "3"
            }
        }
        
        enableButon.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
            guard let self else { return }
            self.updateSettingIfNeed()
        }).disposed(by: disposeBag)
        
        remindButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
            guard let self else { return }
            self.updateRemindIfNeed()
        }).disposed(by: disposeBag)
        
        closeButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
            guard let self else { return }
            self.updateRemindIfNeed()
        }).disposed(by: disposeBag)
        
        // Do any additional setup after loading the view.
    }
    
    func updateSettingIfNeed() {
        
        if type == "1" || type == "2"{
            FingerPrintVerify.fingerPrintLocalAuthenticationFallBackTitle("login_action_oneClick".localized(),
                                                                          localizedReason: "login_action_oneClick".localized()) { [weak self] (success, error, alert) in
                guard let self else { return }
                if success == true{
                    XUserDefault.setFaceIdOrTouchId("100")
                    EXAlert.showSuccess(msg: alert ?? "")
                    self.navigationController?.popViewController(animated: true)
                }else{
                    EXAlert.showFail(msg: alert ?? "")
                }
            }
        }else if type == "3"{
            let onevc = GestureValidationVC()
            onevc.type = GestureValidationType.loginSet
            onevc.confirmGesturesBlock = {[weak self](password) in
                guard let self else { return }
                let twovc = GestureValidationVC()
                twovc.confirmGesturesCompleteBlock = {() in
                    self.navigationController?.popViewController(animated: true)
                }
                twovc.type = GestureValidationType.loginSetAgain
                twovc.code = password
                onevc.popBack(false)
                self.navigationController?.pushViewController(twovc, animated: true)
            }
            self.navigationController?.pushViewController(onevc, animated: true)
        }
    }
    
    func updateConfigDataByIfNeed(_ type:NSString){
        let userAccount = UserInfoEntity.sharedInstance().userAccount
        if type == "1"{
            self.statusLabel.text = "Touch-ID"
            self.titleL.text = "login_text_fingerprint".localized()
            self.detailL.text = userAccount
            self.IMG.image = EXKitBundle.image(named: "fingerprint")
        }else if type == "2"{
            self.statusLabel.text = "Face-ID"
            self.titleL.text = "safety_text_faceId".localized()
            self.detailL.text = userAccount
            self.IMG.image =   EXKitBundle.image(named: "faceid")
        }else if type == "3"{
            self.statusLabel.text = ""
            self.titleL.text = "safety_text_gesturePassword".localized()
            self.detailL.text = userAccount
        }
    }
    
    func updateRemindIfNeed() {
        XUserDefault.setNextRemind()
        self.navigationController?.popViewController(animated: true)
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

