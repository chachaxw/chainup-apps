//
//  EXSKlineShareView.swift
//  Chainup
//
//  Created by 柴伟东 on 2023/7/1.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
//MARK: fix 分享用的文案 以及 图片 提取 English: MARK: Copywriting and image extraction for fix sharing
public class EXSKlineShareView: UIView {
    
    var isSwap = false {
        didSet{
//            //更新合约的文案 English: Update the copy of the contract
//            shareBtn.setTitle("cp_content_text34".ex_localized(), for: UIControl.State.normal)
//            cancelBtn.setTitle("cp_overview_text56".ex_localized(), for: .normal)
            textLabel.text = "cp_stoporder_text4".ex_localized()
            
        }
    }
    

    
    lazy var contentView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        return iv
    }()
      
    lazy var bottomView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.card2
        return view
    }()
    
    lazy var iconView : UIImageView = {
        let view = UIImageView()
        view.extUseAutoLayout()
        view.image = UIImage.themeImageNamed(imageName: "AppIcon")
        return view
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = EXKitStanders.getAppName()
        return label
    }()
    
    lazy var textLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.MinimumRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = "common_share_detail".ex_localized()
        return label
    }()
   
    lazy var qrCodeImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        return imgV
    }()
    
//    lazy var shareBtn : UIButton = {
//        let btn = UIButton()
//        btn.extUseAutoLayout()
//        btn.addTarget(self, action: #selector(clickShareBtn), for: UIControl.Event.touchUpInside)
//        btn.backgroundColor = UIColor.ThemekLine.btnHighlight
//        btn.setTitle("common_share_confirm".localized(), for: .normal)
//        btn.setTitleColor(UIColor.white, for: .normal)
//        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
//        return btn
//    }()
//    let cancelBtn : UIButton = {
//        let button = UIButton()
//        button.setTitle("common_text_btnCancel".localized(), for: .normal)
//        button.ext_SetAddTarget(self, #selector(clickCancel))
//        button.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
//        button.setBackgroundImage(UIImage(named: ""), for: .normal)
//        button.backgroundColor = UIColor.ThemeView.card2
//        button.titleLabel?.font = UIFont.ThemeFont.HeadBold
//        button.layer.cornerRadius = 4
//        button.layer.masksToBounds = true
//        return button
//    }()
    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.exs_roundCorners(corners: .allCorners, radius: 12)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.mask
        addSubViews([contentView])
        contentView.addSubViews([bottomView])
        contentView.backgroundColor = UIColor.ThemeView.bg
        bottomView.addSubViews([iconView,nameLabel,textLabel,qrCodeImgV])
        contentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(45)
            make.left.equalToSuperview().offset(28)
            make.right.equalToSuperview().offset(-28)
            make.bottom.equalToSuperview().offset(-99)
        }

        bottomView.snp.makeConstraints { (make) in
            make.height.equalTo(76)
            make.left.right.bottom.equalToSuperview()
        }
        /// bottomView 子view English: /BottomView sub view
        iconView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.width.equalTo(44)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.right.equalTo(qrCodeImgV.snp.left).offset(-5)
            make.top.equalTo(iconView)
            make.height.equalTo(16)
        }
        textLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(nameLabel)
            make.bottom.equalTo(iconView)
            make.height.equalTo(14)
        }
        qrCodeImgV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
            make.height.width.equalTo(46)
        }
        
        setQRCode()
        
        
    }
    ///合约样式处理 English: /Contract Style Processing
    func swapConfig(){
        let imageBg = UIImageView()
        imageBg.contentMode = .scaleAspectFill
        imageBg.image = UIImage.exs_themeImageNamed(imageName: "public_share")
        bottomView.insertSubview(imageBg, at: 0)
        bottomView.layer.cornerRadius = 10
        bottomView.layer.masksToBounds = true
        imageBg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    public func setImg(_ img : UIImage){
        contentView.image = img
    }
    
    func setQRCode(){
        qrCodeImgV.image = QRCodeCreate().creteScancode(EXSwapPrivateConfig.shared.sharePage)
    }
    
    public var vc = UIViewController()
    
    public func show(){
        self.vc.view.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard self != nil else{
                return
            }
            self!.clickShareBtn()
        }
    }

    @objc func clickShareBtn(){
        let image = self.contentView.asImage()
        ShareHandler.share(self.vc, image:image, completionHandler: {
            self.removeFromSuperview()
        })
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
        
}



