//
//  EXMixFilterCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXMixFilterCell: EXFilterBaseCell {
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var input: EXTextField!
    @IBOutlet var selectionField: EXSelectionField!
    var btnsAry:[EXTextButton] = []
    var models:[EXFilterItem] = []
    var selectedItemValue:String = ""
    @IBOutlet var containerView: UIView!
    static let column:Int = 3
    var isExpand:Bool = false
    var isForceAll:Bool = false
    var lastLeftValue:String?
    var lastRightValue:String?
    
    @IBOutlet var bottomGap: NSLayoutConstraint!

    typealias LeftItemCallback = (String) -> ()
    var leftCallback : LeftItemCallback?
    typealias RightItemCallback = (String) -> ()
    var rightCallback : RightItemCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.ThemeView.bg
        contentView.backgroundColor = UIColor.ThemeView.bg
        selectionField.textfieldDidTapBlock = {[weak self]  in
            guard let mySelf = self else{return}
            mySelf.isExpand = !mySelf.isExpand
            mySelf.cellDidExpandBlock?(mySelf.isExpand)
        }
        input.textfieldValueChangeBlock = {[weak self] text in
            self?.updateLeftValue(text)
        }
        // Initialization code
    }
    
    func updateLeftValue(_ value:String) {
        leftCallback?(value)
    }
    
    
    func clearData() {
        for btn in btnsAry {
            btn.removeFromSuperview()
        }
        btnsAry.removeAll()
    }
    
    func bindMixCell(model:EXFilterDataModel, expand:Bool) {
        cellTitle.text = model.title
        self.isExpand = expand
        if !self.isExpand {
            bottomGap.constant = 0
            selectionField.normalStyle()
        }else {
            bottomGap.constant = 15
        }
        
        if model.items.count > 0 {
            let leftModel = model.items[0]
            input.setPlaceHolder(placeHolder: leftModel.inputPlaceHolder)
            if let lastValue = self.lastLeftValue {
                input.setText(text: lastValue)
            }else {
                input.setText(text: "")
            }
        }
        if model.extraItems.count > 0 {
            self.clearData()
            self.models = model.extraItems
            let rightItem = model.extraItems[0]
          
            if let lastValue = self.lastRightValue,lastValue.count > 0 {
                self.selectedItemValue = lastValue
                if selectedItemValue == EXFoldItemType.forceAll.rawValue {
                    input.setText(text: "common_text_allDay".localized())
                    self.updateLeftValue("common_text_allDay".localized())
                    input.input.isUserInteractionEnabled = false
                }else {
                    if let lastLeft = lastLeftValue,lastLeft == "common_text_allDay".localized(){
                        input.setText(text: "")
                        self.updateLeftValue("")
                    }
                    
                    input.input.isUserInteractionEnabled = true
                }
                for item in models {
                    if item.valueKey == lastValue {
                        selectionField.setText(text: item.text)
                    }
                }
            }else {
                self.selectedItemValue = ""
                if rightItem.valueKey == EXFoldItemType.forceAll.rawValue {
                    input.setText(text: "common_text_allDay".localized())
                    self.updateLeftValue("common_text_allDay".localized())
                    input.input.isUserInteractionEnabled = false
                }else {
                    if let lastLeft = lastLeftValue,lastLeft == "common_text_allDay".localized() {
                        input.setText(text: "")
                        self.updateLeftValue("")
                    }
                    input.input.isUserInteractionEnabled = true
                }
                selectionField.setText(text: rightItem.text)
            }
            if self.isExpand {
                let btnHeight = 32
                let horizonGap = SCREEN_WIDTH * 0.06
                let btnWidth = (SCREEN_WIDTH - 30 - horizonGap*2)/3
                let ygap = 15
                let startX = 15
                let startY = 0
                
                for (idx,item) in models.enumerated() {
                    
                    let cellItem = EXTextButton()
                    cellItem.setFont(font: .Ex.regular(14))
                    cellItem.supportCheckHighlight = true
                    if self.selectedItemValue.isEmpty {
                        cellItem.isSelected = (idx == 0)
                    }else {
                        if item.valueKey == self.selectedItemValue {
                            cellItem.isSelected = true
                        }else {
                            cellItem.isSelected = false
                        }
                    }
                    
                    cellItem.color = UIColor.ThemeView.bgTab
                    cellItem.setTitle(item.text, for: .normal)
                    cellItem.addTarget(self, action: #selector(itemDidTapAction(sender:)), for: .touchUpInside)
                    
                    containerView.addSubview(cellItem)
                    let col = idx %  EXFoldFilterCell.column
                    let row = idx / EXFoldFilterCell.column
                    let xPosition = (btnWidth + horizonGap)*CGFloat(col)
                    let yPosition = (btnHeight + ygap)*(row)
                    let px = CGFloat(startX) + xPosition
                    let py = startY + yPosition
                    cellItem.frame = CGRect(x: px, y: CGFloat(py), width: btnWidth, height: CGFloat(btnHeight))
                    cellItem.tag = idx
                    btnsAry.append(cellItem)
                }
            }
        }
    }
    
    @objc func itemDidTapAction(sender:UIButton) {
        for btn in btnsAry {
            if btn == sender {
                btn.isSelected = true
            }else {
                btn.isSelected = false
            }
        }
        let model = self.models[sender.tag]
        selectionField.setText(text: model.text)
        
        rightCallback?(model.valueKey)
        cellDidExpandBlock?(false)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    class func getHeight(models:[EXFilterItem],expand:Bool = false) -> CGFloat{
        let normalHeight = CGFloat(44 + 45)
        if expand {
            let quotient = models.count/self.column
            var  remainder = models.count%self.column

            if remainder > 0 {
                remainder = 1
            }
            let rowHeight = (quotient + remainder)*36
            let gapHeight = (quotient + remainder - 1)*15
            return CGFloat(rowHeight + gapHeight) + normalHeight
            
        }else {
            return normalHeight
        }
    }
}
