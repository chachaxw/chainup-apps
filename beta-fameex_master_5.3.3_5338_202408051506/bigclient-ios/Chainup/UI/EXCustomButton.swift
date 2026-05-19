//
//  EXCustomButton.swift
//  Chainup
//
//  Created by bradjohn on 2023/10/16.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import RxSwift
class EXCustomButton: UIView {
    
    var edgeInset: UIEdgeInsets = .zero {
        didSet {
            self.textLabel.snp.updateConstraints { make in
                make.edges.equalToSuperview().inset(edgeInset)
            }
        }
    }
    
    var font: UIFont? {
        didSet {
            textLabel.font = font
        }
    }
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            backgroundColor = isSelected ? selectedBackgroundColor : normalBackgroundColor
            textLabel.textColor = isSelected ? selectedTextColor : textColor
            update()
        }
    }
    
    var normalBackgroundColor: UIColor? {
        didSet {
            backgroundColor = normalBackgroundColor
            update()
        }
    }
    
    var selectedBackgroundColor: UIColor?
    
    var textColor: UIColor = .Ex.text1 {
        didSet {
            textLabel.textColor = textColor
        }
    }
    
    var textAlignment: NSTextAlignment = .center {
        didSet {
            textLabel.textAlignment = textAlignment
        }
    }
    
    var selectedTextColor: UIColor?
    
    
    var onTap: EXComVoidBlock?
    
   fileprivate lazy var textLabel: EXLabel = {
        let v = EXLabel()
        return v
    }()
    
    lazy var coverBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.addTarget(self, action: #selector(onTapGesture), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(edgeInset)
        }
        
        self.addSubview(coverBtn)
        coverBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    ///
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func update() {
        layoutIfNeeded()
    }
    
    @objc func onTapGesture() {
        EXLogger.debug(message: "on tapped")
        self.onTap?()
    }
}
