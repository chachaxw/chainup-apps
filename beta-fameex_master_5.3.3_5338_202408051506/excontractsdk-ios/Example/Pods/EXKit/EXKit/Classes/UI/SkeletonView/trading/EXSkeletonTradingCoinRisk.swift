//
//  EXSkeletonTradingCoinRisk.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

class EXSkeletonTradingCoinRisk: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(placeholder)
        addSubview(rectangle2)
        addSubview(rectangle3)
        rectangle1.snp.makeConstraints { make in
            make.left.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.227)
        }
        placeholder.snp.makeConstraints { make in
            make.left.equalTo(rectangle1.snp.right)
            make.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.035)
        }
        rectangle2.snp.makeConstraints { make in
            make.left.equalTo(placeholder.snp.right)
            make.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.178)
        }
        rectangle3.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.178)
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
