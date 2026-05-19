//
//  ThemeImages.swift
//  Chainup
//
//  Created by liuxuan on2020/3/30.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit

public extension UIImage {
    
    static func themeImageNamedFromPod(imageName:String) -> UIImage {
        
        guard let podBundle = Bundle.getPodImageBunlde(podName: "EXKit") else{
            return UIImage()
        }
        
        var newName = imageName
        if EXThemeManager.isNight() {
            newName += "_night"
        }else{
            newName += "_daytime"
        }
        if let img = UIImage(named: newName, in: podBundle, compatibleWith: nil){
            return img
        }
        if let img = UIImage(named: imageName, in: podBundle, compatibleWith: nil){
            return img
        }
        
        return UIImage()
    }
    
    
    static func themeImageNamed(imageName:String) -> UIImage {
        if EXThemeManager.isNight() {
            let temp = UIImage.init(named:imageName + "_night")
            if let exsitImg = temp {
                return exsitImg
            }else {
                if let img = UIImage.init(named: imageName) {
                    return img
                }
            }
            return UIImage()
        }else {
            let temp = UIImage.init(named:imageName + "_daytime")
            if let exsitImg = temp {
                return exsitImg
            }else {
                if let img = UIImage.init(named: imageName) {
                    return img
                }
            }
            return UIImage()
        }
    }
    
    static func themeImageNamed(imageName:String,kline:Bool) -> UIImage {
        if EXThemeManager.current == EXThemeManager.night ||
            (kline == true && EXThemeManager.current == EXThemeManager.dayKlinenight) {
            let temp = UIImage.init(named:imageName + "_night")
            if let exsitImg = temp {
                return exsitImg
            }else {
                if let img = UIImage.init(named: imageName) {
                    return img
                }
            }
            return UIImage()
        }else {
            let temp = UIImage.init(named:imageName + "_daytime")
            if let exsitImg = temp {
                return exsitImg
            }else {
                if let img = UIImage.init(named: imageName) {
                    return img
                }
            }
            return UIImage()
        }
    }
    
    static func themeImageNamedFromPod(imageName:String,kline:Bool) -> UIImage {
        if EXThemeManager.current == EXThemeManager.night ||
            (kline == true && EXThemeManager.current == EXThemeManager.dayKlinenight) {
            let temp = UIImage.init(named:imageName + "_night")
            if let exsitImg = temp {
                return exsitImg
            }else {
                if let img = UIImage.init(named: imageName) {
                    return img
                }
            }
            return UIImage()
        }else {
            let temp = UIImage.init(named:imageName + "_daytime")
            if let exsitImg = temp {
                return exsitImg
            }else {
                if let img = UIImage.init(named: imageName) {
                    return img
                }
            }
            return UIImage()
        }
    }
}

extension Bundle{
    ///pod.bundle
    class func getPodImageBunlde(podName:String) -> Bundle? {
        let podFrameWork = self.getCutsomFrameWorkBundle(podName: podName)
        guard let podFrameWork = podFrameWork else {
            return nil
        }
        if let bundlePath = podFrameWork.path(forResource: "EXKitResource", ofType: ".bundle") {
//            print("bundlePath=\(bundlePath)")
            if let  b = Bundle(path: bundlePath) {
                return b
            }
        }
        return nil
    }
    class func getCutsomFrameWorkBundle(podName:String) -> Bundle? {
        let podframework = Bundle.main.resourcePath! + "/Frameworks/\(podName).framework/"
        return Bundle(path: podframework)
    }
}

public class EXKitBundle: EXBundle {
    public override class var name: String { "EXKitResource" }
}
/*
  5.0的图单独放在这里,方便直接替换
 */
public class EXKitFiveBundle: EXBundle {
    public override class var name: String { "FiveSvg" }
}
