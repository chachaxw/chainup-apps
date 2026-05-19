//
//  EXEmailBindingTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXEmailBindingTC: UITableViewCell {
    
    typealias TextfieldValueChangeBlock = (String) -> ()
    var textfieldValueChangeBlock : TextfieldValueChangeBlock?
    var modify: Bool = false {
        didSet {
            if modify {
                textField.setTitle(title: "personal_Center_text10".localized())
                textField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "personal_Center_text11"))
            }
        }
    }
    lazy var textField : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.titleLabel.bodyRegular()
        text.setTitle(title: LanguageTools.getString(key: "personal_Center_text9"))
        text.titleLabel.textColor = UIColor.ThemeLabel.colorLite
        text.enableTitleModel = true
        text.setPlaceHolder(placeHolder: LanguageTools.getString(key: "safety_tip_inputMail"))
        text.textfieldValueChangeBlock = {[weak self]str in
            self?.textfieldValueChangeBlock?(str)
        }
        return text
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([textField])
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(57)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
