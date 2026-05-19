//
//  EXCoinWithdrawVerifyVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/17.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

class EXCoinWithdrawVerifyVc: BaseVC,StoryBoardLoadable,NavigationPlugin {
    @IBOutlet var topConstraints: NSLayoutConstraint!
    @IBOutlet var footer: EXCoinWithdrawFooter!
    @IBOutlet var nameInputView: EXVerifyInputView!
    @IBOutlet var idInputView: EXVerifyInputView!
    @IBOutlet var errorMsgView: UIView!
    @IBOutlet var errorMsgLabel: UILabel!
    @IBOutlet var errorMsgHeight: NSLayoutConstraint!
    
    var userModel:EXIdentityAuthInfoModel = EXIdentityAuthInfoModel()
    var name:String = ""
    var idnumber:String = ""
    var withdrawID:String = ""
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll:nil, presenter: self)
        nav.customBack = true
        nav.customBackCallback = {[weak self] in
            self?.customBack()
        }
        return nav
     }()
    
    
    func handleNavigation() {
        self.navigation.isLastNavigationStyle = true
        self.navigation.setdefaultType(type: .list)
        self.navigation.setTitle(title: "common_text_identify".localized())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleNavigation()
        handleFooter()
        getAuthInfo()
        self.showErrorMsg()
        bindInputs()
    }
    
    func bindInputs(){
//        nameInputView.infoTextView.input.rx.text.orEmpty.asObservable()
//            .distinctUntilChanged()
//            .subscribe(onNext: { [weak self] inputtxt in
//                guard let `self` = self else { return }
//                self.name = inputtxt
//            }).disposed(by: self.disposeBag)
//
//        idInputView.infoTextView.input.rx.text.orEmpty.asObservable()
//            .distinctUntilChanged()
//            .subscribe(onNext: { [weak self] inputtxt in
//                guard let `self` = self else { return }
//                self.idnumber = inputtxt
//            }).disposed(by: self.disposeBag)
        
        let userNameInput = nameInputView.infoTextView.input.rx.text.orEmpty.asObservable()
        let idNumberInput = idInputView.infoTextView.input.rx.text.orEmpty.asObservable()
        
        Observable.combineLatest(userNameInput,idNumberInput)
            .map({[weak self] tuple in
                let (name,id) = tuple
                if name.count > 0,
                    id.count > 0
                {
                    self?.idnumber = id
                    self?.name = name
                    return true
                }
                return false
            })
            .bind(to:footer.confirmBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        
    }
    
    func getAuthInfo() {
        appApi.rx.request(.securityAuthInfo)
            .MJObjectMap(EXIdentityAuthInfoModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                self?.handleInfos(model)
            }) {[weak self] (error) in
                guard let `self` = self else {return}
                self.handleInfos(self.userModel)
        }.disposed(by: self.disposeBag)
    }
    
    func handleFooter() {
        footer.confirmBtn.setTitle("kyc_action_submit".localized(), for: .normal)
        footer.hideFooterTitle()
        footer.confirmBtn.rx.tap
        .asObservable()
        .throttle(.seconds(1), scheduler: MainScheduler.instance)
        .subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.handleUploadVerify()
        }).disposed(by: self.disposeBag)
    }
    
    func handleInfos(_ model:EXIdentityAuthInfoModel) {
        /*
Common_text_verifyInfoTitle "=" To ensure that it is done for me or not, please complete the following information:
Common_text_realnameVerifyTitle "=" Your real name verified name? (Hint:% @) ";
Common_textUnrealidVerifyTitle "=" Your real name ID number? (Hint:% @) ";
Common_text_realnameVerifyPlaceholder "=" Please enter a name ";
Common_text-realidVerifyPlaceholder "=" Please enter your ID number ";
         */
        self.userModel = model
        let nameTitle = String(format: "common_text_realnameVerifyTitle".localized(), model.userName)
        let idTitle = String(format: "common_text_realidVerifyTitle".localized(), model.idNumber)
        nameInputView.maxLenth = 50
        idInputView.maxLenth = 35
        nameInputView.updateInfo(title:nameTitle, placeHolder: "common_text_realnameVerifyPlaceholder".localized())
        idInputView.updateInfo(title: idTitle, placeHolder: "common_text_realidVerifyPlaceholder".localized())
    }
    
    func handleUploadVerify() {
        
        appApi.rx.request(.securityAuthCheck(idNumber: self.idnumber, userName: self.name,withdrawId:self.withdrawID))
            .MJObjectMap(EXCheckAuthInfoModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let `self` = self else {return}
                self.handleVerifyResult(model)
            }) {[weak self] (error) in
//                guard let `self` = self else {return}
//                self.showErrorMsg(tryTime: "2", errCode: "2")
        }.disposed(by: self.disposeBag)

    }
    
    func handleVerifyResult(_ model :EXCheckAuthInfoModel) {
        
        if model.result == EXCheckAuthCode.tryTimesErr.rawValue {
            self.handleResult(isSuccess: false)
        }else {
            if model.result  == EXCheckAuthCode.success.rawValue {
                self.handleResult(isSuccess: true)
            }else {
                self.showErrorMsg(tryTime: model.reqNum,errCode: model.result)
            }
        }
    }
    
    func handleResult(isSuccess:Bool) {
        var model:EXFullScreenAlertModel?
        if isSuccess {
            model = EXFullScreenAlertModel.successForAuth()
        }else {
            model = EXFullScreenAlertModel.failModelForAuth()
        }

        let fullscreenAlert = EXFullScreenAlertVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        fullscreenAlert.dismissBlock = {[weak self] in
            self?.customBack()
        }
        fullscreenAlert.alertModel = model!
        fullscreenAlert.modalPresentationStyle = .fullScreen
        self.present(fullscreenAlert, animated: false, completion: nil)
    }
    
    func customBack() {
        if let controllers = self.navigationController?.viewControllers {
            var isPoped = false
            for controller in controllers {
                if controller.isKind(of: EXAssetsVc.self) {
                    isPoped = true
                    self.navigationController?.popToViewController(controller, animated: true)
                }
            }
            if isPoped == false {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    func showErrorMsg(tryTime:String = "",errCode:String = "") {
        if tryTime.isEmpty || errCode.isEmpty{
            errorMsgView.isHidden = true
        }else {
            var errMsg = ""
            if errCode == EXCheckAuthCode.userNameErr.rawValue {
                errMsg = "common_text_verifyAuthNameError".localized()
            }else if errCode == EXCheckAuthCode.idNumberErr.rawValue {
                errMsg = "common_text_verifyAuthIdNumberError".localized()
            }
            EXAlert.showFail(msg: errMsg)
            if let usedTime = Int(tryTime) {
                let leftTime = 3 - usedTime
                let fullErrorMsg = errMsg + "," + String(format:"common_text_verifyAuthTryTimeDesc".localized(),"\(leftTime)")
                let textColor = [ NSAttributedString.Key.foregroundColor: UIColor.ThemeLabel.colorMedium ]
                let errorAttr = NSMutableAttributedString(string: fullErrorMsg, attributes: textColor)
                let highc = [ NSAttributedString.Key.foregroundColor: UIColor.ThemeState.fail]
                
                errorAttr.addAttributes(highc, range: (fullErrorMsg as NSString).range(of: "3"))
                errorAttr.addAttributes(highc, range: (fullErrorMsg as NSString).range(of: "\(leftTime)"))
                
                errorMsgLabel.textColor = UIColor.ThemeLabel.colorMedium
                errorMsgView.isHidden = false
                errorMsgLabel.attributedText = errorAttr
            }else {
                errorMsgView.isHidden = true
            }
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
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraints.constant = height
    }
}

