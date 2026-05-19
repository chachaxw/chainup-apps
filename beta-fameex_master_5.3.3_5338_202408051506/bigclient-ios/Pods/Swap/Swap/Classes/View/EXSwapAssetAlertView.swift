//
//  EXSwapAssetAlertView.swift
//  Chainup
//
//  Created by ZYJ on 2023/12/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

public class EXSwapAssetAlertView: UIView {

    public typealias AlertCallback = (Int) -> ()
    public var alertCallback : AlertCallback?
    
    lazy var mainView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.Ex.fill1 //ThemeView.bg
        self.addSubview(view)
        return view
    }()
    
    lazy var contentLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.textAlignment = .left
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        label.numberOfLines = 0
        return label
    }()
    
    lazy var headBg : UIView = {
        let view = UIView()
//        if EXThemeManager.isNight() {
//            view.backgroundColor = UIColor.extColorWithHex("0F192A")
//        } else {
//            view.backgroundColor = UIColor.extColorWithHex("F0F7FF")
//        }
        view.backgroundColor = UIColor.Ex.fill6
        return view
    }()
    
    lazy var iconView : UIImageView = {
        let icon = UIImageView(image: UIImage.svg_themeImageNamed(imageName: "img_optional"))
        return icon
    }()
    
    lazy var confirm : UIButton = {
        let btn = UIButton()
        btn.ext_UseAutoLayout()
        btn.titleLabel?.textAlignment = .right
        btn.ext_SetAddTarget(self, #selector(clickBuyCoin))
        btn.setTitle("cp_content_text24".ex_localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .normal)
        btn.titleLabel!.font = UIFont.ThemeFont.BodyBold
        btn.titleLabel?.textAlignment = .right
        return btn
    }()
    
    lazy var cancel : UIButton = {
        let btn = UIButton()
        btn.ext_UseAutoLayout()
        btn.titleLabel?.textAlignment = .right
        btn.ext_SetAddTarget(self, #selector(clickCancel))
        btn.setTitle("cp_overview_text56".ex_localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorDark, for: .normal)
        btn.titleLabel!.font = UIFont.ThemeFont.BodyBold
        btn.titleLabel?.textAlignment = .right
        return btn
    }()
    
    @objc func clickBuyCoin(_ : UIButton){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            self.alertCallback?(1)
        }
        EXSwapAssetAlertView.dismiss(v: self)
    }
    
    @objc func clickCancel(_ : UIButton){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            self.alertCallback?(0)
        }
        EXSwapAssetAlertView.dismiss(v: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: EXSCREEN_WIDTH, height: EXS_SCREEN_HEIGHT))
        self.backgroundColor =  UIColor.ThemeView.mask
        self.addSubview(mainView)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        mainView.frame = frame
        mainView.center = self.center
        mainView.layer.cornerRadius = 3
        mainView.layer.masksToBounds = true
        mainView.exs_addSubViews([contentLabel,headBg,iconView,confirm,cancel])
        headBg.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(175)
        }
        iconView.snp.makeConstraints { (make) in
//            make.height.equalTo(139)
//            make.width.equalTo(144)
//            make.centerX.equalTo(mainView.frame.width * 0.5)
//            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(-2)
            make.bottom.equalTo(headBg)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(headBg.snp.bottom).offset(15)
            make.height.equalTo(44)
        }
        confirm.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(contentLabel.snp.bottom).offset(26)
        }
        cancel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.right.equalTo(confirm.snp.left).offset(-30)
            make.top.equalTo(contentLabel.snp.bottom).offset(26)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- interface
    public static func createAlert(contentStr: String, btnTitle: String, frame:CGRect) -> EXSwapAssetAlertView {
        let alert = EXSwapAssetAlertView(frame: frame)
        alert.contentLabel.text = contentStr
        alert.confirm.setTitle(btnTitle, for: .normal)
        return alert
    }
    @objc func click(){
        EXSwapAssetAlertView.dismiss(v: self)
    }
    public func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    static func dismiss(v: UIView) {
        for view in UIApplication.shared.keyWindow!.subviews {
            if view is EXSwapAssetAlertView {
                v.removeFromSuperview()
                break
            }
        }
    }
}
