//
//  EXSkeletonProfilePersonal.swift
//  EXKit
//
//  Created by youbin on 2023/7/3.
//

import UIKit

class EXSkeletonProfilePersonal: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(circle)
        addSubview(placeholder)
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(rectangle3)
        circle.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.height.equalToSuperview()
            make.width.equalTo(circle.snp.height)
        }
        placeholder.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(circle.snp.right)
            make.width.equalToSuperview().multipliedBy(0.035)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        rectangle1.snp.makeConstraints { make in
            make.left.equalTo(placeholder.snp.right)
            make.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.350)
            make.height.equalToSuperview().multipliedBy(0.561)
        }
        rectangle2.snp.makeConstraints { make in
            make.left.equalTo(rectangle1)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.213)
            make.height.equalToSuperview().multipliedBy(0.341)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.circle.layer.cornerRadius = CGRectGetHeight(self.circle.frame) * 0.5
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
