//
//  EXSkeletonHomeRankFilter.swift
//  EXKit
//
//  Created by youbin on 2023/6/28.
//

import UIKit

class EXSkeletonHomeRankFilter: EXSkeletonComponents {
    
    lazy var rectangle2Back: UIView = {
        let v = UIView()
        return v
    }()
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2Back)
        addSubview(rectangle3)
        rectangle2Back.addSubview(rectangle2)
        
        rectangle1.snp.makeConstraints { make in
            make.left.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.064)
        }
        rectangle2Back.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalTo(rectangle2Back.superview!.snp.centerX)
            make.width.equalToSuperview().multipliedBy(0.195)
        }
        rectangle3.snp.makeConstraints { make in
            make.right.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.152)
        }
        rectangle2.snp.makeConstraints { make in
            make.right.centerY.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.783)
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
