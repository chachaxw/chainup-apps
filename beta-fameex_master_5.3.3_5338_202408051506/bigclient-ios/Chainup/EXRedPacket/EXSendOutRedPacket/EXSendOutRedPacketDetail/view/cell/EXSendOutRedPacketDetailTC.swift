//
//  EXSendOutRedPacketDetailTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/6/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXSendOutRedPacketDetailTC: UITableViewCell {
    
    //name
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.HeadBold
        label.layoutIfNeeded()
        return label
    }()
    
    //Newcomer logo
    lazy var newMarkImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "new")
        return imgV
    }()
    
    //optimum
    lazy var luckImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "bestluck")
        return imgV
    }()
    
    //quantity
    lazy var numLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.HeadBold
        label.textAlignment = .right
        return label
    }()
    
    //date
    lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()
    
    //Equivalent
    lazy var convertLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        label.layoutIfNeeded()
        label.textAlignment = .right
        return label
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
        contentView.addSubViews([nameLabel,newMarkImgV,luckImgV,numLabel,timeLabel,convertLabel,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(22)
            make.width.lessThanOrEqualTo(0)
        }
        newMarkImgV.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.width.equalTo(22)
            make.centerY.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp.right).offset(8)
        }
        luckImgV.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.width.equalTo(16)
            make.centerY.equalTo(newMarkImgV)
            make.left.equalTo(newMarkImgV.snp.right).offset(8)
        }
        numLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(22)
            make.centerY.equalTo(nameLabel)
            make.left.equalTo(luckImgV.snp.right).offset(10)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.height.equalTo(14)
            make.right.equalTo(convertLabel.snp.left).offset(-10)
        }
        convertLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(22)
            make.centerY.equalTo(timeLabel)
        }
        lineV.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(0.5)
        }
    }
    
    func setCell(_ entity : EXRedPacketListDetailEntity){
        
        let width = entity.nickName.textHeightSizeWithFont(UIFont.ThemeFont.HeadBold, height: 22).width + 5
        nameLabel.snp.updateConstraints { (make) in
            make.width.lessThanOrEqualTo(width)
        }
        
        if entity.isNew == "0"{
            newMarkImgV.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
        }else{
            newMarkImgV.snp.updateConstraints { (make) in
                make.width.equalTo(22)
            }
        }
        
        if entity.isLucky == "0"{
            luckImgV.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
        }else{
            luckImgV.snp.updateConstraints { (make) in
                make.width.equalTo(16)
            }
        }
        
        nameLabel.text = entity.nickName
        
        numLabel.text = entity.amount + " " + entity.coinSymbol.aliasName()
        
        timeLabel.text = DateTools.strToTimeString(entity.ctime, dateFormat: "MM/dd HH:mm:ss")
        
        convertLabel.text = entity.equivalentFiat()
        
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

