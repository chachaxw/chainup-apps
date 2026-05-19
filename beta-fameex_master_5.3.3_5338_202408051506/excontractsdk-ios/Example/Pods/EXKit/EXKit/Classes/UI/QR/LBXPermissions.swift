//
//  LBXPermissions.swift
//  swiftScan
//
//  Created by xialibing on 15/12/15.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AssetsLibrary



public class LBXPermissions: NSObject {

    //MARK: ----获取相册权限
    public static func authorizePhotoWith(comletion:@escaping (Bool)->Void )
    {
       
        var granted = PHPhotoLibrary.authorizationStatus()
        if #available(iOS 14, *) {
            granted = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
        switch granted {
        case PHAuthorizationStatus.authorized:
            comletion(true)
        case PHAuthorizationStatus.denied,PHAuthorizationStatus.restricted:
            comletion(false)
        case PHAuthorizationStatus.notDetermined:
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
                    DispatchQueue.main.async {
                        comletion(status == PHAuthorizationStatus.authorized ? true : status == .limited ? true : false)
                    }
                }
            } else {
                
                PHPhotoLibrary.requestAuthorization({ (status) in
                    DispatchQueue.main.async {
                        
                        comletion(status == PHAuthorizationStatus.authorized ? true : false)
                    }
                })
            }
        case .limited:
            comletion(true)
        default:break
        }
    }
    
    //MARK: ---相机权限
    public static func authorizeCameraWith(comletion:@escaping (Bool)->Void )
    {
        let granted = AVCaptureDevice.authorizationStatus(for: AVMediaType.video);
        
        switch granted {
        case .authorized:
            comletion(true)
            break;
        case .denied:
            comletion(false)
            break;
        case .restricted:
            comletion(false)
            break;
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted:Bool) in
                DispatchQueue.main.async {
                    comletion(granted)
                }
            })
        }
    }
    
    //MARK:跳转到APP系统设置权限界面
    public static func jumpToSystemPrivacySetting()
    {
        let appSetting = NSURL(string:UIApplication.openSettingsURLString)! as URL

        if #available(iOS 10, *) {
            UIApplication.shared.open(appSetting, options: [:], completionHandler: nil)
        }
        else{
            UIApplication.shared.openURL(appSetting)
        }
    }
    
}
