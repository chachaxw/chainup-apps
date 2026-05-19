//
//  EXTaskCenterSegmentView.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit
class EXTaskCenterSegmentView: EXView {
    override func setupView() {
        self.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    lazy var segmentedView: JXSegmentedView = {
        let v = JXSegmentedView()
        v.contentEdgeInsetLeft = 16
        v.indicators = [self.lineIndicatorLienView]
        return v
    }()
    lazy var lineIndicatorLienView: EKIndicatorSegmentIndicator = {
        let view = EKIndicatorSegmentIndicator()
        return view
    }()

}
