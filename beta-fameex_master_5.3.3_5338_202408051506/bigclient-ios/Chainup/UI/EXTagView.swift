//
//  EXTagView.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
class EXTagView: UILabel {
    static func commonTagView() -> EXTagView {
        let label = EXTagView(text: nil, font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeLabel.colorHighlight, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.backgroundColor =  UIColor.Ex.main3
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }
}
