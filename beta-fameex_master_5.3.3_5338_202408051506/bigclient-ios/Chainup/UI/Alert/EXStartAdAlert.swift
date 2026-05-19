//
//  EXStartAdAlert.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/23.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXStartAdAlert: UIView {
    typealias AlertCallback = () -> ()
    typealias AdBannerCallback = (String) -> ()
    var cancelCallback : AlertCallback?
    var clickAdCallback : AdBannerCallback?

    let advertWidth = SCREEN_WIDTH - 108
    
    var href:String = ""
    
    lazy var bgV:UIView = {
        let v = UIView()
        v.extSetCornerRadius(10)
        v.backgroundColor = UIColor.ThemeView.bg
        return v
    }()
    
//    lazy var seperator:UIView = {
//        let v = UIView()
//        v.backgroundColor = UIColor.white
//        return v
//    }()
    
    lazy var adImageView:UIImageView = {
        let adimg = UIImageView()
        adimg.contentMode = .scaleAspectFill
        return adimg
    }()
    
    lazy var closeBtn:UIButton = {
        let closeb = UIButton.init(type: .custom)
        let icon = UIImage.themeImageNamed(imageName: "home_close")
        closeb.setImage(icon, for: .normal)
        closeb.setImage(icon, for: .highlighted)
        closeb.addTarget(self, action:#selector(clickActionBtn), for: .touchUpInside)
        return closeb
    }()

    override init(frame: CGRect) {
        super.init(frame:.zero)
        self.backgroundColor = UIColor.clear
        self.addSubViews([bgV,closeBtn])
        bgV.addSubview(adImageView)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didTapBg))
        self.addGestureRecognizer(tapGesture)
        
        let advertHeight = (advertWidth * 1.3558).rounded(.up)
        bgV.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(advertWidth)
            make.height.equalTo(advertHeight)
        }
        
        adImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
//        seperator.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.width.equalTo(0.5)
//            make.top.equalTo(adImageView.snp.bottom)
//            make.bottom.equalTo(closeBtn.snp.top)
//        }
//
        closeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(adImageView.snp.bottom)
            make.centerX.equalToSuperview()
//            make.width.equalTo(33)
//            make.height.equalTo(33)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindHref(ahref: String) {
        self.href = ahref
    }
    
    @objc func clickActionBtn(_ btn : UIButton){
        EXAlert.dismissEnd {
            self.cancelCallback?()
        }
    }
    
    
    @objc func didTapBg() {
        EXAlert.dismiss()
        if self.href.count > 0 {
            self.clickAdCallback?(self.href)
        }
    }
}
