//
//  EXSkeletonHomeReferralsCell.swift
//  EXKit
//
//  Created by youbin on 2023/6/28.
//

import UIKit

class EXSkeletonHomeReferralsCell: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(rectangle3)
        addSubview(rectangle4)
        
        rectangle1.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalToSuperview().multipliedBy(0.241)
        }
        rectangle2.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.height.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.379)
        }
        rectangle3.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.842)
            make.height.equalToSuperview().multipliedBy(0.362)
        }
        rectangle4.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.842)
            make.height.equalToSuperview().multipliedBy(0.241)
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
