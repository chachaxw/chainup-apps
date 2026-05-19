//
//  EXSkeletonTradingCell.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

class EXSkeletonTradingCell: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(placeholder)
        addSubview(rectangle2)
        addSubview(rectangle3)
        addSubview(rectangle4)
        addSubview(circle)
        
        circle.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.333)
            make.width.equalTo(circle.snp.height)
        }
        placeholder.snp.makeConstraints { make in
            make.left.equalTo(circle.snp.right)
            make.centerY.height.equalTo(circle)
            make.width.equalToSuperview().multipliedBy(0.023)
        }
        rectangle1.snp.makeConstraints { make in
            make.left.equalTo(placeholder.snp.right)
            make.centerY.height.equalTo(circle)
            make.width.equalToSuperview().multipliedBy(0.090)
        }
        
        rectangle2.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.515)
            make.width.equalToSuperview().multipliedBy(0.292)
        }
        
        rectangle3.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.height.width.equalTo(rectangle2)
        }
        
        rectangle4.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.height.width.equalTo(rectangle2)
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
