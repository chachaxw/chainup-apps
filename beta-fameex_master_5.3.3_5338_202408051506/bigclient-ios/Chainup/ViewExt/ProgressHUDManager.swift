//
//  ProgressHVD.swift
//  AppProject
//
//  Created by zewu wang on 2020/8/2.
//  Copyright © 2020年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import Lottie

public class EXHUDManager {
    
    class func viewWithShow() -> UIView {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindow.Level.normal {
            let windowArray = UIApplication.shared.windows
            
            for tempWin in windowArray {
                if tempWin.windowLevel == UIWindow.Level.normal {
                    window = tempWin;
                    break
                }
            }
            
        }
        return window!
    }
    
    class func showLoading1() {
        var hud: MBProgressHUD! = MBProgressHUD.forView(self.viewWithShow())
        
        if hud == nil {
            hud = MBProgressHUD.showAdded(to: self.viewWithShow(), animated: true)
        }
        
        hud.mode = .customView
        
        hud.removeFromSuperViewOnHide = true
        hud.bezelView.style = .solidColor
        hud.contentColor = UIColor.clear
        hud.bezelView.backgroundColor = UIColor.clear
        
        let imgV = LottieLoadingView()
        imgV.backgroundColor = .Ex.fill5
        imgV.extUseAutoLayout()
        imgV.play()
        
        hud.customView = imgV
        hud.show(animated: true)
        
        imgV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
    }
    
    class func hideLoading1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let hud = MBProgressHUD.forView(self.viewWithShow()) {
                hud.hide(animated: true)
            }
        }
    }
    
    class func animation1() -> CABasicAnimation{
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.fillMode = CAMediaTimingFillMode.forwards;
        animation.toValue = Double.pi * 2.0
        animation.duration = 1
        animation.repeatCount = Float.greatestFiniteMagnitude
        return animation
    }
    
}

class XHUDManager : UIView{
    
    //MARK:单例
    public static var sharedInstance : XHUDManager{
        struct Static {
            static let instance : XHUDManager = XHUDManager()
        }
        return Static.instance
    }
    
    lazy var animationV: LottieLoadingView = {
        let v = LottieLoadingView()
        v.extUseAutoLayout()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
    }
    
    func getImgV(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.animationV.backgroundColor = .Ex.fill5
            self.animationV.play()
            self.addSubview(self.animationV)
            self.animationV.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 60, height: 60))
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loading(){
        dismissWithDelay{}
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        getImgV()
        appDelegate.window??.rootViewController?.view.addSubview(self)
    }
    
    func dismissWithDelay(_ f : @escaping (() -> ())){
        self.animationV.removeFromSuperview()
        self.removeFromSuperview()
        f()
    }
}

extension UIView {
    func showLoading1() {
        endEditing(true)
        var hud: MBProgressHUD! = MBProgressHUD.forView(self)
        
        if hud == nil {
            hud = MBProgressHUD.init(view: self)
        }
        
        hud.mode = .customView
        
        hud.removeFromSuperViewOnHide = true
        hud.bezelView.style = .solidColor
        hud.contentColor = UIColor.clear
        hud.bezelView.backgroundColor = UIColor.clear
        
        let imgV = LottieLoadingView()
        imgV.backgroundColor = .Ex.fill5
        imgV.extUseAutoLayout()
        imgV.play()
        
        hud.customView = imgV
        addSubview(hud)
        
        hud.show(animated: true)
        
        imgV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
    }
    
    func hideLoading1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let hud = MBProgressHUD.forView(self) {
                hud.hide(animated: true)
            }
        }
    }
    
    func animation1() -> CABasicAnimation{
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.toValue = Double.pi * 2.0
        animation.duration = 1
        animation.repeatCount = Float.greatestFiniteMagnitude
        return animation
    }
}



public class LottieLoadingView: UIView {
    
    private lazy var animationV: LottieAnimationView = {
        let v = LottieAnimationView(name: "loading_overallsituation")
        v.loopMode = .loop
        v.extUseAutoLayout()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        extSetCornerRadius(8)
        addSubview(animationV)
        animationV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    func play() {
        self.animationV.updateColor(keypaths: ["转动.椭圆 1.描边 1.Color"],
                                    color: .Ex.named(.fill1, color: EXTheme.isDark ? .light : .dark))
        self.animationV.play()
    }
    
    func updateColor(keypaths:[String]? = [], color: UIColor? = nil) {
        self.animationV.updateColor(keypaths: keypaths, color: color)
    }
    
}

