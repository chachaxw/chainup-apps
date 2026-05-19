//
//  EXTextFieldProtocol.swift
//  EXKit
//
//  Created by zq on 2023/3/31.
//

import UIKit
import RxSwift

public protocol EXTextFieldProtocol: EXTextInputProtocol, EXInputHighlightable {
    var textField:UITextField { get }
    ///
    var placeholder: String? { get set }
    var attributedPlaceholder: NSAttributedString? { get set }
    ///
    var clearsOnBeginEditing: Bool { get set }
    ///
    var adjustsFontSizeToFitWidth: Bool { get set }
    var minimumFontSize: CGFloat { get set }
    ///
    var isEditing: Bool { get }
    ///
    var clearButtonMode: UITextField.ViewMode { get set }
}

public extension EXTextFieldProtocol where Self:UIView {
    var placeholder: String? {
        get { textField.attributedPlaceholder?.string ?? textField.placeholder }
        set { setAttributedPlaceholder(text: newValue) }
    }
    var attributedPlaceholder: NSAttributedString? {
        get { textField.attributedPlaceholder }
        set { textField.attributedPlaceholder = newValue }
    }
    func setAttributedPlaceholder(text:String?, font:UIFont? = nil, color:UIColor? = .Ex.text3) {
        attributedPlaceholder = text?.ex_toNSAttributedString(font: font ?? self.font, textColor: color)
    }
    var clearsOnBeginEditing: Bool {
        get { textField.clearsOnBeginEditing }
        set { textField.clearsOnBeginEditing = newValue }
    }
    var adjustsFontSizeToFitWidth: Bool {
        get { textField.adjustsFontSizeToFitWidth }
        set { textField.adjustsFontSizeToFitWidth = newValue }
    }
    var minimumFontSize: CGFloat {
        get { textField.minimumFontSize }
        set { textField.minimumFontSize = newValue }
    }
    var isEditing: Bool { textField.isEditing }
    var clearButtonMode: UITextField.ViewMode {
        get { textField.clearButtonMode }
        set { textField.clearButtonMode = newValue }
    }
    ///
    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    var textColor: UIColor? {
        get { textField.textColor }
        set { textField.textColor = newValue }
    }
    var textAlignment: NSTextAlignment {
        get { textField.textAlignment }
        set { textField.textAlignment = newValue }
    }
    var font: UIFont? {
        get { textField.font }
        set {
            textField.font = newValue;
            ///
            if let attributedPlaceholder = self.attributedPlaceholder?.mutableCopy() as? NSMutableAttributedString {
                self.attributedPlaceholder = attributedPlaceholder.ex_font(newValue)
            }else{
                setAttributedPlaceholder(text: placeholder)
            }
        }
    }
    var attributedText: NSAttributedString? {
        get { textField.attributedText }
        set { textField.attributedText = newValue }
    }
    var inputView: UIView? {
        get { textField.inputView }
        set { textField.inputView = newValue }
    }
    var inputAccessoryView: UIView? {
        get { textField.inputAccessoryView }
        set { textField.inputAccessoryView = newValue }
    }
    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    var keyboardAppearance: UIKeyboardAppearance {
        get { textField.keyboardAppearance }
        set { textField.keyboardAppearance = newValue }
    }
    var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }
    var enablesReturnKeyAutomatically: Bool {
        get { textField.enablesReturnKeyAutomatically }
        set { textField.enablesReturnKeyAutomatically = newValue }
    }
    var isSecureTextEntry: Bool {
        get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    ///
    var hasText: Bool { textField.hasText }
    var isEmpty: Bool { !textField.hasText }
    func insertText(_ text: String) { textField.insertText(text) } 
    func deleteBackward() { textField.deleteBackward() }
    ///
    var textDidChangeSignal: Observable<String> { textField.rx.text.orEmpty.asObservable().distinctUntilChanged() }
}

public extension EXTextFieldProtocol {
    var textEditingStateObject: NSObject { textField }
    var textDidBeginEditingNotification:Notification.Name { UITextField.textDidBeginEditingNotification }
    var textDidEndEditingNotification:Notification.Name { UITextField.textDidEndEditingNotification }
}
