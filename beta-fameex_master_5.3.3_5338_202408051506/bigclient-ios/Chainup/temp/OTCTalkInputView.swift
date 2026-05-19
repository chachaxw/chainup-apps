//
//  OTCTalkInputView.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/18.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class OTCTalkInputView: UIView {
    
    //Click to send a callback
    typealias ClickSendBtnBlock = (String) -> ()
    var clickSendBtnBlock : ClickSendBtnBlock?
    
    //Point Image Callback
    typealias ClickImgBtnBlock = () -> ()
    var clickImgBtnBlock : ClickImgBtnBlock?
    

    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.bg
        view.extSetCornerRadius(4)
        view.extSetBorderWidth(1, color: UIColor.ThemeView.bg)
        return view
    }()
    
    lazy var sendBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.extSetTitle(LanguageTools.getString(key: "otc_action_sendmsg"), 14, UIColor.ThemeView.highlight, UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickSendBtn))
        return btn
    }()
    
    lazy var textField : UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor.ThemeLabel.colorLite
        textField.extUseAutoLayout()
        return textField
    }()
    
    lazy var imgBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.extSetAddTarget(self, #selector(clickImgBtn))
        btn.setImage(UIImage.themeImageNamed(imageName: "fiat_photo"), for: UIControl.State.normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([backView , sendBtn])
        backView.addSubViews([textField,imgBtn])
        textField.setPlaceHolderAtt("common_tip_pleaseInputWord".localized(), color: UIColor.ThemeLabel.colorDark, font: 14)
        backView.snp.makeConstraints { (make) in
            make.height.equalTo(38)
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(sendBtn.snp.left).offset(-20)
            make.centerY.equalToSuperview()
        }
        let sendMsg = "otc_action_sendmsg".localized()
        let btnWidth = sendMsg.textSizeWithFont(UIFont.ThemeFont.BodyRegular, width: CGFloat.greatestFiniteMagnitude).width + 10
        
        sendBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(btnWidth)
        }
        
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.right.equalTo(imgBtn.snp.left).offset(-20)
            make.height.equalTo(25)
        }
        imgBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(20)
            make.width.equalTo(22)
            make.centerY.equalToSuperview()
        }
        
    }
    
    //Click to send
    @objc func clickSendBtn(){
        if textField.text == ""{
            EXAlert.showFail(msg: "common_tip_pleaseInputWord".localized())
            return
        }
        clickSendBtnBlock?(textField.text ?? "")
    }
    
    //Click on the image
    @objc func clickImgBtn(){
        clickImgBtnBlock?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

