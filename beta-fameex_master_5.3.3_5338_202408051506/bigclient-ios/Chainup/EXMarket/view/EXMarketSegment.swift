//
//  EXMarketSegment.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/21.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import JXSegmentedView

class EXMarketSegment: UIView {
    
    lazy var segmentedView: JXSegmentedView = {
        let view = JXSegmentedView(frame: CGRect(x: 16, y: NAV_SCREEN_HEIGHT, width: SCREEN_WIDTH - 30 , height: 30))
        view.delegate = self
        return view
    }()
    
    lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        let source = JXSegmentedTitleDataSource()
        source.itemContentWidth = (SCREEN_WIDTH-30)/3
        source.itemSpacing = 0
        source.titleNormalColor = UIColor.ThemeLabel.colorMedium
        source.titleSelectedColor = UIColor.ThemeLabel.colorLite
        source.titleNormalFont = UIFont.ThemeFont.BodyRegular
        source.titleSelectedFont = UIFont.ThemeFont.BodyRegular
        return source
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let indicator = JXSegmentedIndicatorBackgroundView()
        indicator.indicatorHeight = 30
        indicator.indicatorWidthIncrement = 0
        indicator.indicatorCornerRadius = 0
        indicator.indicatorColor = UIColor.ThemeNav.bg
        segmentedView.layer.masksToBounds = true
        segmentedView.layer.cornerRadius = 5
        segmentedView.layer.borderColor = UIColor.ThemeView.border.cgColor
        segmentedView.layer.borderWidth = 1 / UIScreen.main.scale
        segmentedView.indicators = [indicator]
        segmentedDataSource.titles = ["","",""]
        segmentedView.dataSource = segmentedDataSource
        self.addSubview(segmentedView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXMarketSegment: JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
    }
    
}



