//
//  EXChangePWTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXChangePWTC: UITableViewCell {
    
    typealias TextfieldValueChangeBlock = () -> ()
    var textfieldValueChangeBlock : TextfieldValueChangeBlock?
    
    var entity = EXChangePWEntity()
    
    lazy var textField : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.enableTitleModel = true
        text.enablePrivacyModel = true
        text.textfieldValueChangeBlock = {[weak self]str in
            self?.entity.info = str
            self?.textfieldValueChangeBlock?()
        }
        return text
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
            make.height.equalTo(53)
        }
    }
    
    func setCell(_ entity : EXChangePWEntity){
        textField.setTitle(title: entity.name)
        textField.setPlaceHolder(placeHolder: entity.placeHolder)
        self.entity = entity
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
