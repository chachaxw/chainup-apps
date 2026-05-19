//
//  EXWebLoginVC.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/28.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXScanInfoV:UIView {
    
    lazy var ipLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.font = UIFont.ThemeFont.SecondaryMedium
        l.textColor = UIColor.ThemeLabel.colorMedium
        l.text = "login_scan_ipTitle".localized()
        return l
    }()
    
    lazy var ipValueLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.font = UIFont.ThemeFont.SecondaryMedium
        l.textColor = UIColor.ThemeLabel.colorLite
        return l
    }()
    
    
    lazy var deviceLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .left
        l.font = UIFont.ThemeFont.SecondaryMedium
        l.textColor = UIColor.ThemeLabel.colorMedium
        l.text = "login_scan_equipment".localized()

        return l
    }()
    
    lazy var deviceValueLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.font = UIFont.ThemeFont.SecondaryMedium
        l.textColor = UIColor.ThemeLabel.colorLite
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 4
        self.backgroundColor = UIColor.ThemeView.card2
        self.addSubViews([ipLabel,ipValueLabel,deviceLabel,deviceValueLabel])
        
        ipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(16)
        }
        
        deviceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(ipLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        ipValueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(ipLabel)
        }
        
        deviceValueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(deviceLabel)
            make.bottom.equalToSuperview().offset(-16)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EXWebLoginVC: BaseVC {
    
    var qrID:String = ""
    lazy var pcIcon:UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage.themeImageNamed(imageName: "public_scancode")
        return icon
    }()
    
    lazy var nameLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = UIFont.ThemeFont.H3Medium
        l.textColor = UIColor.ThemeLabel.colorLite
        l.text = "login_scan_title".localized()
        return l
    }()
    
    lazy var descLabel:UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = UIFont.ThemeFont.SecondaryMedium
        l.textColor = UIColor.ThemeLabel.colorMedium
        l.text = "login_scan_desc".localized()
        return l
    }()
    
    lazy var infoBg:EXScanInfoV = {
        let v = EXScanInfoV()
        return v
    }()
    
    lazy var confirmBtn:EXButton = {
        let btn = EXButton()
        btn.selectStyle = .blueColor
        btn.setFont(UIFont.ThemeFont.BodyMedium)
        btn.setTitle("login_scan_confirm".localized(), for: .normal)
        btn.addTarget(self, action: #selector(confirmLogin), for: .touchUpInside)
        return btn
    }()
    
    
    lazy var cancelBtn:EXButton = {
        let btn = EXButton()
        btn.selectStyle = .defultColor
        btn.setFont(UIFont.ThemeFont.BodyMedium)
        btn.setTitle("login_scan_cancel".localized(), for: .normal)
        btn.addTarget(self, action: #selector(cancelLogin), for: .touchUpInside)
        return btn
    }()
    
    @objc func confirmLogin() {
        if qrID.isEmpty {
            return
        }
        appApi.rx.request(.confirmPCLogin(qrid: qrID))
            .MJObjectMap(EXVoidModel.self)
            .autoShowLoadingOnController(context: self)
            .subscribe(onSuccess: {[weak self] _ in
                guard let mySelf = self else{return}
                self?.dismiss(animated: true)
            }) { (error) in
//                print("error =\( error._code)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dismiss(animated: true)
                }
                
                
        }.disposed(by: disposeBag)
    }
    
    @objc func cancelLogin() {
        self.popBack()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([pcIcon,nameLabel,descLabel,infoBg,confirmBtn,cancelBtn])
        pcIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(37)
            make.width.height.equalTo(100)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(pcIcon.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.equalTo(MARGIN_LEFT)
            make.trailing.equalTo(-MARGIN_LEFT)
        }
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.leading.equalTo(MARGIN_LEFT)
            make.trailing.equalTo(-MARGIN_LEFT)
        }
        infoBg.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(24)
            make.leading.equalTo(MARGIN_LEFT)
            make.trailing.equalTo(-MARGIN_LEFT)
        }
        
        cancelBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-(TABBAR_BOTTOM + 20))
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        confirmBtn.snp.makeConstraints { make in
            make.bottom.equalTo(cancelBtn.snp.top).offset(-16)
            make.leading.equalTo(MARGIN_LEFT)
            make.trailing.equalTo(-MARGIN_LEFT)
            make.height.equalTo(44)
        }
        
    }
    
    func fetchLoginInfo() {
        if qrID.isEmpty {
            return
        }
        appApi.rx.request(.getIpByCode(qrid: qrID))
            .MJObjectMap(EXQRLoginModel.self, false)
            .autoShowLoadingOnController(context: self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                mySelf.infoBg.ipValueLabel.text = model.ipAddress
                mySelf.infoBg.deviceValueLabel.text = model.equipment
            }) { (error) in
                
        }.disposed(by: disposeBag)
        
    }
}
