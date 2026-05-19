//
//  JXSegmentedCustomDataSource.swift
//  Chainup
//
//  Created by youbin on 2023/6/16.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView

class JXSegmentedCustomDataSource: JXSegmentedTitleDataSource {
    ///Background color
    open var bgColor              : UIColor = .clear
    ///Select Background Color
    open var bgSelectedColor      : UIColor = .clear
    
    open var borderColor          : UIColor = .clear
    open var selectedBorderColor  : UIColor = .clear
    
    open var borderWidth          : CGFloat = 0.0
    open var selectedborderWidth  : CGFloat = 0.0
    
    open var cornerRadius         : CGFloat = 0.0
    open var selectedCornerRadius : CGFloat = 0.0
    
    
    open override func preferredItemModelInstance() -> JXSegmentedBaseItemModel {
        return JXSegmentedCustomItemModel()
    }
    
    override func preferredRefreshItemModel(_ itemModel: JXSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        super.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)
        guard let myItemModel = itemModel as? JXSegmentedCustomItemModel else {
            return
        }
        myItemModel.bgColor              = bgColor
        myItemModel.bgSelectedColor      = bgColor
        myItemModel.cornerRadius         = cornerRadius
        myItemModel.selectedCornerRadius = selectedCornerRadius
        
        myItemModel.borderColor         = borderColor
        myItemModel.selectedBorderColor = selectedBorderColor
        myItemModel.borderWidth         = borderWidth
        myItemModel.selectedborderWidth = selectedborderWidth
    }
    
    //Register Cell
    override func registerCellClass(in segmentedView: JXSegmentedView) {
        segmentedView.collectionView.register(JXSegmentedCustomTitleCell.self, forCellWithReuseIdentifier: NSStringFromClass(JXSegmentedCustomTitleCell.self))
    }
    
    //Reuse Cells
    override func segmentedView(_ segmentedView: JXSegmentedView, cellForItemAt index: Int) -> JXSegmentedBaseCell {
        return segmentedView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(JXSegmentedCustomTitleCell.self), at: index)
    }
    
    override func refreshItemModel(_ segmentedView: JXSegmentedView, currentSelectedItemModel: JXSegmentedBaseItemModel, willSelectedItemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
        super.refreshItemModel(segmentedView, currentSelectedItemModel: currentSelectedItemModel, willSelectedItemModel: willSelectedItemModel, selectedType: selectedType)
        guard let myCurrentSelectedItemModel = currentSelectedItemModel as? JXSegmentedTitleItemModel, let myWilltSelectedItemModel = willSelectedItemModel as? JXSegmentedTitleItemModel else {
            return
        }
        myCurrentSelectedItemModel.titleCurrentColor = myCurrentSelectedItemModel.titleNormalColor
        myWilltSelectedItemModel.titleCurrentColor = myWilltSelectedItemModel.titleSelectedColor
    }
    
}

class JXSegmentedCustomItemModel: JXSegmentedTitleItemModel {
    
    ///Background color
    open var bgColor              : UIColor = .white
    open var bgSelectedColor      : UIColor = .white
    
    open var borderColor          : UIColor = .clear
    open var selectedBorderColor  : UIColor = .clear
    
    open var borderWidth          : CGFloat = 0.0
    open var selectedborderWidth  : CGFloat = 0.0
    
    open var cornerRadius         : CGFloat = 0.0
    open var selectedCornerRadius : CGFloat = 0.0
    
}

class JXSegmentedCustomTitleCell: JXSegmentedTitleCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func reloadData(itemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType)
        if itemModel is JXSegmentedCustomItemModel {
            let _item = itemModel as! JXSegmentedCustomItemModel
            if _item.isSelected {
                titleLabel.layer.cornerRadius = _item.selectedCornerRadius
                titleLabel.backgroundColor    = _item.bgSelectedColor
                titleLabel.layer.borderColor  = _item.selectedBorderColor.cgColor
                titleLabel.layer.borderWidth  = _item.selectedborderWidth
            } else {
                titleLabel.layer.cornerRadius = _item.cornerRadius
                titleLabel.backgroundColor    = _item.bgColor
                titleLabel.layer.borderColor  = _item.borderColor.cgColor
                titleLabel.layer.borderWidth  = _item.borderWidth
            }
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let labelSize = titleLabel.sizeThatFits(self.contentView.bounds.size)
        var labelBounds: CGRect = .zero
        if labelSize.width > 0, labelSize.height > 0 {
            labelBounds = CGRect(x: 0, y: 0, width: labelSize.width + 10, height: labelSize.height + 6)
        }
        titleLabel.bounds = labelBounds
    }
    
}

