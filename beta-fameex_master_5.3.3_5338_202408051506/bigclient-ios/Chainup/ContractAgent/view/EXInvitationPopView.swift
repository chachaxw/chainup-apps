//
//  EXInvitationPopView.swift
//  Chainup
//
//  Created by chainup on 2023/9/2.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit

let EXInvitationPopViewImageRatio = 315/440
class EXInvitationPopView: UIView {
    
    lazy var titleLabel: UILabel = {
        let v = UILabel(text: "invite_poster_tips".localized(), font: .Ex.bold(24), textColor: .white)
        v.textAlignment = .center
        v.numberOfLines = 2
        return v
    }()

    lazy var bgImgView : UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "facetoface")
        v.layer.cornerRadius = 6
        v.layer.masksToBounds = true
        v.contentMode = .scaleAspectFit
        return v
        
    }()

    lazy var cancelButton:UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "shutdown"), for: .normal)
        return b
    }()
    lazy var codeImageView:UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
        
    }()
    
    lazy var codeBgView:UIView = {
    
        let v =  UIView()
        v.backgroundColor = UIColor.white
        v.layer.cornerRadius = 6
        return v
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cancelButton.rx.tap.subscribe(onNext: { (_) in
            EXAlert.dismiss()
        }).disposed(by: disposeBag)
        
        addSubViews([bgImgView, titleLabel, codeBgView, cancelButton])
        codeBgView.addSubViews([codeImageView])
        
        bgImgView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 315, height: 416))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        codeImageView.image = QRCodeCreate().creteScancode(UserInfoEntity.sharedInstance().inviteUrl)

        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(bgImgView.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 44))
        }

        codeBgView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bgImgView).offset(-91)
            make.height.width.equalTo(191)
        }

        codeImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(171)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(bgImgView.snp.top).offset(30)
            make.centerX.equalTo(bgImgView)
            make.width.equalTo(bgImgView).offset(-36 * 2)
            make.bottom.equalTo(codeBgView.snp.top).offset(-20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(bgImageUrl:String, inviteUrl: String?) {
        
        if let inviteUrl = inviteUrl {
            codeImageView.image = QRCodeCreate().creteScancode(inviteUrl)
        }
            
        if let availableUrl = URL(string: bgImageUrl) {
            bgImgView.yy_setImage(with: availableUrl, placeholder: UIImage(named: "facetoface"))
        }
    }
}
