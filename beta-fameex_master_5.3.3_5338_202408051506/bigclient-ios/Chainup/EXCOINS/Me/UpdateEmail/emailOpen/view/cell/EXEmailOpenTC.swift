//
//  EXEmailOpenTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXEmailOpenTC: UITableViewCell {
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = UserInfoEntity.sharedInstance().email
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var rightLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = LanguageTools.getString(key: "common_action_edit")
        return label
    }()
    
    lazy var rightImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = EXKitBundle.image(named: "public_positions_arrow_right")
        imgV.contentMode = .scaleAspectFit
        return imgV
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([nameLabel,rightLabel,rightImgV,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.right.equalTo(rightLabel.snp.left).offset(-10)
        }
        rightLabel.snp.makeConstraints { (make) in
            make.height.equalTo(17)
            make.right.equalTo(rightImgV.snp.left).offset(-5)
            make.centerY.equalToSuperview()
        }
        rightImgV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(10)
            make.width.equalTo(7)
            make.centerY.equalToSuperview()
        }
        lineV.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.equalToSuperview().offset(15)
            make.bottom.right.equalToSuperview()
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
