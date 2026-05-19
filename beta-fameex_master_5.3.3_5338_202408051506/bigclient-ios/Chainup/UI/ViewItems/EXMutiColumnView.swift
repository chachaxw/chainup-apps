//
//  EXMutiColumnView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class ColumnItem :UIView {
    var container = UIView.init()
    var itemContainer = UIView.init()

    var titleLabel = UILabel()
    var detailLabel = UILabel()
    
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
            detailLabel.textAlignment = .left
            itemContainer.snp.remakeConstraints { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
//                make.width.lessThanOrEqualToSuperview()
            }
        case .center:
            titleLabel.textAlignment = .left
            detailLabel.textAlignment = .left
            itemContainer.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(30)
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
//                make.width.lessThanOrEqualToSuperview()
            }
        case .right:
            titleLabel.textAlignment = .right
            detailLabel.textAlignment = .right
            itemContainer.snp.remakeConstraints { (make) in
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
//                make.width.lessThanOrEqualToSuperview()
            }
        }
    }
    
    func config(){
        self.addSubview(container)
        self.addSubview(itemContainer)
        itemContainer.addSubview(titleLabel)
        itemContainer.addSubview(detailLabel)
        
        container.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        itemContainer.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalTo(detailLabel.snp.top).offset(-9)
            make.left.right.equalToSuperview()
        }

        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(9)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
   
    }
}
import EXKit
class EXMutiColumnView: NibBaseView {
    
    @IBOutlet var containerView: UIStackView!
    var containers:[ColumnItem] = []
    
    override func onCreate() {
        
    }
    
    func bindItems(_ models:[ExThreeColumnDataModel]) {

        if containers.count > 0 {
            self.containerView.removeAllArrangedSubviews()
            self.containers.removeAll()
        }
        
         for(_,model) in models.enumerated() {
            let columnView = ColumnItem()
//            columnView.backgroundColor = UIColor.ThemeView.bg
            columnView.titleLabel.font = model.style.topLabelFont
            columnView.titleLabel.textColor = model.style.topLabelColor
            columnView.titleLabel.text = model.title
            columnView.detailLabel.font = model.style.bottomLabelFont
            columnView.detailLabel.textColor = model.style.bottomLabelColor
            columnView.detailLabel.text = model.content
            columnView.updateAlignMent(model.aliment)
            self.containerView.addArrangedSubview(columnView)

            self.containers.append(columnView)
        }
    }
}
