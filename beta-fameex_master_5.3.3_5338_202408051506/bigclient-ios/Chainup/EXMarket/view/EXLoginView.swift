//
//  EXLoginView.swift
//  EXKit_Example
//
//  Created by cwd on 2022/7/18.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
public typealias EXComIntBlock = (_ number: Int) -> ()
public class EXLoginView: EXBaseView {
    public var btnBlock: EXComIntBlock?
    
    /// ///Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"login to trade", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        return label
    }()
    
    //confirm
    lazy var register : UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        btn.addTarget(self, action: #selector(registerClick), for: UIControl.Event.touchUpInside)
Btn. setTitle ("registration", for:. normal)
        return btn
    }()
    
    //
    lazy var login : UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        btn.addTarget(self, action: #selector(loginClick), for: UIControl.Event.touchUpInside)
Btn. setTitle ("Login", for:. normal)
        return btn
    }()
    
    public override func setSubView() {
        self.backgroundColor = UIColor.ThemeView.bgGap
        self.addSubViews([titleLabel,register,login])
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        login.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.width.equalTo(72)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        register.snp.makeConstraints { make in
            make.right.equalTo(login.snp.left).offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(login)
            make.height.equalTo(login)
        }
    }
    
    @objc func registerClick(){
        self.btnBlock?(0)
    }
    @objc func loginClick(){
        self.btnBlock?(1)
    }
}

