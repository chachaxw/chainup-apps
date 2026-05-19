//
//  EXRedPacketDetailView.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage
import EXKit

let redproportion : CGFloat = SCREEN_WIDTH / 375

class EXRedPacketDetailView: UIView {
    
    typealias ShareSuccessBlock = () -> ()
    var shareSuccessBlock : ShareSuccessBlock?
    
//    //MARK: Single Example
//    public static var sharedInstance : EXRedPacketDetailView{
//        struct Static {
//            static let instance : EXRedPacketDetailView = EXRedPacketDetailView()
//        }
//        return Static.instance
//    }
    
    var entity = EXCreateRedPacketEntity()
    
    lazy var backImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        return imgV
    }()

    lazy var logoImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        if let url = URL.init(string:  EXAppConfigManager.sharedInstance.getAppLogo().logo_black){
            imgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
        }
        return imgV
    }()
    
    lazy var redPackView : EXRedPacketView = {
        let view = EXRedPacketView()
        view.extUseAutoLayout()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        addSubViews([backImgV])
        backImgV.addSubViews([logoImgV,redPackView])
        backImgV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(300 * redproportion)
            make.height.equalTo(429 * redproportion)
        }
        logoImgV.snp.makeConstraints { (make) in
            make.left.top.equalTo(15)
            make.height.equalTo(18)
            make.width.equalTo(90)
        }
        redPackView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20 * redproportion)
            make.width.equalTo(236 * redproportion)
            make.height.equalTo(281 * redproportion)
            make.centerX.equalToSuperview()
        }
        
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismiss))
        self.addGestureRecognizer(tap)
    }
    
    //show
    func show(_ vc : UIViewController){
        guard let appDelegate  = UIApplication.shared.delegate else {
            return
        }
        if appDelegate.window != nil   {
            appDelegate.window??.rootViewController?.view.addSubview(self)
            appDelegate.window??.rootViewController?.view.bringSubviewToFront(self)
            self.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        var imgV = UIImage.themeImageNamed(imageName: "background")
        if LanguageTools.isHan() == false{
            imgV = UIImage.themeImageNamed(imageName: "background_english")
        }
        if let url = URL.init(string: entity.background){
            backImgV.yy_setImage(with: url, placeholder: imgV, options: YYWebImageOptions.allowBackgroundTask) { [weak self](img, url, type, stage, error) in
                self?.bscreenShot(vc)
            }
        }else{
            backImgV.image = imgV
            bscreenShot(vc)
        }
    }
    
    func bscreenShot(_ vc : UIViewController){
        self.layoutIfNeeded()
        if let image = backImgV.screenShot(){
            ShareHandler.share(vc, image: image, completionHandler: {
                self.shareSuccessBlock?()
                self.dismiss()
            })
        }
    }
    
    //disappear
    @objc func dismiss(){
        self.removeFromSuperview()
    }
    
    func setView(_ entity : EXCreateRedPacketEntity){
        self.entity = entity
//        var imgV = UIImage.themeImageNamed(imageName: "background")
//        if LanguageTools.isHan() == false{
//            imgV = UIImage.themeImageNamed(imageName: "background_english")
//        }
//        if let url = URL.init(string: entity.background){
//            backImgV.yy_setImage(with: url, placeholder: imgV , options: YYWebImageOptions.allowBackgroundTask, completion: nil)
//            backImgV.yy_setImage(with: url, placeholder: imgV, options: YYWebImageOptions.allowBackgroundTask) { (img, url, type, stage, error) in
//
//            }
//        }else{
//            backImgV.image = imgV
//        }
        redPackView.setView(entity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXRedPacketView: UIView {
    
    lazy var redPacketBackView : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "bigredenvelope")
        return imgV
    }()
    
    lazy var coinImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "redpacket_coin")
        return imgV
    }()
    
    lazy var coinLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textAlignment = .center
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.extColorWithHex("1F3F59")
        return label
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .center
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeRedPacket.text
        return label
    }()
    
    lazy var qrCode : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        return imgV
    }()
    
    lazy var promptLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeRedPacket.text
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "redpacket_send_longPress".localized()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([redPacketBackView])
        redPacketBackView.addSubViews([coinImgV,coinLabel,nameLabel,qrCode,promptLabel])
        redPacketBackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        coinImgV.snp.makeConstraints { (make) in
            make.height.width.equalTo(50 * redproportion)
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        coinLabel.snp.makeConstraints { (make) in
            make.height.equalTo(22)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(coinImgV)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.height.equalTo(22)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(coinImgV.snp.bottom).offset(8)
        }
        qrCode.snp.makeConstraints { (make) in
            make.height.width.equalTo(90 * redproportion)
            make.bottom.equalTo(promptLabel.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        promptLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.left.right.equalTo(nameLabel)
            make.height.equalTo(14)
        }
    }
    
    func setView(_ entity : EXCreateRedPacketEntity){
        if entity.shareUrl != ""{
            qrCode.image = QRCodeCreate().creteScancode(entity.shareUrl)
        }
        nameLabel.text = String.init(format: "redpacket_send_from".localized(), entity.nickName)
        
        coinLabel.text = entity.coinSymbol.aliasName()
        if entity.coinSymbol.count > 4{
            coinLabel.font = UIFont.ThemeFont.SecondaryBold
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

