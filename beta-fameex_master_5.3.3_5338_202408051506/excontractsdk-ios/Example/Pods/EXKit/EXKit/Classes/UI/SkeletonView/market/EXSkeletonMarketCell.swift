//
//  EXSkeletonMarketCell.swift
//  EXKit
//
//  Created by youbin on 2023/6/28.
//

import UIKit

class EXSkeletonMarketCell: EXSkeletonComponents {
    
    lazy var rectangle5: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(rectangle3)
        addSubview(rectangle4)
        addSubview(rectangle5)
        addSubview(placeholder)

        rectangle1.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.469)
            make.width.equalToSuperview().multipliedBy(0.265)
        }
        rectangle2.snp.makeConstraints { make in
            make.bottom.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.469)
            make.width.equalToSuperview().multipliedBy(0.102)
        }
        rectangle5.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.210)
        }
        placeholder.snp.makeConstraints { make in
            make.centerY.height.equalToSuperview()
            make.right.equalTo(rectangle5.snp.left)
            make.width.equalToSuperview().multipliedBy(0.105)
        }
        rectangle3.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalTo(placeholder.snp.left)
            make.height.width.equalTo(rectangle1)
        }
        rectangle4.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalTo(placeholder.snp.left)
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
