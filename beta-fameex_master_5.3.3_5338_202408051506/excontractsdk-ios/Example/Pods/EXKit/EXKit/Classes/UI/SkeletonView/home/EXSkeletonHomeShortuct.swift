//
//  EXSkeletonHomeShortuct.swift
//  EXKit
//
//  Created by youbin on 2023/6/26.
//

import UIKit

class EXSkeletonHomeShortuct: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(circle)
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(rectangle3)
        
        circle.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSizeMake(28, 28))
        }
        rectangle1.snp.makeConstraints { make in
            make.left.equalTo(circle.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
        }
        rectangle2.snp.makeConstraints { make in
            make.left.equalTo(rectangle1.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSizeMake(20, 20))
        }
        rectangle3.snp.makeConstraints { make in
            make.left.equalTo(rectangle2.snp.right).offset(12)
            make.left.equalTo(rectangle1.snp.right).offset(12).priority(.medium)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSizeMake(20, 20))
            make.right.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.circle.roundCorners(corners: .allCorners, radius: CGRectGetWidth(self.circle.frame))
        self.rectangle1.roundCorners(corners: .allCorners, radius: CGRectGetHeight(self.rectangle1.frame))
    }


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
