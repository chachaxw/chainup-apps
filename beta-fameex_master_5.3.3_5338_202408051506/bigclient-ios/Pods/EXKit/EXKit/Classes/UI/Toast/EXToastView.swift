////
////  EXToast.swift
////  Chainup
////
////  Created by 柴伟东 on 2022/2/28.
////  Copyright © 2022 Chainup. All rights reserved.
////


import UIKit
private let hudTag = 1293433

public extension UIView {

    ///////////////////////////////////////////////////////////////////////////////
    /// 显示Toast hud(view)
    /// - Parameters:
    ///   - title: msg
    ///   - completion: completion
    func makeToast(_ title: String, completion:(() -> Void)? = nil) {
        var hud: MBProgressHUD
        if let _hud = getMBProgressHUD() {
            hud = _hud
        } else {
            hud = createMBProgressHUD(title)
        }
        setTitle(title, hud)
        hud.show(animated: true)
        hud.hide(animated: true, afterDelay: 2.0)
//        hud.completionBlock = completion
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            completion?()
        }
    }


    /// 显示加载状态hud(view)
     func makeLoading() {
        var hud: MBProgressHUD
        if let _hud = getMBProgressHUD() {
            hud = _hud
            setLoading(hud)
        } else {
            hud = createIndicatorMBProgressHUD()
        }

        hud.show(animated: true)
    }


    /// 隐藏hud(view)
    func hideProgressHUD(_ animated: Bool = true) {
        let hud = getMBProgressHUD()
        hud?.hide(animated: animated)
    }

    ///////////////////////////////////////////////////////////////////////////////

    /// 显示Toast hud(keyWindow)
    /// - Parameters:
    ///   - title: title
    ///   - completion: completion
    class func makeToast(_ title: String, completion:(() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.makeToast(title, completion: completion)
        }
    }


    /// 显示加载hud(keyWindow)
    class func makeLoading() {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.makeLoading()
        }
        
    }


    /// 隐藏hud(keyWindow)
    class func hideProgressHUD() {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.hideProgressHUD()
        }
    }

    ///////////////////////////////////////////////////////////////////////////////
    // Private method
    private func getMBProgressHUD() -> MBProgressHUD?{
        for view in subviews {
            if view.tag == hudTag {
                if view is MBProgressHUD {
                    return view as? MBProgressHUD
                } else {
                    return nil
                }
            }
        }
        return nil
    }

    private func createMBProgressHUD(_ title: String, offsetY: CGFloat = 0) -> MBProgressHUD {
        let hud = MBProgressHUD(view: self)
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = .black.withAlphaComponent(0.5)
        hud.bezelView.layer.cornerRadius = 5.0
        hud.animationType = .zoom
        hud.offset = .init(x: hud.offset.x, y: offsetY)
        hud.removeFromSuperViewOnHide = true
        hud.marginH = 16
        hud.marginV = 12
        hud.tag = hudTag
        addSubview(hud)
        setTitle(title, hud)
        return hud
    }

    private func setTitle(_ title: String,_ hud: MBProgressHUD) {
        hud.mode = .text
        hud.label.text = title
        hud.label.font =  UIFont.systemFont(ofSize: 16)//.themeFont.bodyRegular
        hud.label.textColor = .white
        hud.label.numberOfLines = 0
    }

    private func createIndicatorMBProgressHUD(offsetY: CGFloat = 0) -> MBProgressHUD {
        let hud = MBProgressHUD(view: self)
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = .black.withAlphaComponent(0.5)
        hud.bezelView.layer.cornerRadius = 5.0
        hud.animationType = .zoom
        hud.offset = .init(x: hud.offset.x, y: offsetY)
        hud.removeFromSuperViewOnHide = true
        hud.marginH = 16
        hud.marginV = 12
        hud.tag = hudTag
        addSubview(hud)
        setLoading(hud)
        return hud
    }

    private func setLoading(_ hud: MBProgressHUD) {
        hud.mode = .customView
        let v = UIActivityIndicatorView()
        v.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        v.style = .whiteLarge
        v.startAnimating()
        v.hidesWhenStopped = true
        hud.customView = v;
    }


    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

}
