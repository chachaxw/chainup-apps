//
//  EXFoldFilterCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXFoldFilterCell: UITableViewCell {
    
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var expandBtn: UIButton!
    @IBOutlet var selectValueLabel: UILabel!
    
    @IBOutlet var containerView: UIView!
    static let column:Int = 3
    static var isExpand:Bool = false
    typealias ExpandCallback = (Bool) -> ()
    var cellDidExpandBlock : ExpandCallback?
    typealias ItemSelectedCallback = (String) -> ()
    var itemDidChangeBlock : ItemSelectedCallback?
    var selectedItemValue:String = ""
    var btnsAry:[EXTextButton] = []
    var models:[EXFilterItem] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.ThemeView.bg
        contentView.backgroundColor = UIColor.ThemeView.bg
        expandBtn.setImage(UIImage.themeImageNamed(imageName: "transaction_triangle_down"), for: .normal)
        expandBtn.setImage(UIImage.themeImageNamed(imageName: "transaction_triangle_up"), for: .selected)
        selectValueLabel.textColor = .Ex.main4
//        expandBtn.isHidden = true
//        selectValueLabel.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func clearData() {
        for btn in btnsAry {
            btn.removeFromSuperview()
        }
        btnsAry.removeAll()
    }
    
    func bindFoldCell(models:[EXFilterItem],expand:Bool) {
        self.clearData()
        self.models = models
        expandBtn.isSelected = expand
        expandBtn.isHidden = (models.count <= 3)
        selectValueLabel.isHidden = (models.count <= 3)
        
        let btnHeight = 32
        let horizonGap = SCREEN_WIDTH * 0.06
        let btnWidth = (SCREEN_WIDTH - 30 - horizonGap*2)/3
        let ygap = 15
        let startX = 15
        let startY = 0
        
        for (idx,item) in models.enumerated() {
            
            if expand == false,idx > 2 {
                break 
            }
            let cellItem = EXTextButton.init(type:.custom)
            cellItem.setFont(font: UIFont.ThemeFont.BodyRegular)
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
            cellItem.setColor(color:  UIColor.ThemeView.bgTab)
            cellItem.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
            cellItem.setTitleColor(UIColor.ThemeLabel.colorLite, for: .selected)

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
    
    @objc func itemDidTapAction(sender:UIButton) {
        for btn in btnsAry {
            if btn == sender {
                btn.isSelected = true
            }else {
                btn.isSelected = false
            }
        }
        let model = self.models[sender.tag]
        selectValueLabel.text = model.text
        itemDidChangeBlock?(model.valueKey)
    }
    
    class func getHeight(models:[EXFilterItem],expand:Bool = false) -> CGFloat{
        var quotient = 1
        var remainder = 0
        if expand {
            quotient = models.count/self.column
            remainder = models.count%self.column
        }
        if remainder > 0 {
            remainder = 1 
        }
        let rowHeight = (quotient + remainder)*32
        let gapHeight = (quotient + remainder - 1)*15
        return CGFloat(rowHeight + gapHeight + 15 + 44)
    }
    
    @IBAction func expandAction(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        self.cellDidExpandBlock?(sender.isSelected)
    }
    
}
