//
//  EXSkeletonAssetsCoin1Cell.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

class EXSkeletonAssetsCoin1Cell: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(rectangle3)
        rectangle1.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.195)
            make.height.equalToSuperview().multipliedBy(0.526)
        }
        rectangle2.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.408)
            make.height.equalToSuperview().multipliedBy(0.526)
        }
        rectangle3.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.209)
            make.height.equalToSuperview().multipliedBy(0.368)
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
