//
//  EXLoginAccountCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/12.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXLoginAccountCell: EXHomeBaseCell {
    
    var model = EXHomeAssetModel()
    
    //My assets
    lazy var myassetLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = LanguageTools.getString(key: "home_text_assets")
        return label
    }()
    
    //Hide Button
    lazy var hiddenBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setImage(UIImage.themeImageNamed(imageName: "login_eyeoff"), for: UIControl.State.selected)
        btn.setImage(UIImage.themeImageNamed(imageName: "login_eyeon"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickHiddenBtn(_:)))
        return btn
    }()
    
    lazy var hilineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var allBlanceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorHighlight
        label.text = "assets_text_total".localized()
        label.font = UIFont.ThemeFont.SecondaryBold
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var rightImgV :UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.contentMode = .scaleAspectFit
        imgV.image = EXKitBundle.image(named: "public_positions_arrow_right")
        return imgV
    }()
    
    lazy var assetsLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        return label
    }()
    
    lazy var equivalentLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryBold
        return label
    }()
    
    lazy var iconImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "home_assetentry")
        return imgV
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubViews([myassetLabel,hiddenBtn,hilineV,allBlanceLabel,rightImgV,assetsLabel,equivalentLabel,iconImgV])
        hilineV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalToSuperview().offset(46)
        }
        myassetLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(22)
            make.right.equalTo(hiddenBtn.snp.left).offset(-10)
        }
        hiddenBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.lessThanOrEqualTo(16)
            make.width.equalTo(16)
            make.centerY.equalTo(myassetLabel)
        }
        allBlanceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(17)
            make.top.equalTo(hilineV.snp.bottom).offset(15)
        }
        rightImgV.snp.makeConstraints { (make) in
            make.left.equalTo(allBlanceLabel.snp.right).offset(3)
            make.height.width.equalTo(8.5)
            make.centerY.equalTo(allBlanceLabel)
        }
        assetsLabel.snp.makeConstraints { (make) in
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(iconImgV.snp.left).offset(-10)
            make.top.equalTo(allBlanceLabel.snp.bottom).offset(10)
        }
        equivalentLabel.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(iconImgV.snp.left).offset(-10)
            make.top.equalTo(assetsLabel.snp.bottom).offset(3)
        }
        iconImgV.snp.makeConstraints { (make) in
            make.height.equalTo(94)
            make.width.equalTo(140)
            make.right.equalToSuperview()
            make.top.equalTo(hilineV.snp.bottom)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickView))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func clickView(){
        let action = "coin"
        EXNavigationHandler.sharedHandler.commandToAsset(action)
    }
    
    //Click to hide
    @objc func clickHiddenBtn(_ btn : UIButton){
        btn.isSelected = !btn.isSelected
        XUserDefault.switchAssets(btn.isSelected)
        setView(self.model)
    }
    
    func setView(_ model : EXHomeAssetModel){
        self.model = model
        let bool = XUserDefault.assetPrivacyIsOn()
        hiddenBtn.isSelected = bool
        if bool {
            assetsLabel.text = String.privacyString()
            equivalentLabel.text =  String.privacyString()
        }else{
            assetsLabel.attributedText = model.assetsAtt
            equivalentLabel.text = model.rmb
        }
    }
    
    
}

