//
//  EXTitltleLabelBottomAlighDateSoure.swift
//  Chainup
//
//  Created by 柴伟东 on 2023/7/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
///头部字体底部对齐方案 English: /Alignment scheme for the bottom of the header font
class EXTitltleLabelCenterDataSoure: JXSegmentedTitleDataSource {
    
    //MARK: - JXSegmentedViewDataSource
    open override func registerCellClass(in segmentedView: JXSegmentedView) {
        segmentedView.collectionView.register(EXTitleCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

    open override func segmentedView(_ segmentedView: JXSegmentedView, cellForItemAt index: Int) -> JXSegmentedBaseCell {
        let cell = segmentedView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        return cell
    }
}

class EXTitleCollectionViewCell:JXSegmentedTitleCell  {
    override func layoutSubviews(){
        super.layoutSubviews()
        var f = titleLabel.frame
        let superH = contentView.frame.height
        let titleViewh:CGFloat = 25
        f.origin.y = (superH - titleViewh) * 0.5
        f.size.height = titleViewh
        titleLabel.frame = f
    }
}

