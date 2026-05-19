//
//  UIViewControllerExt.swift
//  Chainup
//
//  Created by zewu wang on2020/8/18.
//  Copyright ©2020年 zewu wang. All rights reserved.
//

import UIKit

extension UIViewController{
    
    @objc open func popBack(_ animated : Bool = true, _ backToRoot:Bool = false ){
        if let vcs = self.navigationController?.viewControllers ,  vcs.count > 1 {
            if backToRoot {
                self.navigationController?.popToRootViewController(animated: animated)
            }else {
                self.navigationController!.popViewController(animated: animated)
            }
        } else {
            self.dismiss(animated: animated, completion: nil)
        }
    }
    /// 截取当前屏幕
    public func screenshot() -> UIImage? {
        var imageSize = CGSize.zero
        
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation.isPortrait {
            imageSize = UIScreen.main.bounds.size
        } else {
            imageSize = CGSize(width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        }
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        for window in UIApplication.shared.windows {
            context.saveGState()
            context.translateBy(x: window.center.x, y: window.center.y)
            context.concatenate(window.transform)
            context.translateBy(x: -window.bounds.size.width * window.layer.anchorPoint.x, y: -window.bounds.size.height * window.layer.anchorPoint.y)
            if orientation == .landscapeLeft {
                context.rotate(by: CGFloat(Double.pi * 0.5))
                context.translateBy(x: 0, y: -imageSize.width)
            } else if orientation == .landscapeRight {
                context.rotate(by: -CGFloat(Double.pi * 0.5))
                context.translateBy(x: -imageSize.height, y: 0)
            } else if orientation == .portraitUpsideDown {
                context.rotate(by: CGFloat(Double.pi * 0.5))
                context.translateBy(x: -imageSize.width, y: -imageSize.height)
            }
            if window.responds(to: #selector(UIWindow.drawHierarchy(in:afterScreenUpdates:))) {
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }else {
                window.layer.render(in: context)
            }
            context.restoreGState()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

