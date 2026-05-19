//
//  EXGoogleInputTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/15.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXGoogleInputTC: UITableViewCell {
    
    typealias TxtFieldValueChanged = () -> ()
    var textfieldValueChangeBlock :TxtFieldValueChanged?
    var entity = EXGoogleCellEntity()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        label.layoutIfNeeded()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var pwInputV : EXTextField = {
        let inputV = EXTextField()
        inputV.extUseAutoLayout()
        inputV.enablePrivacyModel = true
        inputV.enableTitleModel = true
        inputV.setTitle(title: LanguageTools.getString(key: "register_text_loginPwd"))
        inputV.setPlaceHolder(placeHolder: "register_tip_inputPassword".localized())
        inputV.titleLabel.font = UIFont.ThemeFont.BodyRegular
        inputV.titleLabel.textColor = UIColor.ThemeLabel.colorLite
        inputV.textfieldValueChangeBlock = {[weak self]str in
            self?.entity.info1 = str
            self?.textfieldValueChangeBlock?()
        }
        return inputV
    }()
    lazy var googleCodeV : EXPasteField = {
        let inputV = EXPasteField()
        inputV.extUseAutoLayout()
        inputV.input.keyboardType = .numberPad
        inputV.showTitle = true
        inputV.setPlaceHolder(placeHolder: "common_tip_googleAuth".localized())
        inputV.setTitle(title: "safety_text_googleAuth".localized())
        inputV.titleLabel.font = .Ex.regular(14)
        inputV.titleLabel.textColor = .Ex.text1
        inputV.pasteBtn.titleLabel?.font = .Ex.regular(14)
        inputV.pasteBtn.setTitleColor(.Ex.main4, for: .normal)
        inputV.textfieldValueChangeBlock = {[weak self]str in
            self?.entity.info2 = str
            self?.textfieldValueChangeBlock?()
        }
        return inputV
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([nameLabel,pwInputV,googleCodeV])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-15)
        }
        
        pwInputV.snp.makeConstraints { (make) in
            make.height.equalTo(54)
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(15)
            make.bottom.equalTo(googleCodeV.snp.top).offset(-15)
        }
        
        googleCodeV.snp.makeConstraints { (make) in
            make.height.equalTo(54)
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(pwInputV.snp.bottom).offset(15)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCell(_ entity : EXGoogleCellEntity){
        self.entity = entity
        nameLabel.text = entity.name
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
