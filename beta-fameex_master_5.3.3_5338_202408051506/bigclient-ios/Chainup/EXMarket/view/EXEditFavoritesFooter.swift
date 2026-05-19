//
//  EXEditFavoritesFooter.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/28.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXEditFavoritesFooter: UIView {
    
    lazy var container:UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.ThemeTab.bg.withAlphaComponent(0.95)
        return container
    }()
    
    lazy var topLine:UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.ThemeTab.bg.withAlphaComponent(0.95)
        return line
    }()
    
    lazy var selectedAllBtn:EXCheckBox = {
        let btn = EXCheckBox.init(frame: .zero, style: .circleCheck)
        btn.checkLabel.font = UIFont.ThemeFont.BodyMedium
        btn.checkLabel.textColor = UIColor.Ex.text1
        btn.text(content: "common_action_sendall".localized())
        return btn
    }()
    
    lazy var deleteBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btn.setTitle("address_action_delete".localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .disabled)
        btn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .normal)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        btn.setImage(UIImage.themeImageNamed(imageName:"public_delete_default".localized()), for: .disabled)
        let img = EXKitBundle.svgImage(named: "public_delete_highlight")
        btn.setImage(img, for: .normal)
        return btn
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeTab.bg.withAlphaComponent(0.95)
        self.addSubview(container)
        container.addSubview(topLine)
        container.addSubview(selectedAllBtn)
        container.addSubview(deleteBtn)
//        selectedAllBtn.updateInnerGap(10)
        selectedAllBtn.spacing = 10

        container.snp.makeConstraints { (make) in
            make.height.equalTo(46)
            make.left.top.right.equalToSuperview()
        }
        
        topLine.snp.makeConstraints { (make) in
            make.height.equalTo(1/UIScreen.main.scale)
            make.left.top.right.equalToSuperview()
        }
        
        selectedAllBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        deleteBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

