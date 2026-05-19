//
//  EXSkeletonHomRankCell.swift
//  EXKit
//
//  Created by youbin on 2023/6/28.
//

import UIKit

class EXSkeletonHomRankCell: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(rectangle3)
        
        rectangle1.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.357)
            make.width.equalToSuperview().multipliedBy(0.195)
        }
        
        rectangle2.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(rectangle2.superview!.snp.centerX)
            make.height.equalToSuperview().multipliedBy(0.357)
            make.width.equalToSuperview().multipliedBy(0.195)
        }
        
        rectangle3.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.571)
            make.width.equalToSuperview().multipliedBy(0.210)
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
