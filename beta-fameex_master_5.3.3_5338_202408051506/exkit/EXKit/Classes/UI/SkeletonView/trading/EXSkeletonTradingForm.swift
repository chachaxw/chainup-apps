//
//  EXSkeletonTradingForm.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

class EXSkeletonTradingForm: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(placeholder)
        addSubview(rectangle2)
        addSubview(rectangle3)
        
        rectangle1.snp.makeConstraints { make in
            make.left.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.195)
        }
        placeholder.snp.makeConstraints { make in
            make.left.equalTo(rectangle1.snp.right)
            make.height.centerY.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.125)
        }
        rectangle2.snp.makeConstraints { make in
            make.centerY.height.equalTo(rectangle1)
            make.left.equalTo(placeholder.snp.right)
            make.width.equalToSuperview().multipliedBy(0.195)
        }
        rectangle3.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
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
