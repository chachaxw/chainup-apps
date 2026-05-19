//
//  EXSkeletonContractSmallCandle.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

class EXSkeletonContractSmallCandle: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        rectangle1.snp.makeConstraints { make in
            make.left.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.519)
        }
        rectangle2.snp.makeConstraints { make in
            make.right.centerY.height.equalToSuperview()
            make.width.equalTo(rectangle2.snp.height).priority(.medium)
            make.left.greaterThanOrEqualTo(rectangle1.snp.right)
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
