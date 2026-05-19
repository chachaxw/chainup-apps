//
//  EXIDAuthenticStatusView.swift
//  Chainup
//
//  Created by cwd on 2023/11/1.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXIDAuthenticStatusView: EXCustomBaseView {
    static var viewHeight: CGFloat = 44
    
    
    var model: EXIDAuthenticModel? {
        didSet{
            titleLabel.text = model?.levelName
            currentShowLabel.isHidden = !(model?.isCurrent ?? false)
            img.isHidden = !(model?.isCurrent ?? false)
        }
    }
    override func setSubView() {
        self.backgroundColor = .Ex.fill1
        self.addSubViews([titleLabel,img,currentShowLabel,line])
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        currentShowLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        img.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.centerY.equalToSuperview()
            make.right.equalTo(currentShowLabel.snp.left).offset(-6)
        }
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
        }
        
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(16), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    
    lazy var currentShowLabel: UILabel = {
        let label = UILabel(text:"kyc_page_current".localized(), font: .Ex.medium(14), textColor: UIColor.ThemeState.success, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var img : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage.themeImageNamed(imageName: "individual_identity_Current")
        return img
    }()
    
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.Ex.fill4
        return v
    }()
    
}



class EXIDAuthenticSectionHeaderView: UITableViewHeaderFooterView {
    
    static func getViewHeight(type :EXIDAuthenticType) -> CGFloat{
        return type == .requirement ? 40 : 32
    }
    
    var type: EXIDAuthenticType = .right {
        didSet{
            contentLabel.text = type.destionTitle
            let imageName = type == .right ? "individual_identity_equity" : "individual_identity_demand"
            let image = UIImage.themeImageNamed(imageName: imageName)
            iconImg.image = image
        }
    }
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configSubView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configSubView(){
        self.backgroundColor = UIColor.Ex.fill1
        self.addSubViews([iconImg,contentLabel])
        initLayout()
    }
    
  
    lazy var iconImg : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage.themeImageNamed(imageName: "individual_identity_Current")
        return img
    }()
    ///Result display
    lazy var contentLabel: UILabel = {
        let label = UILabel(text: "权益".ex_localized(), font: UIFont.Ex.medium(14), textColor: UIColor.Ex.text2, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    func initLayout() {
        iconImg.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.height.width.equalTo(16)
            make.bottom.equalToSuperview()
        }
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(40)
            make.height.equalTo(16)
            make.bottom.equalToSuperview()
        }
    }
}

class EXIDAuthenticListCell: EXBaseCell {
    static var viewHeight: CGFloat = 32
    
    var model: EXIDAuthenticItemModel? {
        didSet{
            
            guard let m = model else {
                return
            }
            titleLabel.text = m.title
            if m.type == .right {
                contentLabel.text = m.content
                contentLabel.isHidden = false
            }else{
                contentLabel.isHidden = true
            }
        }
    }
    override func setUpView() {
        self.backgroundColor = UIColor.Ex.fill1
        self.contentView.addSubViews([titleLabel,contentLabel])
        initLayout()
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: "权益".ex_localized(), font: UIFont.Ex.medium(12), textColor: UIColor.Ex.text3, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel(text: "禁止".ex_localized(), font: UIFont.Ex.medium(12), textColor: UIColor.Ex.text2, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    func initLayout() {
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(16)
            make.height.equalTo(16)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
        }
    }
}


class EXIDAuthenticListBtnCell: EXBaseCell {
    static var viewHeight: CGFloat = 44 + 16
    var gotoKycBlock: EXComVoidBlock?
    var model: EXIDAuthenticItemModel? {
        didSet{
            btn.setTitleColor(.white, for: .normal)
            btn.setTitle(model?.btnTitle, for: .normal)
            btn.isEnabled = model?.btnEnble ?? false
        }
    }
    override func setUpView() {
        self.backgroundColor = UIColor.Ex.fill1
        self.contentView.addSubViews([btn])
        initLayout()
    }
    
    
    lazy var btn : EXButton = {
        let btn = EXButton()
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.setTitle("kyc_page_button_verify".localized(), for: .normal)
        return btn
    }()
    
    
    func initLayout() {
        btn.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc func clickBtn(){
        self.gotoKycBlock?()
    }
}

