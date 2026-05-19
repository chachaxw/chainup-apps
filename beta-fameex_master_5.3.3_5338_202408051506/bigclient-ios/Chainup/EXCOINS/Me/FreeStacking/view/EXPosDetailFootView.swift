//
//  EXPosDetailFootView.swift
//  Chainup
//
//  Created by lcus on 2023/10/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit




class EXPosDetailFootView: UIView {

    var enityProtocol:EXPosDetailProtocolEnity = EXPosDetailProtocolEnity()
    var inputString:String = ""
    let VM = EXPosProjectDetailVM()
    var title :UILabel = {
        let lable = UILabel()
        lable.textColor = UIColor.ThemeLabel.colorLite
        lable.font = UIFont.ThemeFont.HeadBold
        lable.text = "pos_state_rules".localized()
        return lable
    }()
    var sepLine: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.ThemeNav.bg
        
        return view
        
    }()
    var detail:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0;
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        label.preferredMaxLayoutWidth = SCREEN_WIDTH-30
        return label
    }()
    
    var protocolButton:UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .Ex.regular(12)
        button.titleLabel?.numberOfLines = 0
        button.setImage(UIImage.themeImageNamed(imageName: "assets_selected"), for: .normal)
        button.setImage(UIImage.themeImageNamed(imageName: "lineswitching_unselected"), for: .selected)
        button.setTitle("pos_sting_potocolTitle".localized(), for: .normal)
        button.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        button.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .selected)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        button.addTarget(self, action: #selector(didClickAgreeButton), for: .touchUpInside)
        button.isSelected = true
        button.contentMode = .scaleAspectFit
        return button;
    }()
    
    var agreeButton:UIButton = {
        
        let button = UIButton()
        button.titleLabel?.font = UIFont.ThemeFont.HeadRegular
        button.titleLabel?.textColor = UIColor.ThemeBtn.disable
        button.setTitleColor(UIColor.ThemeBtn.normal, for: .normal)
    
        button.backgroundColor = UIColor.ThemeBtn.disable
       
        button.setTitle("pos_sting_agree".localized(), for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(didClickPosButton), for: .touchUpInside)
        return button;
    }()

    override init(frame: CGRect) {
        
    
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(title)
        self.addSubview(sepLine)
        self.addSubview(detail)
        self.addSubview(protocolButton)
        self.addSubview(agreeButton)
//
        title.snp.makeConstraints { (make) in
            
            make.left.top.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(30)
        }
        sepLine.snp.makeConstraints { (make) in
            
            make.left.right.equalTo(self)
            make.top.equalTo(title.snp.bottom).offset(14)
            make.height.equalTo(1)
        }
        
        detail.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15)
            make.top.equalTo(sepLine.snp.bottom).offset(31)
            make.right.equalTo(self).offset(-15)
            make.bottom.equalTo(self).offset(-15).priority(.low)
        }
        protocolButton.snp.makeConstraints { (make) in
            
            make.left.equalTo(self).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(detail.snp.bottom).offset(20);
            
        }
        agreeButton.snp.makeConstraints { (make) in
            
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.top.equalTo(protocolButton.snp.bottom).offset(32)
            make.height.equalTo(44)
            make.bottom.equalTo(self.snp.bottom).offset(-5).priority(.low)
        }
        
        setNotification()
        
        
    }
    
    func setNotification()  {
        
        
        let loginSuccess = Notification.Name(rawValue: "EXLoginSuccess")
        _ = NotificationCenter.default.rx
            .notification(loginSuccess)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext:{ [weak self] notification in
                
                if let infoVC  = self?.yy_viewController as? EXPosProtocolDetailVC{
                    infoVC.loadDetailInfo()
                }
                
            })
        
        
        let notification = Notification.Name(rawValue: "needCaluclation")
        _ = NotificationCenter.default.rx
            .notification(notification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext:{ [weak self] notification in
                
                
                let userInfo = notification.userInfo as! [String:Any]
                
                let value = userInfo["inputValue"] as! String
                self?.inputString = value
                
                if value != "" {
                    
                    if self?.protocolButton.isSelected == false {
                        
                        self?.setButtonEnable(isEnable: true)
                    }else{
                        self?.setButtonEnable(isEnable: false)
                    }
                    
                }else {
                    self?.setButtonEnable(isEnable: false)
                }
            })
    }
    
    
    func setButtonEnable(isEnable:Bool) {
        
        if isEnable {
            agreeButton.backgroundColor = UIColor.ThemeBtn.highlight
        }else{
             agreeButton.backgroundColor = UIColor.ThemeBtn.disable
        }
        agreeButton.isEnabled = isEnable
    }
    
    
    func setFootData(enity:EXPosDetailProtocolEnity) {
        
        let string = enity.details
        self.enityProtocol = enity
        detail.attributedText = string.htmlToAttributedString
        
        if enity.activeStatus != 1 || enity.isShowBuy != 1 {
            
            self.agreeButton.removeFromSuperview()
            self.protocolButton.removeFromSuperview()
            
        }}
    
    
    
    func setFootData(enity:EXPosDetailPostionEnity)  {
        
        let string = enity.details
          detail.attributedText = string.htmlToAttributedString
        self.agreeButton.removeFromSuperview()
        self.protocolButton.removeFromSuperview()
        
    }
    
    @objc func didClickAgreeButton(){
        
        protocolButton.isSelected = !protocolButton.isSelected
        
        let state =  self.inputString.count != 0 && protocolButton.isSelected == false
       
        self.setButtonEnable(isEnable:state)
        
    }
    
    @objc func didClickPosButton(){
        
        if XUserDefault.getToken() == nil{
            BusinessTools.modalLoginVC()
            return
        }
        let isValid = validMessage()
        if !isValid { return }
       
        VM.incrementApply { [weak self] in
            
            if let contrller = self?.yy_viewController {
                
                let view = EXNormalAlert()
                view.configSigleAlert(title: "common_text_tip".localized(), message: "pos_buy_success".localized())
                EXAlert.showAlert(alertView: view)
                let infoVC  = contrller as! EXPosProtocolDetailVC
                infoVC.loadDetailInfo()
            }
        }
    }
    
    func validMessage()->Bool {
         let inputValue = EXPosDetailServer.sharedInstance.inputValue
        
        if let inputDoubleValue = Double(inputValue!){
            
            if inputDoubleValue < self.enityProtocol.buyAmountMin {
                EXAlert.showFail(msg:"\("pos_string_minquantityperLock".localized())\(self.enityProtocol.buyAmountMin)\(self.enityProtocol.shortName)")
                return false
            }else if inputDoubleValue+self.enityProtocol.totalAmount > self.enityProtocol.buyAmountMax {
                
            EXAlert.showFail(msg:"\("pos_string_maxquantityLock".localized())\(self.enityProtocol.buyAmountMax)\(self.enityProtocol.shortName)")
                
                return false
            }else if inputDoubleValue > self.enityProtocol.balance  {
                EXAlert.showFail(msg:"\("pos_string_lockNotAvailable".localized())\(self.enityProtocol.balance)\(self.enityProtocol.shortName)")
                return false

            }

        }
        
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            let str = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            
                let muti = NSMutableAttributedString(attributedString: str)
                muti.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.ThemeLabel.colorMedium, range: NSMakeRange(0, str.length))
                return muti
            
            
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
