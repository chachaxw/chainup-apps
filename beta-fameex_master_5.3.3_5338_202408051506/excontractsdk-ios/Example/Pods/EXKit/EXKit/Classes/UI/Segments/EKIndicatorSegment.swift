//
//  EKIndicatorSegment.swift
//  EXKit
//
//  Created by liuxuan on 2022/7/26.
//

import UIKit
import JXSegmentedView

class EKIndicatorCell:JXSegmentedTitleCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        //        let labelSize = titleLabel.sizeThatFits(self.contentView.bounds.size)
        //        let labelBounds = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
        //        titleLabel.bounds = labelBounds
        //        titleLabel.center = contentView.center
        //
        //        maskTitleLabel.bounds = labelBounds
        //        maskTitleLabel.center = contentView.center
        
        var f = titleLabel.frame
        f.origin.y = 0
        titleLabel.frame = f
    }
}


public class EKIndicatorSegmentDatasource: JXSegmentedTitleDataSource {
    
    public override func registerCellClass(in segmentedView: JXSegmentedView) {
        segmentedView.collectionView.register(EKIndicatorCell.self, forCellWithReuseIdentifier: "EKIndicatorCell")
    }
    
    public override func segmentedView(_ segmentedView: JXSegmentedView, cellForItemAt index: Int) -> JXSegmentedBaseCell {
        let cell = segmentedView.dequeueReusableCell(withReuseIdentifier: "EKIndicatorCell", at: index)
        return cell
    }
    
    public override init() {
        super.init()
        self.titleSelectedColor = UIColor.ThemeLabel.colorLite
        self.titleNormalColor = UIColor.ThemeLabel.colorMedium
        self.titleNormalFont = UIFont.ThemeFont.HeadMedium
        self.titleSelectedFont = UIFont.ThemeFont.HeadMedium
        self.isTitleColorGradientEnabled = false
        self.isItemSpacingAverageEnabled = false
    }
}

public class EKIndicatorSegmentIndicator: JXSegmentedIndicatorLineView {
    
    public override func commonInit() {
        super.commonInit()
        self.indicatorColor = UIColor.ThemeView.highlight
        self.indicatorHeight = 4
        self.indicatorWidth = 22
        self.indicatorCornerRadius = 0
    }
}
