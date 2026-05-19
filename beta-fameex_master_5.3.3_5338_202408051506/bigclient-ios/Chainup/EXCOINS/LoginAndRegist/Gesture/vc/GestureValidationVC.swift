//
//  GestureValidationVC.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/4.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
enum GestureValidationType {
    case input//Enter gesture password
    case EnterAgain//Reenter gesture password
    case login//Gesture password login
    case loginSet//Login reminder settings
    case loginSetAgain//Login reminder reset
}

class GestureValidationVC: NavCustomVC {
    
    let vm = GestureValidationVM()
    
    var type = GestureValidationType.EnterAgain
    {
        didSet{
            gestureValidationView.setView(type)
        }
    }
    
    var code = ""//Gesture password
    
    var gesToken = ""//Gesture token
    
    typealias ConfirmGesturesBlock = (String)->()//Confirm gesture
    var confirmGesturesBlock : ConfirmGesturesBlock?

    typealias ConfirmGesturesCompleteBlock = () -> ()//Second confirmation gesture
    var confirmGesturesCompleteBlock : ConfirmGesturesCompleteBlock?
    
    //Cancel button
    lazy var cancelBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
//        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
//        btn.setTitle(LanguageTools.getString(key: "common_text_btnCancel"), for: UIControl.State.normal)
//        btn.contentHorizontalAlignment = .left
        btn.extSetAddTarget(self, #selector(clickCancelBtn))
//        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.setImage(UIImage.themeImageNamed(imageName: "login_close"), for: .normal)
        return btn
    }()
    
    lazy var gestureValidationView : GestureValidationView = {
        let view = GestureValidationView()
        view.extUseAutoLayout()
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        vm.setVC(self)
        gestureValidationView.vm = self.vm
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        contentView.addSubview(gestureValidationView)
        gestureValidationView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
   
    }
    
    override func setNavCustomV() {
        self.navCustomView.backgroundColor = UIColor.ThemeView.bg
        self.navCustomView.popBtn.isHidden = true
        self.navCustomView.backView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(28)
            make.centerY.equalToSuperview()
//            make.width.lessThanOrEqualTo(200)
//            make.height.equalTo(16)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Gesture verification
    func sendGestDatas(afterLogin:Bool){
        let quickToken = XUserDefault.quickTokenValue ?? ""

        appApi.rx.request(.handOpen(quickToken:afterLogin ? quickToken : gesToken, handPwd: code, afterLogin: afterLogin))
            .subscribe(onSuccess: { [weak self] (_)  in
                XUserDefault.setGesturesPassword(self?.code ?? "")
                self?.confirmGesturesCompleteBlock?()
                self?.clickCancelBtn()
                EXAlert.showSuccess(msg: "login_tip_gestureLoginSuccess".localized())
            }, onFailure: nil, onDisposed: nil).disposed(by: self.disposeBag)
    }
    
    //Gesture login
    func gestLogin(){
        
        if  XUserDefault.getGesturesPassword() != nil {
            
            let quickToken = XUserDefault.quickTokenValue ?? ""

            appApi.rx.request(.handLogin(quickToken: quickToken, handPwd: XUserDefault.getGesturesPassword() ?? "")).MJObjectMap(EXLoginSuccessEntity.self).subscribe(onSuccess: {[weak self] (entity) in
                UserInfoEntity.sharedInstance().loginSuccess(entity.token)
                UserInfoEntity.sharedInstance().getUserInfo ({}) {}
                EXAlert.showSuccess(msg: LanguageTools.getString(key: "login_tip_loginsuccess"))
                self?.popBack()
                EXGameJumpManager.shareInstance.presentAuthorVc()
            }) {[weak self] (error) in
                if error._code == 104008 || error._code == 108001 {
                    XUserDefault.setGesturesPassword("")
                    XUserDefault.quickTokenValue = nil
                    self?.popBack()
                    guard let appDelegate  = UIApplication.shared.delegate else {
                        return
                    }
                    if appDelegate.window != nil   {
                        let nav = NavController()
                        nav.modalPresentationStyle = .fullScreen
                        nav.isNavigationBarHidden = true
                        let loginVC = EXAccountActionVc()
//                        let loginVC = UIViewController.createControllerFromStoryBoard(name: .accout, type: EXAccountActionVc.self)
                        nav.viewControllers = [loginVC]
                        appDelegate.window??.rootViewController?.present(nav, animated: true, completion: nil)
                    }
                }
            }.disposed(by: self.disposeBag)
           
        }
    }
    
    @objc func clickCancelBtn(){
        //        super.navBack()
//        UserInfoEntity.sharedInstance().clearQuickToken()
        guard BusinessTools.getRootNavBar() != nil else{
            return
        }
        popBack()
//        BusinessTools.logoutNet()
    }
}

