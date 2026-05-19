//
//  EXNoLoginAccountCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/12.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXNoLoginAccountCell: EXHomeBaseCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    lazy var assetsLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = LanguageTools.getString(key: "home_text_assets")
        return label
    }()
    
    lazy var promptLoginLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = LanguageTools.getString(key: "home_action_notLogin")
        return label
    }()
    
    lazy var loginBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.setTitle(LanguageTools.getString(key: "login_action_login"), for: UIControl.State.normal)
        btn.extSetBorderWidth(0.5, color: UIColor.ThemeView.border.withAlphaComponent(0.5))
        btn.backgroundColor = UIColor.ThemeTab.bg.withAlphaComponent(0.5)
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryBold
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickLoginBtn))
        return btn
    }()
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: EXHomeViewModel.getHomeNoLoginDefaultImage())
        return imgV
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addSubViews([assetsLabel,promptLoginLabel,loginBtn,imgV])
        assetsLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(22)
            make.right.equalTo(imgV.snp.left).offset(-10)
        }
        promptLoginLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(assetsLabel.snp.bottom).offset(2)
            make.height.equalTo(17)
            make.right.equalTo(imgV.snp.left).offset(-10)
        }
        loginBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(promptLoginLabel.snp.bottom).offset(15)
            make.height.equalTo(30)
            make.width.equalTo(110)
        }
        imgV.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(116)
        }
    }
    
    //Click on the login button
    @objc func clickLoginBtn(){
        BusinessTools.modalLoginVC()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

