//
//  EXTextInputProtocol.swift
//  EXKit
//
//  Created by zq on 2023/3/31.
//

import UIKit
import RxSwift

public protocol EXTextInputProtocol:UIView {
    ///
    var text: String? { get set }
    var textColor: UIColor? { get set }
    var textAlignment: NSTextAlignment { get set }
    var font: UIFont? { get set }
    var attributedText: NSAttributedString? { get set }
    ///
    var inputView: UIView? { get set }
    var inputAccessoryView: UIView? { get set }
    ///
    var keyboardType: UIKeyboardType { get set }
    var keyboardAppearance: UIKeyboardAppearance { get set }
    var returnKeyType: UIReturnKeyType { get set }
    var enablesReturnKeyAutomatically: Bool { get set }
    var isSecureTextEntry: Bool { get set }
    ///
    var hasText: Bool { get }
    var isEmpty: Bool { get }
    func insertText(_ text: String)
    func deleteBackward()
}

public protocol EXInputHighlightable: EXHighlightable {
    var isHighlightable: Bool { get set }
    var textDidBeginEditingNotification:Notification.Name { get }
    var textDidEndEditingNotification:Notification.Name { get }
    var textEditingStateObject:NSObject { get }
}

fileprivate struct EXInputHighlightableConstant {
    static var isHighlightable:UInt8 = 0
}

public extension EXInputHighlightable where Self:UIView {
    var isHighlightable: Bool {
        get {
            guard let _ = objc_getAssociatedObject(self, &EXInputHighlightableConstant.isHighlightable) as? [Disposable] else { return false }
            return true
        }
        set {
            var disposables = objc_getAssociatedObject(self, &EXInputHighlightableConstant.isHighlightable) as? [Disposable]
            if (disposables != nil) == newValue { return } //
            if newValue {
                if highlightableUpdater == nil { highlightableUpdater = EXViewStateUpdater.default }
                var disposables:[Disposable] = []
                disposables.append(NotificationCenter.default.rx.notification(textDidBeginEditingNotification, object: textEditingStateObject)
                    .subscribe(onNext:{[weak self] _ in
                        guard let `self` = self, self.isHighlightable else { return }
                        self.isHighlighted = true
                    }))
                disposables.append(NotificationCenter.default.rx.notification(textDidEndEditingNotification, object: textEditingStateObject)
                    .subscribe(onNext:{[weak self] _ in
                        guard let `self` = self, self.isHighlightable else { return }
                        self.isHighlighted = false
                    }))
                disposables.forEach { disposable in
                    disposable.disposed(by: self.disposeBag)
                }
                objc_setAssociatedObject(self, &EXInputHighlightableConstant.isHighlightable, disposables, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }else{
                disposables?.forEach({ disposable in
                    disposable.dispose()
                })
                disposables?.removeAll()
                objc_setAssociatedObject(self, &EXInputHighlightableConstant.isHighlightable, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}


