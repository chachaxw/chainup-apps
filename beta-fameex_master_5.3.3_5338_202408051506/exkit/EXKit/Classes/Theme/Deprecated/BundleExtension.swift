//
//  BundleExtension.swift
//  EXBaseUIKit
//
//  Created by cwd on 2022/7/6.
//

import Foundation
extension Bundle{
    
    /**
     Frameworks
     pod.Frameworks/pod.bundle
     */
    ///pod.Frameworks
    class func getPodFrameWorkBundle(podName:String) -> Bundle? {
        let podframework = Bundle.main.resourcePath! + "/Frameworks/\(podName).framework/"
        return Bundle(path: podframework)
    }
    ///pod.bundle
    class func getPodBunlde(podName:String) -> Bundle? {
        let podFrameWork = self.getPodFrameWorkBundle(podName: podName)
        guard let podFrameWork = podFrameWork else {
            return nil
        }
        if let bundlePath = podFrameWork.path(forResource: podName, ofType: ".bundle") {
//            print("bundlePath=\(bundlePath)")
            if let  b = Bundle(path: bundlePath) {
                return b
            }
        }
        return nil
    }
    
    ///pod.bundle
    class func getImageBunlde(podName:String) -> Bundle? {
        let podFrameWork = self.getPodFrameWorkBundle(podName: podName)
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
        
    ///获取 pod bundle 其他资源 如plist文件
    class func getPlistResource(named name: String, podName: String) -> NSDictionary? {
        let bundle = getPodFrameWorkBundle(podName: podName)
        guard let bundle = bundle else {
            return nil
        }
        let temp = bundle.path(forResource: name, ofType: nil)
        guard let temp = temp else {
            return nil
        }
        print("pod temp =>\(temp)")
        let content = NSDictionary(contentsOfFile: temp)
        print("content = >\(content)")
        return content
    }

    
    ///获取 pod bundle 其他资源 name 需要+ 类型
    class func getPodResource(named name: String, podName: String, bundleName: String? = nil) {
        var filePath = Bundle.main.resourcePath! + "/Frameworks/\(podName).framework/"
        if bundleName != nil{
            filePath += "/\(bundleName!).bundle"
        }
        print("pod filePath =>\(filePath)")
        let newbundle = Bundle(path: filePath)
        guard let newbundle = newbundle else{return}
        let temp = newbundle.path(forResource: name, ofType: nil)
        guard let temp = temp else {
            return
        }
        print("pod temp =>\(temp)")
        let content = NSDictionary(contentsOfFile: temp)
        print("content = >\(content)")
    }
}

//🔥：此方法可以获取任意 Pod 中图片，只需要知道 pod 名称， bundle 名称和图片名称即可（bundle 和pod 同名可不传）
//    目前用于查找 “Frameworks/*.framework/*.bundle/*.car" 中资源。
//🌰：

@objc public extension UIImage{
    ///获取 pod bundle 图片资源
    convenience init?(named name: String, podClass: AnyClass, bundleName: String? = nil) {
        let bName = bundleName ?? "\(podClass)"
        if let image = UIImage(named: "\(bName).bundle/\(name)"), let cgImage = image.cgImage{
            self.init(cgImage: cgImage)
        } else {
            let filePath = Bundle(for: podClass).resourcePath! + "/\(bName).bundle"
            guard let bundle = Bundle(path: filePath) else { return nil}
            self.init(named: name, in: bundle, compatibleWith: nil)
        }
    }

    ///获取 pod bundle 图片资源
    convenience init?(named name: String, podName: String, bundleName: String? = nil) {
        let bName = bundleName ?? podName
        if let image = UIImage(named: "\(bName).bundle/\(name)"), let cgImage = image.cgImage{
            self.init(cgImage: cgImage)
        } else {
            let filePath = Bundle.main.resourcePath! + "/Frameworks/\(podName).framework/\(bName).bundle"
            print("pod filePath =>\(filePath)")
            guard let bundle = Bundle(path: filePath) else { return nil}
            self.init(named: name, in: bundle, compatibleWith: nil)
        }
    }
    
//    ///获取 pod bundle 其他资源
//    convenience init?(named name: String, podName: String, bundleName: String? = nil,subBundleName: String?) {
//        let bName = bundleName ?? podName
//        if let image = UIImage(named: "\(bName).bundle/\(name)"), let cgImage = image.cgImage{
//            self.init(cgImage: cgImage)
//        } else {
////            var filePath = Bundle.main.resourcePath! + "/Frameworks/\(podName).framework/\(bName).bundle"
//
//            var filePath = Bundle.main.resourcePath! + "/Frameworks/\(podName).framework/"
//            if subBundleName != nil{
//                filePath += "/\(subBundleName!).bundle"
//            }
//            print("pod filePath =>\(filePath)")
////            let path = filePath.
//            let newb = Bundle(path: filePath)
//            let temp = (newb?.path(forResource: name, ofType: ".plist"))!
//            print("pod temp =>\(temp)")
//            let content = NSDictionary(contentsOfFile: temp)
//            print("content = >\(content)")
//
//            guard let bundle = Bundle(path: filePath) else { return nil}
//            self.init(named: name, in: bundle, compatibleWith: nil)
//        }
//    }
}

