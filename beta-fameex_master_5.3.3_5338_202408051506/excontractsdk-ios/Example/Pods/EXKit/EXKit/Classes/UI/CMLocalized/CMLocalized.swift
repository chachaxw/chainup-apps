//
//  CMLocalized.swift
//  EXKit
//
//  Created by zq on 2023/3/28.
//

import UIKit

enum CMLocalizedStringFunction:Int {
    case none
    case capital
    case upperCase
    case lowerCase
    static func localized(with key:String,function:Int) -> String {
        var raw = key.localized()
        guard let instance = CMLocalizedStringFunction(rawValue: function) else { return raw }
        switch instance {
        case .capital:
            return raw.lowercased().capitalized
        case .upperCase:
            return raw.uppercased()
        case .lowerCase:
            return raw.lowercased()
        case .none:
            return raw
        }
    }
}

public class CMLocalizedLabel: UILabel {
    @IBInspectable var function:Int = 0
    public override func awakeFromNib() {
        super.awakeFromNib()
        if let attr = attributedText, attr.length > 0 {
            attributedText = NSAttributedString(string: attr.string.localized(), attributes: attr.attributes(at: 0, effectiveRange: nil))
        }else if let string = text, !string.isEmpty {
            text = CMLocalizedStringFunction.localized(with: string, function: function)
        }
    }
}

public class CMLocalizedButton: UIButton {
    @IBInspectable var function:Int = 0
    public override func awakeFromNib() {
        super.awakeFromNib()
        if let maybeKey = title(for: .normal), !maybeKey.isEmpty {
            setTitle(CMLocalizedStringFunction.localized(with: maybeKey, function: function), for: .normal)
        }   
    }
}
