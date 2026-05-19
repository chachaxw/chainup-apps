//
//  EXSkeletonAssetsCoin2Cell.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

class EXSkeletonAssetsCoin2Cell: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        rectangle1.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.195)
            make.height.equalToSuperview()
        }
        rectangle2.snp.makeConstraints { make in
            make.centerY.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.209)
            make.height.equalToSuperview().multipliedBy(0.7)
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
