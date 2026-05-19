//
//  EXTextViewProtocol.swift
//  EXKit
//
//  Created by zq on 2023/3/31.
//

import UIKit
import RxSwift

public protocol EXTextViewProtocol: EXTextInputProtocol, EXInputHighlightable {
    var textView:UITextView { get }
    ///
    var selectedRange: NSRange { get set }
    var isEditable: Bool { get set }
    var isSelectable: Bool { get set }
    var clearsOnInsertion: Bool { get set }
    ///
    func scrollRangeToVisible(_ range: NSRange)
}

public extension EXTextViewProtocol where Self:UIView {
    var selectedRange: NSRange {
        get { textView.selectedRange }
        set { textView.selectedRange = newValue }
    }
    var isEditable: Bool {
        get { textView.isEditable }
        set { textView.isEditable = newValue }
    }
    var isSelectable: Bool {
        get { textView.isSelectable }
        set { textView.isSelectable = newValue }
    }
    var clearsOnInsertion: Bool {
        get { textView.clearsOnInsertion }
        set { textView.clearsOnInsertion = newValue }
    }
    func scrollRangeToVisible(_ range: NSRange) {
        textView.scrollRangeToVisible(range)
    }
    ///
    var text: String? {
        get { textView.text }
        set { textView.text = newValue }
    }
    var textColor: UIColor? {
        get { textView.textColor }
        set { textView.textColor = newValue }
    }
    var textAlignment: NSTextAlignment {
        get { textView.textAlignment }
        set { textView.textAlignment = newValue }
    }
    var font: UIFont? {
        get { textView.font }
        set { textView.font = newValue }
    }
    var attributedText: NSAttributedString? {
        get { textView.attributedText }
        set { textView.attributedText = newValue }
    }
    var inputView: UIView? {
        get { textView.inputView }
        set { textView.inputView = newValue }
    }
    var inputAccessoryView: UIView? {
        get { textView.inputAccessoryView }
        set { textView.inputAccessoryView = newValue }
    }
    var keyboardType: UIKeyboardType {
        get { textView.keyboardType }
        set { textView.keyboardType = newValue }
    }
    var keyboardAppearance: UIKeyboardAppearance {
        get { textView.keyboardAppearance }
        set { textView.keyboardAppearance = newValue }
    }
    var returnKeyType: UIReturnKeyType {
        get { textView.returnKeyType }
        set { textView.returnKeyType = newValue }
    }
    var enablesReturnKeyAutomatically: Bool {
        get { textView.enablesReturnKeyAutomatically }
        set { textView.enablesReturnKeyAutomatically = newValue }
    }
    var isSecureTextEntry: Bool {
        get { textView.isSecureTextEntry }
        set { textView.isSecureTextEntry = newValue }
    }
    ///
    var hasText: Bool { textView.hasText }
    var isEmpty: Bool { !textView.hasText }
    func insertText(_ text: String) { textView.insertText(text) }
    func deleteBackward() { textView.deleteBackward() }
    ///
    var textDidChangeSignal: Observable<String> { textView.rx.text.orEmpty.asObservable().distinctUntilChanged() }
}

public extension EXTextViewProtocol {
    var textEditingStateObject: NSObject { textView }
    var textDidBeginEditingNotification:Notification.Name { UITextView.textDidBeginEditingNotification }
    var textDidEndEditingNotification:Notification.Name { UITextView.textDidEndEditingNotification }
}
