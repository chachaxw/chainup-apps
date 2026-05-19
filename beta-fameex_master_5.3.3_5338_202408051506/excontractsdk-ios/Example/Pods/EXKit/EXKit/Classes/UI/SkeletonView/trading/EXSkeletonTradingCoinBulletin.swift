//
//  EXSkeletonTradingCoinBulletin.swift
//  EXKit
//
//  Created by youbin on 2023/6/28.
//

import UIKit

class EXSkeletonTradingCoinBulletin: EXSkeletonComponents {
    
    lazy var placeholder1: UIView = {
        let v = UIView()
        return v
    }()
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(rectangle3)
        addSubview(rectangle4)
        addSubview(placeholder)
        addSubview(placeholder1)
        rectangle1.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(rectangle1.snp.height)
        }
        placeholder.snp.makeConstraints { make in
            make.left.equalTo(rectangle1.snp.right)
            make.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.023)
        }
        rectangle2.snp.makeConstraints { make in
            make.left.equalTo(placeholder.snp.right)
            make.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.519)
        }
        rectangle4.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(rectangle4.snp.height)
        }
        placeholder1.snp.makeConstraints { make in
            make.right.equalTo(rectangle4.snp.left)
            make.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.035)
        }
        rectangle3.snp.makeConstraints { make in
            make.right.equalTo(placeholder1.snp.left)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(rectangle3.snp.height)
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
