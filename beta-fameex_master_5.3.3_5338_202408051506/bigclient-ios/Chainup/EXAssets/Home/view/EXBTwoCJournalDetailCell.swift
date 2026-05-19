//
//  EXBTwoCJournalDetailCell.swift
//  Chainup
//
//  Created by ljw on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXBTwoCJournalDetailCell: UITableViewCell {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var leftLab: UILabel!
    @IBOutlet weak var rightBtn: UIButton!
    typealias Block = () -> ()
    var cellBlock : Block?
    
    var model = EXCellDataModel() {
        didSet {
            rightBtn.isSelected = model.isNeedAction
            handleModel(model: model)
        }
    }
    func handleModel(model : EXCellDataModel) {
        leftLab.text = model.leftStr;
        rightBtn.setTitle(model.rightStr, for: UIControl.State.normal)
        rightBtn.setTitle(model.rightStr, for: UIControl.State.selected)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        self.selectionStyle = .none
        lineView.backgroundColor = UIColor.ThemeView.seperator
        leftLab.textColor = UIColor.ThemeLabel.colorMedium
        rightBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: UIControl.State.normal)
        rightBtn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: UIControl.State.selected)
    }

    @IBAction func rightBtnClick(_ sender: UIButton) {
        if sender.isSelected {
            self.cellBlock?()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
