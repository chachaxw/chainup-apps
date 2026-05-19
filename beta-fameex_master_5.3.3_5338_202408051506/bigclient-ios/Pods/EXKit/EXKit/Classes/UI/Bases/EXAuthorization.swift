//
//  EXAuthorization.swift
//  EXKit
//
//  Created by zq on 2023/10/26.
//

import UIKit
import Photos
import AVFoundation
import UserNotifications

public class EXAuthorization {
    
    /// The type to authorize
    public enum `Type` {
        /// camera
        case camera
        /// for select photo via system album
        case photo
        /// for save photo to system album
        case savePhoto
        /// scan qrcode etc.
        case captureVideo
        /// for notification
        case notification
    }
    
    
    /// Request status of the permission, and trigger the authorizion automatically if not determined,
    /// then callback after success
    /// - Parameters:
    ///   - type: The type to authorize
    ///   - success: This success block will be invoked after authorize successfully
    public class func authorize(_ type:`Type`, success: @escaping ()->Void) {
        authorize(type) { granted in
            guard granted else { return showAuthrizationLimitationAlert(type: type) }
            success()
        }
    }
    
    
    /// Request status of the permission, and trigger the authorizion automatically if not determined,
    /// then callback after finised
    /// - Parameters:
    ///   - type: The type to authorize
    ///   - completion: This success block will be invoked after authorize finished, true for success and other for denied
    public class func authorize(_ type:`Type`, completion: @escaping (Bool)->Void) {
        authorize(type) { (granted,first) in completion(granted) }
    }
    
    
    /// Request status of the permission, and trigger the authorizion automatically if not determined,
    /// then callback after finised
    /// - Parameters:
    ///   - type: The type to authorize
    ///   - completion: This success block will be invoked after authorize finished, true for success and other for denied,
    ///   and the second value of the completion means that this authorization is the first time or not.
    public class func authorize(_ type:`Type`, completion: @escaping (Bool, Bool)->Void) {
        internal_authorize(type) { (granted,first) in
            DispatchQueue.main.async{ completion(granted, first) }
        }
    }
    
    ///
    private class func internal_authorize(_ type:`Type`, completion: @escaping (Bool, Bool)->Void) {
        switch type {
            case .camera: authorizeCamera(completion: completion)
            case .photo: authorizePhoto(addOnly: false, completion: completion)
            case .savePhoto: authorizePhoto(addOnly: true, completion: completion)
            case .captureVideo: authorizeCaptureDevice(for: .video, completion: completion)
            case .notification: authorizeNotification(completion: completion)
        }
    }
    
    
    /// To open system settings page
    /// - Parameters:
    ///   - completion: see `UIApplication.open(_ url, options, completionHandler)`
    public class func openAppSystemSettings(completionHandler completion:((Bool) -> Void)? = nil) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: completion)
    }
    
    
    /// To open system notification settings page of this app
    /// - Parameters:
    ///   - completion: see `UIApplication.open(_ url, options, completionHandler)`
    public class func openAppSystemNotificationSettings(completionHandler completion:((Bool) -> Void)? = nil) {
        if #available(iOS 16.0, *) {
            UIApplication.shared.open(URL(string: UIApplication.openNotificationSettingsURLString)!, completionHandler: completion)
        } else if #available(iOS 15.4, *) {
            UIApplication.shared.open(URL(string: UIApplicationOpenNotificationSettingsURLString)!, completionHandler: completion)
        } else {
            openAppSystemSettings(completionHandler: completion)
        }
    }
    
}

private extension EXAuthorization {
    ///
    class func authorizeCamera(completion: @escaping (Bool, Bool)->Void) {
        let granted = AVCaptureDevice.authorizationStatus(for: .video)
        switch granted {
            case .notDetermined: AVCaptureDevice.requestAccess(for:.video) { granted in completion(granted,true) }
            case .authorized: return completion(true, false)
            case .denied: fallthrough
            case .restricted: fallthrough
            default: return completion(false, false)
        }
    }
    
    ///
    class func authorizePhoto(addOnly:Bool, completion: @escaping (Bool, Bool)->Void) {
        var status = PHPhotoLibrary.authorizationStatus()
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: addOnly ? .addOnly : .readWrite)
        }
        switch status {
            case .notDetermined:
                let handler = { status in
                    var validStatuses:[PHAuthorizationStatus] = [.authorized]
                    if #available(iOS 14, *) { validStatuses.append(.limited) }
                    completion(validStatuses.contains(status), true)
                }
                if #available(iOS 14, *) {
                    PHPhotoLibrary.requestAuthorization(for: addOnly ? .addOnly : .readWrite, handler: handler)
                } else {
                    PHPhotoLibrary.requestAuthorization(handler)
                }
            case .limited: fallthrough
            case .authorized: return completion(true, false)
            case .denied: fallthrough
            case .restricted: fallthrough
            default: completion(false, false)
        }
    }
    
    ///
    class func authorizeCaptureDevice(for mediaType:AVMediaType, completion: @escaping (Bool, Bool)->Void) {
        let granted = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch granted {
            case .notDetermined: AVCaptureDevice.requestAccess(for:mediaType) { granted in completion(granted,true) }
            case .authorized: completion(true, false)
            case .denied: fallthrough
            case .restricted: fallthrough
            default: completion(false, false)
        }
    }
    
    ///
    class func authorizeNotification(completion: @escaping (Bool, Bool)->Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
                case .notDetermined: UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { granted, error in completion(granted, true)
                }
                case .provisional: fallthrough
                case .authorized: completion(true, false)
                case .denied: fallthrough
                default: completion(false, false)
            }
        }
    }
    
    ///
    class func showAuthrizationLimitationAlert(type:`Type`) {
        var title = ""
        switch type {
            case .captureVideo: fallthrough
            case .camera: title = "privacy_alert_open_camera".localized()
            case .savePhoto: fallthrough
            case .photo:  title = "privacy_alert_open_photo".localized()
            default: return
        }
        let alert = EXCommonAlert()
        alert.configAlert(title: title,
                          cancelBtnTitle: "privacy_alert_i_known".localized(),
                          sureBtnTitle: "privacy_alert_to_set".localized(),
                          btnLayoutStyle: .vertical) { type in
            guard type == .sure else { return }
            openAppSystemSettings()
        }
        EXKitAlert.showAlert(alertView: alert)
    }
}
