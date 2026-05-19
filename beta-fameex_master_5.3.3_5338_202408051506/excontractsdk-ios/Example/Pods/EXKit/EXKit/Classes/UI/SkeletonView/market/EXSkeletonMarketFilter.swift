//
//  EXSkeletonMarketFilter.swift
//  EXKit
//
//  Created by youbin on 2023/6/28.
//

import UIKit

class EXSkeletonMarketFilter: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(placeholder)
        addSubview(rectangle3)
        rectangle1.snp.makeConstraints { make in
            make.left.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.102)
        }
        rectangle3.snp.makeConstraints { make in
            make.right.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.198)
        }
        placeholder.snp.makeConstraints { make in
            make.right.equalTo(rectangle3.snp.left)
            make.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.117)
        }
        rectangle2.snp.makeConstraints { make in
            make.right.equalTo(placeholder.snp.left)
            make.height.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.198)
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
