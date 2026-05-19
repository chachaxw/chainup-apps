//
//  EXSkeletonAssetsBalance.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

class EXSkeletonAssetsBalance: EXSkeletonComponents {

    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(placeholder)
        addSubview(rectangle3)
        addSubview(rectangle4)
        rectangle1.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.210)
            make.height.equalToSuperview().multipliedBy(0.302)
        }
        rectangle2.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.446)
            make.height.equalToSuperview().multipliedBy(0.623)
        }
        placeholder.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(rectangle2.snp.right)
            make.width.equalToSuperview().multipliedBy(0.012)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        rectangle3.snp.makeConstraints { make in
            make.bottom.equalTo(rectangle2)
            make.left.equalTo(placeholder.snp.right)
            make.width.equalToSuperview().multipliedBy(0.216)
            make.height.equalToSuperview().multipliedBy(0.302)
        }
        rectangle4.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.377)
            make.width.equalTo(rectangle4.snp.height)
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
