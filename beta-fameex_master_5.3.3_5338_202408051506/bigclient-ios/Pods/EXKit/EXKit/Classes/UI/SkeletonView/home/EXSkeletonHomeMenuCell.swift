//
//  EXSkeletonHomeMenuCell.swift
//  EXKit
//
//  Created by youbin on 2023/6/28.
//

import UIKit

class EXSkeletonHomeMenuCell: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        rectangle2.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.35)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        rectangle1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.55)
            make.centerX.equalToSuperview()
            make.width.equalTo(rectangle1.snp.height)
        }
        rectangle1.skeletonSolid(with: .Ex.fill3)
        rectangle2.skeletonSolid(with: .Ex.fill3)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
