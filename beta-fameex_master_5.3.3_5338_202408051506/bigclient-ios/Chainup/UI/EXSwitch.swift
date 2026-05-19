//
//  EXSwitch.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSwitch: UIButton {
    
    var isOn:Bool = false
    typealias ValueChangeBlock = (Bool) -> ()
    var onValueChangeCallback : ValueChangeBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func config(){
        self.imageView?.contentMode = .scaleAspectFit
        self.backgroundColor = UIColor.clear
        let open = UIImage.svgImage(named: "public_open")
        let close = UIImage.themeImageNamed(imageName: "public_switchclose")
        self.setImage(close, for: .normal)
        self.setImage(open, for: .selected)
        self.addTarget(self, action: #selector(openOrClose), for: .touchDragInside)
        self.addTarget(self, action: #selector(openOrClose), for: .touchUpInside)
    }
    @objc func openOrClose(){
        self.isSelected = !self.isSelected
        self.isOn = self.isSelected
        onValueChangeCallback?(self.isSelected)
    }
    
    func setOn(isOn:Bool) {
        self.isSelected = isOn
    }
}
