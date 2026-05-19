//
//  EXCodeInputVc.swift
//  Chainup
//
//  Created by wangdong on 2023/9/17.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit
enum EXCodeInputType: String {
    case gooleCode = "1"
    case phoneCode = "2"
    case emailCode = "3"
}

class EXCodeInputVc: BaseVC{

    @IBOutlet weak var navBar: EXAccountNavigationBar!
    var inputType: EXCodeInputType!
    @IBOutlet weak var codeGroupView: EXCodeGroupView!
    @IBOutlet weak var bigTitleLabel: UILabel!
    @IBOutlet weak var smalltitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var pasteBtn: EXButton = {
        let b = EXButton()
        b.selectStyle = .blueTextColor
        b.setTitle("common_action_paste".localized(), for: .normal)
        return b
    }()
    var accountContext: EXAccountContext!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let (done, _) = codeGroupView.inputDone.value
        
        if done {
            codeGroupView.clear()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        codeGroupView.beginInput()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        codeGroupView.endInput()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configPasteBtn()
        navBar.topShowAllBtn()
        guard let _ = accountContext else { return }

        if accountContext.type == .regist {
            if accountContext.signType == .phone {
                inputType = .phoneCode
            }
            else if accountContext.signType == .mail {
                inputType = .emailCode
            }
        }
        
        guard let _ = inputType else { return }
        
        initControls()
        
        actionButton.setTitleColor(UIColor.ThemeBtn.highlight, for: .normal)
        actionButton.setTitleColor(UIColor.ThemeBtn.disable, for: .disabled)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        
        codeGroupView.inputDone.subscribe(onNext: { [weak self] tuple in
            guard let self = `self` else { return }
            let (done, value) = tuple
            if done {
                if self.accountContext?.type == .regist {
                    self.requestRegistTwo(value: value)
                }
                else {
                    self.loginCode(value: value)
                }
            }
        }).disposed(by: self.disposeBag)
    }
    
    func requestRegistTwo(value: String) {
        appApi.rx.request(.registerTwo(registerCode: accountContext.account, numberCode: value))
            .MJObjectMap(EXRegistTwoEntity.self)
            .autoShowLoadingOnController(context: self)
            .subscribe(onSuccess: {[weak self] (entitiy) in
                guard let self = `self` else { return }
                self.accountContext.invitationCode_required = entitiy.invitationCode_required
                let vc = EXAccountNewPasswordVc()
                vc.passwordIntent = .set
                vc.accountContext = self.accountContext
                self.navigationController?.pushViewController(vc, animated: true)
            }) {[weak self] (error) in
                self?.codeGroupView.error()
        }.disposed(by: disposeBag)
        
    }
    
    func loginCode(value: String) {
        self.codeGroupView.resignFirstResponder()
        _ = appApi
            .rx
            .request(.loginTwo(token: accountContext.token,
                               checkType: self.inputType.rawValue,
                               authCode: value,
                               googleCode: nil,
                               smsCode: nil,
                               emailCode: nil,
                               idCardCode: nil))
            .MJObjectMap(EXLoginSuccessEntity.self)
            .autoShowLoadingOnController(context: self)
            .subscribe(onSuccess: { [weak self] entity in
                guard let self = `self` else { return }
//                print("login \(self.accountContext.countryCode)")
                if (self.accountContext.countryCode.isEmpty == false){
                    XUserDefault.setValueForKey(self.accountContext.countryCode, key: XUserDefault.countryNumber)
                }
                UserInfoEntity.sharedInstance().loginSuccess(self.accountContext.token,
                                                             quickToken: entity.quicktoken,
                                                             account: self.accountContext.account,
                                                             loginPwd: "")
                UserInfoEntity.sharedInstance().getUserInfo ({
                    EXAlert.showSuccess(msg: LanguageTools.getString(key: "login_tip_loginsuccess"))
                    if let str = XUserDefault.getFaceIdOrTouchIdPassword(),
                        str == "" &&
                        UserInfoEntity.sharedInstance().gesturePwd.ch_length < 3 {
                        self.dismiss(animated: true) {
                            let vc = GesstureAlertVC()
                            if let nav = BusinessTools.getRootNavBar(){
                                nav.pushViewController(vc, animated: true)
                            }
                            self.presentGameAuthor()
                        }
                    }else{
                        self.dismiss(animated: true, completion: nil)
                        self.presentGameAuthor()
                    }
                    
                    EXAuthenticManagerTool.getUserKysRight(symbol: nil) { _ in
                        
                    }
                }) {
                    UserInfoEntity.sharedInstance().logout()
                    self.dismiss(animated: true, completion: nil)
                    EXAlert.showFail(msg: "get_userinfo_failed_tip".localized())
                }
            }) { [weak self] error in
                self?.codeGroupView.error()
        }
    }
   
    deinit {
        print("deinit")
    }
    
    func configPasteBtn(){
        self.view.addSubview(pasteBtn)
        pasteBtn.snp.makeConstraints { make in
            make.centerY.equalTo(actionButton)
            make.height.equalTo(15)
            make.width.equalTo(30)
            make.right.equalTo(self.codeGroupView.snp.right)
            
        }
        pasteBtn.textSizeFit(imageWidth: 0,space: 0)
        pasteBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.codeGroupView.set(value: UIPasteboard.general.string ?? "")
        }).disposed(by: self.disposeBag)
    }
    
    func presentGameAuthor() {
        EXGameJumpManager.shareInstance.presentAuthorVc()
    }
    
    func initControls() {
        switch inputType {
        case .phoneCode:
            inputPhoneCodeScene()
        case .emailCode:
            inputEmailCodeScene()
        case .gooleCode:
            inputGoogleCodeScene()
        case .none:
            break
        }
    }
    
    private func inputPhoneCodeScene() {
                
        phoneAction()
        bigTitleLabel.font = UIFont.Ex.medium(28)
        bigTitleLabel.text = "personal_tip_inputPhoneCode".localized()
        smalltitleLabel.text = "phone_didSendCode_to".localized() + " " + accountContext.phoneAccount.desensitizedPhone()
        resetSendCodeControl()
        actionButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = `self` else { return }
            self.phoneAction()
            self.resetSendCodeControl()
        }).disposed(by: self.disposeBag)
    }
    
    private func phoneAction() {
        if accountContext.type == .login {
            getSmsValidCode()
        }
        else if accountContext.type == .regist {
            registSmsValidCode()
        }
    }
    
    private func mailAction () {
        if accountContext.type == .login {
            getMailValidCode()
        }
        else if accountContext.type == .regist {
            registMailValidCode()
        }
    }
    
    private func inputEmailCodeScene() {
        mailAction()
        bigTitleLabel.text = "personal_tip_inputMailCode".localized()
        smalltitleLabel.text = "mail_didSendCode_to".localized() + " " + accountContext.mailAccount.desensitizedMail()
        resetSendCodeControl()
        actionButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = `self` else { return }
            self.mailAction()
            self.resetSendCodeControl()
        }).disposed(by: self.disposeBag)
    }
    
    private func inputGoogleCodeScene() {
        bigTitleLabel.text = "safety_text_googleAuth".localized()
        smalltitleLabel.text = "please_check_with_google_auth".localized()
        actionButton.setTitle("common_action_paste".localized(), for: .normal)
        self.pasteBtn.isHidden = true
        actionButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.codeGroupView.set(value: UIPasteboard.general.string ?? "")
        }).disposed(by: self.disposeBag)
    }
    
    private func resetSendCodeControl() {
        let seconds = Observable.generate(
            initialState: 89,
            condition: { $0 >= 0},
            iterate: { $0 - 1 }
        )
        
        let timer = Driver<Int>.interval(.seconds(1))
        
        Observable.zip(seconds, timer.asObservable()).map({ (seconds, timer) in
            return seconds
        }).subscribe(onNext: { [weak self] seconds in
            guard let self = `self` else { return }
            if seconds == 0 {
                self.actionButton.isEnabled = true
                self.actionButton.setTitle("login_action_resendCode".localized(), for: .normal)
            }
            else {
                self.actionButton.isEnabled = false
                self.actionButton.setTitle(String(seconds) + "(s)" + "login_action_resendCode".localized(), for: .disabled)
            }
            
        }).disposed(by: self.disposeBag)
    }
}

extension EXCodeInputVc {
    
    func getSmsValidCode() {
        appApi
            .rx
            .request(.getsmsValidCode(token: accountContext.token,
                                      operationType: EXSendVerificationCode.moblielogin,
                                      countryCode: "",
                                      mobile: ""))
            .MJObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: { (response) in
            }) { _ in
//                self?.codeGroupView.error()
        }.disposed(by: disposeBag)
    }
    
    func registSmsValidCode() {
        appApi
            .rx
            .request(.registGetsmsValidCode(token: accountContext.token,
                                            operationType: EXSendVerificationCode.regist,
                                            countryCode: accountContext.countryCode,
                                            mobile: accountContext.phoneAccount))
            .MJObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: { _ in
                
            }) { _ in
//                self?.codeGroupView.error()
        }.disposed(by: disposeBag)
    }
    
    func getMailValidCode() {
        appApi
            .rx
            .request(.getemailVallidCode(email: self.accountContext.mailAccount,
                                         operationType: EXSendVerificationCode.emaillogin,
                                         token : self.accountContext.token))
            .MJObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: { _ in
                
            }) { _ in
                
        }.disposed(by: disposeBag)
    }
    
    func registMailValidCode() {
        appApi
            .rx
            .request(.registGetemailVallidCode(email: self.accountContext.mailAccount,
                                               operationType: EXSendVerificationCode.regist,
                                               token: self.accountContext.token))
            .MJObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: { (reponse) in
            }) { _ in

        }.disposed(by: disposeBag)
    }
}
