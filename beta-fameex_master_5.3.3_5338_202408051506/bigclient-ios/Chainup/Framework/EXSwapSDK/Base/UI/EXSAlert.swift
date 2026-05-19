//
//  EXAlert.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/9.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import SwiftEntryKit
//import SKPhotoBrowser
//import SwiftyDrop
//import IQKeyboardManager

enum EXSDropMessageType {
    case success
    case fail
    case warning
}

class EXSAlert: NSObject {
    
    static func resignFirstResponder(){
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
//    static func showPhotoBrowser(urls:[String]) {
//        var images = [SKPhoto]()
//        for imgUrl in urls {
//            let photo = SKPhoto.photoWithImageURL(imgUrl, holder: nil)
//            images.append(photo)
//        }
//        let browser = SKPhotoBrowser(photos: images)
//        browser.initializePageIndex(0)
//        if let topVc = AppService .topViewController() {
//            topVc.present(browser, animated: true, completion: {})
//        }
//    }
    static func showCenterView(view:UIView) {
        self.resignFirstResponder()
        var attributes = EKAttributes()
        attributes.position = .center
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.screenBackground = .color(color: UIColor.exs_ThemeView.mask)
        attributes.positionConstraints.size = .screen
        
        SwiftEntryKit.display(entry: view, using: attributes, presentInsideKeyWindow: true, rollbackWindow: .main)
    }
    
    static func showDropView(view:UIView) {
        self.resignFirstResponder()
        var attributes = EKAttributes()
        attributes.position = .center
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.screenBackground = .color(color: UIColor.exs_ThemeView.mask)
        attributes.positionConstraints.size = .screen
        
        SwiftEntryKit.display(entry: view, using: attributes, presentInsideKeyWindow: true, rollbackWindow: .main)
    }
    
    //Actionsheet bullet
    static func showSheet(sheetView:UIView,animated:Bool = true){
        self.resignFirstResponder()
        var attributes = EKAttributes()
        attributes.name = "ExSheet"
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.displayDuration = .infinity
        
        attributes.entranceAnimation = .init(translate: .init(duration:animated ? 0.25 : 0.0, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: animated ? 0.25 : 0.0, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.lifecycleEvents.willDisappear = {
            NotificationCenter.default.post(name: NSNotification.Name.init("EXSheetDissmissed"), object: nil)
        }
        attributes.positionConstraints.verticalOffset = EXISIPhoneX ? -34 : 0
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 0, screenEdgeResistance: EX_NAV_SCREEN_HEIGHT)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.screenBackground = .color(color: UIColor.exs_ThemeView.mask)
//        attributes.entryBackground = .color(color: UIColor.exs_ThemeView.mask)
        attributes.scroll = .disabled
        SwiftEntryKit.display(entry: sheetView, using: attributes, presentInsideKeyWindow: true, rollbackWindow: .main)
    }
    
    //pop-up notification
    static func showAlert(alertView:UIView, offset: CGFloat = 32.0) {
        self.resignFirstResponder()
        var attributes = EKAttributes()
        attributes = .centerFloat
        attributes.name = "ExAlert"
        attributes.windowLevel = .alerts
//        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
        attributes.positionConstraints.size = .init(
            width: .offset(value: offset),
            height: .intrinsic
        )
        attributes.lifecycleEvents.willDisappear = {
            NotificationCenter.default.post(name: NSNotification.Name.init("EXSheetDissmissed"), object: nil)
        }
        attributes.entranceAnimation = .init(scale: .init(from: 0.9, to: 1, duration: 0.2, spring: .init(damping: 1, initialVelocity: 0)), fade: .init(from: 0, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.screenBackground = .color(color: UIColor.exs_ThemeView.mask)
//        attributes.entryBackground = .color(color: UIColor.exs_ThemeView.mask)
        attributes.scroll = .disabled

        if EXSThemeManager.isNight() == true{
            attributes.statusBar = .light
        }else{
            attributes.statusBar = .dark
        }
        
        SwiftEntryKit.display(entry: alertView, using: attributes)
    }
    
//    static func showAlertFollowKeyboard(alertView: EXAlertFollowKeyboard) {
//
//        self.resignFirstResponder()
//        var attributes = EKAttributes()
//        attributes.name = "ExAlertFollowKeyboard"
//        attributes.windowLevel = .normal
//        attributes.position = .bottom
////        attributes = .centerFloat
//        attributes.displayDuration = .infinity
//        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
//        attributes.entranceAnimation = .init(translate: .init(duration:0.0, spring: .init(damping: 1, initialVelocity: 0)))
//        attributes.exitAnimation = .init(translate: .init(duration: 0.0, spring: .init(damping: 1, initialVelocity: 0)))
//        attributes.lifecycleEvents.willDisappear = {
////            NotificationCenter.default.post(name: NSNotification.Name.init("EXSheetDissmissed"), object: nil)
//            
//            IQKeyboardManager.shared().isEnableAutoToolbar = true
//        }
//        attributes.lifecycleEvents.willAppear = {
//            IQKeyboardManager.shared().isEnableAutoToolbar = false
//        }
//        attributes.positionConstraints.verticalOffset = isiPhoneX ? -34 : 0
//        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 0, screenEdgeResistance: 0)
//        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
//        attributes.positionConstraints.keyboardRelation = keyboardRelation
////        attributes.positionConstraints.keyboardRelation = .bind(
////            offset: .init(
////                bottom: 10,
////                screenEdgeResistance: 5
////            )
////        )
//        attributes.screenInteraction = .dismiss
//        attributes.entryInteraction = .absorbTouches
//        attributes.screenBackground = .color(color: UIColor.exs_ThemeView.mask)
//        //        attributes.entryBackground = .color(color: UIColor.exs_ThemeView.mask)
////        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
//        attributes.scroll = .enabled(
//            swipeable: true,
//            pullbackAnimation: .jolt
//        )
////        attributes.lifecycleEvents.didAppear = {
////            alertView.showKeyboard()
////        }
//        SwiftEntryKit.display(entry: alertView, using: attributes, presentInsideKeyWindow: true, rollbackWindow: .main)
//    }
    
    //show DatePicker
    static func showDatePicker(dateView:UIView){
        self.resignFirstResponder()
        var attributes = EKAttributes()
        attributes.name = "ExSheet"
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.displayDuration = .infinity
        attributes.entranceAnimation = .init(translate: .init(duration: 0.25, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.25, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.positionConstraints.verticalOffset = EXISIPhoneX ? -34 : 0
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 0, screenEdgeResistance: EX_NAV_SCREEN_HEIGHT)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
//        attributes.screenInteraction = .absorbTouches
//        attributes.entryInteraction = .absorbTouches
        attributes.screenBackground = .color(color: UIColor.exs_ThemeView.mask)
//        attributes.entryBackground = .color(color: UIColor.exs_ThemeView.mask)
        attributes.scroll = .disabled
        SwiftEntryKit.display(entry: dateView, using: attributes)
    }
    
    //Top descent
    static func showSuccess(msg:String) {
    
        self.showDrop(message: msg, msgType: .success)
    }
    
    @objc static func showFail(msg:String) {
        self.showDrop(message: msg, msgType: .fail)
    }
    
    static func showWarning(msg:String) {
        self.showDrop(message: msg, msgType: .warning)
    }
    
    static func showDrop(message:String,msgType:EXSDropMessageType) {
        EXCustomToast.showMsg(msg: message)
    }
    
    static func dismiss() {
        SwiftEntryKit.dismiss {
        }
    }
    static func dismissSheet(complete: (() -> Void)? = nil ) {
        SwiftEntryKit.dismiss(.specific(entryName: "ExSheet"), with: {
          //  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                complete?()
           // }
        })
    }
    
    static func dismissEnd(delay:Double = 0.5, complete: @escaping () -> Void){
        SwiftEntryKit.dismiss(.displayed, with: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
                complete()
            }
        })
    }

}

