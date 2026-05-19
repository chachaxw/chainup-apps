//
//  EXSkeletonProfileShortuct.swift
//  EXKit
//
//  Created by youbin on 2023/7/3.
//

import UIKit

class EXSkeletonProfileShortuct: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(placeholder)
        addSubview(rectangle3)
        rectangle1.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(rectangle1.snp.height)
        }
        
        rectangle3.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(rectangle1)
        }
        placeholder.snp.makeConstraints { make in
            make.right.equalTo(rectangle3.snp.left)
            make.width.equalToSuperview().multipliedBy(0.105)
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        rectangle2.snp.makeConstraints { make in
            make.right.equalTo(placeholder.snp.left)
            make.centerY.equalTo(rectangle1)
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
