//
//  EXInputFilterCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXInputFilterCell: UITableViewCell {

    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var input: EXTextField!
    var lastValue:String?
    
    typealias LeftItemCallback = (String) -> ()
    var leftCallback : LeftItemCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.ThemeView.bg
        contentView.backgroundColor = UIColor.ThemeView.bg
        input.textfieldValueChangeBlock = {[weak self] text in
            self?.updateLeftValue(text)
        }
    }
    
    func updateLeftValue(_ value:String) {
        leftCallback?(value)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func bindModel(_ model:EXFilterDataModel) {
        cellTitle.text = model.title
        input.input.keyboardType = model.keyBoardType
        if model.items.count > 0 {
            let modelLeft = model.items[0]
            input.setPlaceHolder(placeHolder: modelLeft.inputPlaceHolder)
            if let value = self.lastValue {
                input.setText(text: value)
            }else {
                input.setText(text: "")
            }
        }

    }
    
    class func getHeight() -> CGFloat{
        //54 input box+15gap+15gap
        return 84
    }
}

