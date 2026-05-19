//
//  EKMaskSegment.swift
//  EXKit-EXKit
//
//  Created by liuxuan on 2022/7/22.
//

import UIKit
import JXSegmentedView

public protocol EKMaskSegmentDelegate :AnyObject {
    func segmentTitles() -> [String]
}

public class EKMaskSegmentDatasource: JXSegmentedTitleDataSource {
    
    public override init() {
        super.init()
        self.titleSelectedColor = UIColor.ThemeLabel.colorLite
        self.titleNormalColor = UIColor.ThemeLabel.colorMedium
        self.titleNormalFont = UIFont.ThemeFont.BodyMedium
        self.titleSelectedFont = UIFont.ThemeFont.BodyMedium
        self.isTitleColorGradientEnabled = false
        self.isItemSpacingAverageEnabled = false
        
//        self.isTitleMaskEnabled = true
    }
}

public class EKMaskSegmentIndicator: JXSegmentedIndicatorBackgroundView {
    
    public override func commonInit() {
        super.commonInit()
//        self.isIndicatorConvertToItemFrameEnabled = true
        self.indicatorColor = UIColor.ThemeView.card2
        self.indicatorHeight = 20
        self.indicatorWidth = JXSegmentedViewAutomaticDimension
        self.indicatorWidthIncrement = 16
        self.isIndicatorWidthSameAsItemContent = true
        self.indicatorCornerRadius = 4
    }
}

