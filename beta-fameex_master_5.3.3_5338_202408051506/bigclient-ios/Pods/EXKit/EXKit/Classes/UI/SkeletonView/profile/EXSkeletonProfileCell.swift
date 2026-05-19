//
//  EXSkeletonProfileCell.swift
//  EXKit
//
//  Created by youbin on 2023/7/3.
//

import UIKit

class EXSkeletonProfileCell: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(placeholder)
        addSubview(rectangle2)
        addSubview(rectangle3)
        rectangle1.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.842)
            make.width.equalTo(rectangle1.snp.height)
        }
        placeholder.snp.makeConstraints { make in
            make.left.equalTo(rectangle1.snp.right)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.035)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        rectangle2.snp.makeConstraints { make in
            make.left.equalTo(placeholder.snp.right)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.350)
        }
        rectangle3.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(rectangle1)
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
