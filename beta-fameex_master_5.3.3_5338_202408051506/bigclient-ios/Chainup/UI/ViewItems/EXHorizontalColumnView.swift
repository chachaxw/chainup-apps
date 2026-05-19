//
//  EXHorizontalColumnView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class HorizontalColumnItem :UIView {
    var container = UIView.init()
    var titleLabel = UILabel()
    var icon = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAlignMent(_ alignMent:EXColumnAlignment) {
        switch alignMent {
        case .left:
            titleLabel.textAlignment = .left
            
            container.snp.remakeConstraints { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            }
        case .center:
            titleLabel.textAlignment = .center
    
            container.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            }
        case .right:
            titleLabel.textAlignment = .right
            container.snp.remakeConstraints { (make) in
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            }
        }
    }
    
    func config(){
        self.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(icon)
        container.backgroundColor = UIColor.ThemeView.bg
        container.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.top.height.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalTo(icon.snp.left).offset(-5)
        }
        
        icon.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.height.equalTo(12)
            make.left.equalTo(titleLabel.snp.right).offset(5)
            make.right.equalToSuperview()
        }
    }
}


class EXHorizontalColumnView: NibBaseView {

    @IBOutlet var containerStack: UIStackView!
    
    override func onCreate() {
        
    }
    
    func bindItems(_ models:[ExThreeColumnDataModel]) {

        for(_,model) in models.enumerated() {
            let columnView = HorizontalColumnItem()
            columnView.backgroundColor = UIColor.ThemeView.bg
            columnView.titleLabel.font = model.style.topLabelFont
            columnView.titleLabel.textColor = model.style.topLabelColor
            columnView.titleLabel.text = model.title
            columnView.updateAlignMent(model.aliment)
            if model.title.count > 0 {
                let finish = EXKitBundle.svgImage(named: "public_checked")
                columnView.icon.image = model.iconStatus ?
            finish: UIImage.themeImageNamed(imageName: "fiat_unfinished")
            }
            self.containerStack.addArrangedSubview(columnView)
        }
    }
}
