//
//  EXDirectionSelector.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/29.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXDirectionSelector: UIControl {
    
    var insets:UIEdgeInsets = .zero{
        didSet {
            self.makeLayouts(insets: insets)
        }
    }
    
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.ThemeFont.BodyMedium
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var icon:UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        icon.image = UIImage.themeImageNamed(imageName:"coins_drop_down")
        return icon
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func config() {
        self.extSetCornerRadius(4)
        self.extSetBorderWidth(1/UIScreen.main.scale, color: UIColor.ThemeView.border)
        self.addSubview(titleLabel)
        self.addSubview(icon)
        makeLayouts(insets: UIEdgeInsets.init(top: 0, left: 12, bottom: 0, right: 12))
    }
    
    func makeLayouts(insets:UIEdgeInsets) {
        
        titleLabel.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(insets.left)
            make.right.equalTo(icon.snp.left)
        }
        
        icon.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-insets.right)
            make.left.equalTo(titleLabel.snp.right)
            make.width.height.equalTo(16)
        }
    }
}
