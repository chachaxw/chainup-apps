//
//  EXHorizontalButtonListView.swift
//  Chainup
//
//  Created by chainup on 2023/8/28.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit

typealias EXIndexButtonClickBlock = () -> ()

class EXButtonModel {
    
    var title = ""
    
    var clickBlock:EXIndexButtonClickBlock?
    var highlight:Bool = false
}

class EXHorizontalButtonListView: UIView {
    
    var items:[EXButtonModel]?
    
    init(items:[EXButtonModel],font:UIFont = UIFont.ThemeFont.HeadMedium) {
        
        super.init(frame:CGRect.zero)
        
        self.items = items
        
        for view in subviews {
            
            view.removeFromSuperview()
        }
        
        var lastButton:UIButton?
        for (index,item) in items.enumerated() {
            let button = UIButton()
            button.extSetCornerRadius(4)
            if item.highlight {
                button.backgroundColor = UIColor.ThemeBtn.highlight
            }else {
                button.layer.borderWidth = 1.0
                button.layer.borderColor = UIColor.ThemeBtn.highlight.cgColor
                button.setTitleColor(UIColor.ThemeBtn.highlight, for: .normal)
            }
            button.tag = index
            button.setTitle(LanguageTools.getString(key: item.title), for: UIControl.State.normal)
            button.extSetAddTarget(self, #selector(clickButton))
            button.titleLabel?.font = font
            
            addSubview(button)
            button.snp.makeConstraints { (make) in
                if  let last = lastButton {
                    make.leading.equalTo(last.snp.trailing).offset(9)
                }else {
                    make.leading.equalTo(0)
                }
                if index == items.count - 1 {
                    make.trailing.equalToSuperview()
                }
                make.top.bottom.equalToSuperview()
                if let v = lastButton {
                    
                    make.width.equalTo(v)
                }
            }
            
            lastButton = button
        }
    }
    
    func updateDisabledIfNeed(disabled: Bool) {
        if disabled {
            
        subviews.forEach { sv in
                if let button = sv as? UIButton {
                    button.isEnabled = !disabled
                
                    
                    
                    
                }
            }
            
            
            
            
        } else {
            
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func clickButton(_ button:EXButton) {
        
        if let model = items?[button.tag], let block = model.clickBlock {
            block()
        }
    }
}
