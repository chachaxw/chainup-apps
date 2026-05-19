//
//  EXFullScreenAlertVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/17.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXFullScreenAlertModel:EXBaseModel {
    var alertTitle:String = ""
    var alertMsg:String = ""
    var iconName:String = ""

    /*
Common_text_verifySuccessTitle "=" Certification passed! ";
Common_text_verifyAuthFailTitle "=" Authentication failed! ";
Common_text_verifyAuthFailMsg "=" The system will freeze the cash out for 24 hours! ";
Common_text_verifyAuthTimerMsg "=" Automatically exit in% @ seconds ";
     */
    
    static func failModelForAuth()->EXFullScreenAlertModel {
        let model = EXFullScreenAlertModel()
        model.iconName = "personal_failure"
        model.alertTitle = "common_text_verifyAuthFailTitle".localized()
        model.alertMsg = "common_text_verifyAuthFailMsg".localized()
        return model
    }
    
    static func successForAuth() -> EXFullScreenAlertModel {
        
        let model = EXFullScreenAlertModel()
        model.iconName = "personal_successfulhints"
        model.alertTitle = "common_text_verifySuccessTitle".localized()
        model.alertMsg = ""
        return model
    }
}

class EXFullScreenAlertVc: UIViewController,StoryBoardLoadable {
    
    typealias FullScreenAlertDismissedBlock = ()->()
    
    @IBOutlet var closeBtn: UIButton!
    @IBOutlet var iconImg: UIImageView!
    @IBOutlet var alertTitleLabel: UILabel!
    @IBOutlet var alertMsgLabel: UILabel!
    @IBOutlet var autoTImerLabel: UILabel!
    @IBOutlet var msgView: UIView!
    var disposable: Disposable? = nil
    var dismissBlock:FullScreenAlertDismissedBlock?

    var alertModel:EXFullScreenAlertModel = EXFullScreenAlertModel()
    
    func handleUI(){
        alertTitleLabel.textColor = UIColor.ThemeLabel.colorLite
        alertTitleLabel.font = UIFont.ThemeFont.H3Bold
        alertMsgLabel.textColor = UIColor.ThemeLabel.colorLite
        autoTImerLabel.textColor = UIColor.ThemeLabel.colorMedium
        closeBtn.setImage(UIImage.themeImageNamed(imageName: "personal_shutdown_daytime"), for: .normal)
        leftTime(time: "3")
        closeBtn.rx.tap
               .asObservable()
               .throttle(.seconds(1), scheduler: MainScheduler.instance)
               .subscribe(onNext: { [weak self] _ in
                   guard let `self` = self else { return }
                   self.alertDissMiss()
               }).disposed(by: self.disposeBag)

    }
    
    func leftTime(time:String) {
        let left = String(format:"common_text_verifyAuthTimerMsg".localized(),time)
        autoTImerLabel.text = left
    }
    
    func startTimer(){
        self.disposable?.dispose()
        self.disposable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                let left = 3 - element
                self.leftTime(time: "\(left)")
                if element == 3 {
                    self.alertDissMiss()
                }
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
        handleUI()
        bindAlertModel(self.alertModel)
    }
    
    func bindAlertModel(_ model:EXFullScreenAlertModel) {
        iconImg.image = UIImage.themeImageNamed(imageName: model.iconName)
        alertTitleLabel.text = model.alertTitle
        msgView.isHidden = model.alertMsg.isEmpty
        alertMsgLabel.text = model.alertMsg
    }
    
    
    func alertDissMiss() {
        self.dismissBlock?()
        self.disposable?.dispose()
        self.dismiss(animated: false, completion:nil)
    }

}

