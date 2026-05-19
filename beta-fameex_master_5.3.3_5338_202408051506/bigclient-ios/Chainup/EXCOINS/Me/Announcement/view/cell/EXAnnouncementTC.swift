//
//  EXAnnouncementTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXAnnouncementTC: UITableViewCell {
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
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
        contentView.addSubViews([nameLabel,timeLabel,rightImgV,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(rightImgV.snp.left).offset(-10)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(13)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(nameLabel)
            make.height.equalTo(14)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
        }
        rightImgV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(10)
            make.width.equalTo(7)
            make.centerY.equalTo(nameLabel)
        }
        lineV.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(0.5)
        }
    }
    
    func setCell(_ entity : EXAnnouncementEntity){
        timeLabel.text = entity.timeLong
        nameLabel.text = entity.title
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
