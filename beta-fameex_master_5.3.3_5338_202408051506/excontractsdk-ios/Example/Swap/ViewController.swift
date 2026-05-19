//
//  ViewController.swift
//  Swap
//
//  Created by 柴伟东 on 05/07/2022.
//  Copyright (c) 2022 柴伟东. All rights reserved.
//

import UIKit
import EXKit
class ViewController: UIViewController {

    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var accountTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("0.123456".toPercentString(1))
        
    }
    
    @IBAction func login(_ sender: UIButton) {
        if accountTF.text?.count == 0 {
            //EXKitAlert.showWarning(msg: "输入账号")
            return
        }
        if passwordTF.text?.count == 0 {
          //  EXKitAlert.showWarning(msg: "输入密码")
            return
        }

        
    }
}

extension ViewController{
//    func ekitTest(){
//        view.backgroundColor = .Ex.kLine.text1
//        view.backgroundColor = .Ex.global.text2
//        view.backgroundColor = .Ex.text3
//        let label = UILabel()
//        label.font = .Ex.regular(12)
//        EXThemeBundle.data(named: "")
//        EXThemeBundle.image(named: "")
//        _ = EXTheme.dark.isActive
//        _ = EXTheme.dark.active()
//        _ = EXTheme.current
//        EXTheme.current.isActive
//        UIColor.Ex.kLine.isDarkMode
//        UIColor.Ex.global.isDarkMode
//    }
}
//extension ViewController{
//
//
//    func requestLoginOne(account: String, password: String) {
//
//        let verificationType = EXCaptchaMananger.shared.captchaType()
//
//        let context = EXAccountContext.init(type: .login)
//        context.account = account
//        context.password = password
//
//        appApi
//            .rx
//            .request(.loginOne(mobileNumber: account, loginPword: password))
//            .MJObjectMap(EXLoginEntity.self)
//            .autoShowLoadingOnController(context: self)
//            .subscribe(onSuccess: {[weak self] (entity) in
//                self?.didLoginOneRequestSucceeded(entity, context: context)
//            }) {[weak self] (error) in
//
//        }.disposed(by: disposeBag)
//    }
//
//    func didLoginOneRequestSucceeded(_ loginModel: EXLoginEntity, context: EXAccountContext){
//
//        context.token = loginModel.token
//
//        let codeInputVc = UIViewController.createControllerFromStoryBoard(name: .accout, type: EXCodeInputVc.self)
//
//        if loginModel.googleAuth == "1" {
//            codeInputVc.inputType = .gooleCode
//        }
//        else if accountInputView.text.isEmail() {
//            codeInputVc.inputType = .emailCode
//            context.signType = .mail
//        }
//        else {
//            context.signType = .phone
//            codeInputVc.inputType = .phoneCode
//        }
//        codeInputVc.accountContext = context
//        navigationController?.pushViewController(codeInputVc, animated: true)
//    }
//
//}
