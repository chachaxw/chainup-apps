//
//  EXLoginTabView.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/26.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXLoginTabView: UIView {
    lazy var bg:UIView = {
        let b = UIView()
        b.backgroundColor = UIColor.ThemeView.card2
        return b
    }()
    
    lazy var loginTitleLabel:UILabel = {
        let l = UILabel ()
        l.textColor = UIColor.ThemeLabel.colorLite
        l.text = "login_bottom_tips".localized()
        l.font = UIFont.ThemeFont.BodyMedium
        return l
    }()
    
    lazy var registerBtn:RepeatButton = {
        let btn = RepeatButton.init(type: .custom)
        btn.addTarget(self , action: #selector(onRegisterAction), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryMedium
        btn.setTitle("login_action_register".localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        return btn
    }()
    
    lazy var loginBtn:RepeatButton = {
        let btn = RepeatButton.init(type: .custom)
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryMedium
        btn.layer.cornerRadius = 16
        btn.addTarget(self , action: #selector(onLoginAction), for: .touchUpInside)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right:  20)
        btn.setTitle("login_action_login".localized(), for: .normal)
        btn.setBackgroundColor(color: UIColor.ThemeView.highlight, forState: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(bg)
        self.backgroundColor = UIColor.ThemeView.bg
        bg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bg.addSubViews([loginTitleLabel,registerBtn,loginBtn])
        loginTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(MARGIN_LEFT)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(registerBtn.snp.leading)
        }
        
        registerBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(loginBtn.snp.leading).offset(-20)
        }
        
        loginBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-MARGIN_LEFT)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bg.roundCorners(corners: [.topLeft,.topRight], radius: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onLoginAction() {
        BusinessTools.modalLoginVC()
    }
    
    @objc func onRegisterAction() {
        
        if EXHomeViewModel.appdCompanyID() == "1490" {
            self.webRegister()
        }else {
            guard let appDelegate  = UIApplication.shared.delegate else {
                return
            }
            let nav = NavController()
            nav.modalPresentationStyle = .fullScreen
            nav.isNavigationBarHidden = true
//            let loginVC = UIViewController.createControllerFromStoryBoard(name: .accout, type: EXAccountActionVc.self)
            let loginVC = EXAccountActionVc()
            nav.viewControllers = [loginVC]
            loginVC.showSignup = true
            appDelegate.window??.rootViewController?.present(nav, animated: true, completion: nil)
        }
        
   
    }
    
    func webRegister() {
        if let url = URL(string: "https://centurioninvest.com/en/register") {
            UIApplication.shared.open(url, options: [:],
                                                  completionHandler: {(success) in
                                                    print(success)
                        })
        }
    }
    
}

extension EXLoginTabView{
    func refreshTitles(){
        loginTitleLabel.text = "login_bottom_tips".localized()
        registerBtn.setTitle("login_action_register".localized(), for: .normal)
        loginBtn.setTitle("login_action_login".localized(), for: .normal)
    }
}
