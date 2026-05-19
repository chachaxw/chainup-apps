//
//  EXAlert.swift
//  Chainup
//
//  Created by liuxuan on2020/3/9.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit
import SwiftEntryKit
import SKPhotoBrowser
import IQKeyboardManagerSwift
import RxSwift
import RxCocoa

public enum DropMessageType {
    case success
    case fail
    case warning
}

open class EXKitAlert: NSObject {
    public static let sheetCloseSubject : BehaviorSubject<Bool> = BehaviorSubject.init(value:false)

    public typealias EXProgressHUDCompletionBlock = () -> Void

    public static func resignFirstResponder(){
        UIApplication.shared.keyWindow?.endEditing(true)
    }

    public static func showPhotoBrowser(urls:[String]) {
        var images = [SKPhoto]()
        for imgUrl in urls {
            let photo = SKPhoto.photoWithImageURL(imgUrl, holder: nil)
            images.append(photo)
        }
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(0)
        if let topVc = AppService .topViewController() {
            topVc.present(browser, animated: true, completion: {})
        }
    }

    public static func showCenterView(view:UIView) {
        self.resignFirstResponder()
        var attributes = EKAttributes()
        attributes.position = .center
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.screenBackground =  .color(color: EKColor.init(UIColor.ThemeView.mask))
        attributes.positionConstraints.size = .screen

        SwiftEntryKit.display(entry: view, using: attributes, presentInsideKeyWindow: true, rollbackWindow: .main)
    }

    public static func showDropView(view:UIView,offset:CGFloat = 0,animated:Bool = true) {
        self.resignFirstResponder()
        var attributes = EKAttributes()
        attributes.position = .top
        attributes.scroll = .disabled
        
        if EXThemeManager.isNight() == true{
            attributes.statusBar = .light
        }else{
            attributes.statusBar = .dark
        }
        

        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        attributes.positionConstraints.verticalOffset = offset
        attributes.entranceAnimation = .init(translate: .init(duration:animated ? 0.25 : 0.0, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: animated ? 0.25 : 0.0, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.screenBackground = .color(color: EKColor.init(UIColor.ThemeView.mask))
        attributes.positionConstraints.size = .init(width: .constant(value: view.frame.width), height: .constant(value: view.frame.height))
        attributes.positionConstraints.safeArea = .overridden
        SwiftEntryKit.display(entry: view, using: attributes, presentInsideKeyWindow: true, rollbackWindow: .main)
    }

    public static func showVc(controller: UIViewController, animated:Bool = true,ratio: CGFloat = 0.6){
        var attributes = EKAttributes()
        attributes = .bottomFloat
//        attributes.displayMode = EKAttributes.DisplayMode.inferred
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: EKColor.init(UIColor.ThemeView.mask))
//        attributes.entryBackground = .color(color: .white)
        attributes.roundCorners = .top(radius: 10)
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.5,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.35)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.35)
            )
        )
//        attributes.shadow = .active(
//            with: .init(
//                color: .black,
//                opacity: 0.3,
//                radius: 6
//            )
//        )
        attributes.positionConstraints.size = .init(
            width: .fill,
            height: .ratio(value: ratio)
        )
        attributes.positionConstraints.verticalOffset = 0
        attributes.positionConstraints.safeArea = .overridden
//        attributes.statusBar = .dark
        
//        let viewController = ContactsViewController()
//        let navigationController = ExampleNavigationViewController(rootViewController: viewController)
        SwiftEntryKit.display(entry: controller, using: attributes, presentInsideKeyWindow: true)
//        EKWindowProvider.shared.displayRollbackWindow()

       
    }
    //actionsheet弹
    public static func showSheet(sheetView:UIView,animated:Bool = true,bgTapCancel:Bool = true ,allowForwardTouch:Bool = false) {
        self.resignFirstResponder()

        var attributes = EKAttributes()
        attributes.name = "ExSheet"
        attributes.windowLevel = .alerts
        attributes.position = .bottom
        attributes.displayDuration = .infinity
        attributes.statusBar = EXThemeManager.isNight() ? .light : .dark
        attributes.entranceAnimation = .init(translate: .init(duration:animated ? 0.25 : 0.0, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: animated ? 0.25 : 0.0, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.lifecycleEvents.willDisappear = {
            self.sheetCloseSubject.onNext(false)
            NotificationCenter.default.post(name: NSNotification.Name.init("EXSheetDissmissed"), object: nil)
        }
        attributes.positionConstraints.verticalOffset = isiPhonexType() ? -34 : 0
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 0, screenEdgeResistance: NAV_H)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        if bgTapCancel {
            attributes.screenInteraction = .dismiss
        }else {
            attributes.screenInteraction = .absorbTouches
        }
        if allowForwardTouch {
            attributes.entryInteraction = .forward
        }else {
            attributes.entryInteraction = .absorbTouches
        }
        attributes.screenBackground = .color(color: EKColor.init(UIColor.ThemeView.mask))
        attributes.scroll = .disabled
        SwiftEntryKit.display(entry: sheetView, using: attributes, presentInsideKeyWindow: true, rollbackWindow: .main)
    }

    //弹窗
    /**
     touchCanDissmiss : 点击背景是否消失，默认不消失
     */
    public static func showAlert(alertView:UIView, offset: CGFloat = 20.0,touchCanDissmiss: Bool? = false,windowLevel: EKAttributes.WindowLevel? = EKAttributes.WindowLevel.alerts, backgroundColor:UIColor = UIColor.ThemeView.mask) {
//        if self.isCurrentlyDisplaying() {
//            return
//        }
        self.resignFirstResponder()
        var attributes = EKAttributes()
        attributes = .centerFloat
        attributes.name = "ExAlert"
        attributes.windowLevel = .alerts
        if let windowLevel = windowLevel {
            attributes.windowLevel = windowLevel
        }
        var widthOffset = offset
        if alertView is EXCommonAlert {
            widthOffset = 32
        }
        attributes.positionConstraints.maxSize = .init(
            width: .offset(value: widthOffset),
            height: .ratio(value: 0.8)
        )
        
        if offset == 0 {
            attributes.positionConstraints.maxSize = .init(
                width: .intrinsic,
                height: .intrinsic
            )
        }
        attributes.positionConstraints.size = .init(
            width: .offset(value: widthOffset),
            height: .intrinsic
        )
        attributes.entranceAnimation = .init(scale: .init(from: 0.9, to: 1, duration: 0.2, spring: .init(damping: 1, initialVelocity: 0)), fade: .init(from: 0, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        if let touchCanDissmiss = touchCanDissmiss,touchCanDissmiss == true {
            attributes.screenInteraction = .dismiss
            attributes.entryInteraction = .dismiss
        }
        attributes.screenBackground = .color(color: EKColor.init(backgroundColor))
        attributes.scroll = .disabled

        if EXThemeManager.isNight() == true{
            attributes.statusBar = .light
        }else{
            attributes.statusBar = .dark
        }

        SwiftEntryKit.display(entry: alertView, using: attributes)
    }

    public static func showInputView(inputView: UIView, maskTapAction:EKAttributes.UserInteraction.Action? = nil) {
        self.resignFirstResponder()
        var attributes = EKAttributes()
        attributes.name = "EXInputView"
        attributes.windowLevel = .normal
        attributes.scroll = .disabled
        attributes.position = .bottom
        attributes.displayDuration = .infinity
        attributes.statusBar = EXThemeManager.isNight() ? .light : .dark
        attributes.screenBackground = .color(color: EKColor.init(UIColor.ThemeView.mask))
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        if let maskTapAction = maskTapAction {
            attributes.screenInteraction = .absorbTouches
            attributes.screenInteraction.customTapActions = [maskTapAction]
        }
        attributes.positionConstraints.verticalOffset = isiPhonexType() ? -34 : 0
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
        //
        attributes.entranceAnimation = .init(translate: .init(duration:0.25, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration:0.25, spring: .init(damping: 1, initialVelocity: 0)))
        //
        let enabled = IQKeyboardManager.shared.enableAutoToolbar
        attributes.lifecycleEvents.didDisappear = {
            IQKeyboardManager.shared.enableAutoToolbar = enabled
        }
        attributes.lifecycleEvents.willAppear = {
            IQKeyboardManager.shared.enableAutoToolbar = false
        }
        SwiftEntryKit.display(entry: inputView, using: attributes, presentInsideKeyWindow: true, rollbackWindow: .main)
    }
    
    public static func showAlertFollowKeyboard(alertView: EXAlertFollowKeyboard) {

        self.resignFirstResponder()
        var attributes = EKAttributes()
        attributes.name = "ExAlertFollowKeyboard"
        attributes.windowLevel = .normal
        attributes.position = .bottom
//        attributes = .centerFloat
        attributes.displayDuration = .infinity
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
        attributes.entranceAnimation = .init(translate: .init(duration:0.0, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.0, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.lifecycleEvents.willDisappear = {
            IQKeyboardManager.shared.enableAutoToolbar = true
        }
        attributes.lifecycleEvents.willAppear = {
            IQKeyboardManager.shared.enableAutoToolbar = false
        }
        attributes.positionConstraints.verticalOffset = isiPhonexType() ? -34 : 0
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 0, screenEdgeResistance: 0)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.screenBackground = .color(color: EKColor.init(UIColor.ThemeView.mask))
        attributes.scroll = .enabled(
            swipeable: true,
            pullbackAnimation: .jolt
        )

        SwiftEntryKit.display(entry: alertView, using: attributes, presentInsideKeyWindow: true, rollbackWindow: .main)
    }

    //show DatePicker
    public static func showDatePicker(dateView:UIView,maskTapAction:EKAttributes.UserInteraction.Action? = nil){
        self.resignFirstResponder()
        var attributes = EKAttributes()
        attributes.name = "ExSheet"
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.displayDuration = .infinity
        attributes.entranceAnimation = .init(translate: .init(duration: 0.25, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.25, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.positionConstraints.verticalOffset = isiPhonexType() ? -34 : 0
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        if let maskTapAction = maskTapAction {
            attributes.screenInteraction.customTapActions = [maskTapAction]
        }
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 0, screenEdgeResistance: NAV_H)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        attributes.screenBackground = .color(color: EKColor.init(UIColor.ThemeView.mask))
        attributes.scroll = .disabled
        if EXThemeManager.isNight() == true{
            attributes.statusBar = .light
        }else{
            attributes.statusBar = .dark
        }

        SwiftEntryKit.display(entry: dateView, using: attributes)
    }

    //顶部下降
    public static func showSuccess(msg:String,holdResponder:Bool = false,in view:UIView? = nil, completion: EXProgressHUDCompletionBlock? = nil) { 
        self.showDrop(message: msg, msgType: .success, holdResponder: holdResponder, in: view, completion: completion)
    }

    @objc public static func showFail(msg:String,holdResponder:Bool = false,in view:UIView? = nil) {
        self.showDrop(message: msg, msgType: .fail,holdResponder: holdResponder,in: view)
    }

    public static func showWarning(msg:String,holdResponder:Bool = false,in view:UIView? = nil) {
        self.showDrop(message: msg, msgType: .warning, holdResponder: holdResponder, in: view)
    }

    static func showDrop(message:String,msgType:DropMessageType,holdResponder:Bool = false,in view:UIView? = nil, completion: EXProgressHUDCompletionBlock? = nil) {
        if holdResponder == false {
            self.resignFirstResponder()
        }
        let bgcolor = UIColor.ThemeState.normal
        if msgType == .fail {
//            bgcolor = UIColor.ThemeState.fail80
        }else if msgType == .warning {
//            bgcolor = UIColor.ThemeState.warning80
        }
        var toastInView = view
        if toastInView == nil {
            if let vc = AppService.topViewController() {
                toastInView = vc.view
            }
        }
        if let view = toastInView  {
            //网络请求的loading也是用MBprogressHud做的,loading在关闭的时候延迟了0.1s关币,这里延迟0.15防止冲突,loading会把网络报错的带走.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                var hud = MBProgressHUD.forView(view)
                if hud == nil {
                    hud = MBProgressHUD.showAdded(to: view, animated: true)
                }
                hud?.minShowTime = 1.5
                hud?.mode = .text
                hud?.marginH = 16
                hud?.marginV = 12
                hud?.label.font = UIFont.ThemeFont.BodyMedium
                hud?.isUserInteractionEnabled = false
                hud?.bezelView.style = .solidColor
                hud?.bezelView.backgroundColor = bgcolor
                hud?.label.textColor = UIColor.white
                hud?.label.text = message
                hud?.label.numberOfLines = 0
                hud?.hide(animated: true, afterDelay: 3.0)
                hud?.completionBlock = completion
            }
        }
    }

    public static func isCurrentlyDisplaying() -> Bool {
        return SwiftEntryKit.isCurrentlyDisplaying()
    }

    public static func dismiss() {
        self.sheetCloseSubject.onNext(false)
        SwiftEntryKit.dismiss {
        }
    }

    public static func dismissEnd(complete: @escaping () -> Void,delay:Double = 0.5 ){
        self.sheetCloseSubject.onNext(false)
        SwiftEntryKit.dismiss(.displayed, with: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
                complete()
            }
        })
    }
}

public protocol EXAlertFollowKeyboard where Self:UIView {
    func showKeyboard()
}

