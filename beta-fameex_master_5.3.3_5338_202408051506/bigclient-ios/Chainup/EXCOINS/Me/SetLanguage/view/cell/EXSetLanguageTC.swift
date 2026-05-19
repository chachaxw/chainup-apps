//
//  EXSetLanguageTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXSetLanguageTC: UITableViewCell {

    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.HeadRegular
        return label
    }()
    
    lazy var rightImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.contentMode = .scaleAspectFit
        imgV.image =  EXKitBundle.svgImage(named: "public_checked")
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
        contentView.addSubViews([nameLabel,rightImgV,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.lessThanOrEqualTo(200)
        }
        rightImgV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        lineV.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setCell(_ entity : AppCfgLanListItem){
        nameLabel.text = entity.name
        rightImgV.isHidden = !entity.selected
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

