//
//  EXSkeletonProfileBanner.swift
//  EXKit
//
//  Created by youbin on 2023/7/3.
//

import UIKit

class EXSkeletonProfileBanner: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        rectangle1.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
