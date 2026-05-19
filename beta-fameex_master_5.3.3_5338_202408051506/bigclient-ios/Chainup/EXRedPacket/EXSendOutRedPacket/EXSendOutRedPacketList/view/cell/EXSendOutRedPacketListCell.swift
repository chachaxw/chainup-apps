//
//  EXSendOutRedPacketListCell.swift
//  Chainup
//
//  Created by zewu wang on 2023/6/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXSendOutRedPacketListCell: UITableViewCell {
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "redenvelopehead")
        return imgV
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    lazy var numLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var statusLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textAlignment = .right
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
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
        contentView.addSubViews([imgV,nameLabel,timeLabel,numLabel,statusLabel,lineV])
        imgV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.width.equalTo(34)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imgV.snp.right).offset(10)
            make.height.equalTo(22)
            make.top.equalToSuperview().offset(15)
            make.right.equalTo(numLabel.snp.left).offset(-10)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.height.equalTo(14)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.right.equalTo(statusLabel.snp.left).offset(-10)
        }
        numLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(22)
            make.top.equalToSuperview().offset(15)
        }
        statusLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(22)
            make.centerY.equalTo(timeLabel)
        }
        lineV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.bottom.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setCell(_ entity : EXSendOutRedPacketListDetailEntity){
        nameLabel.text = entity.type == "0" ? "redpacket_send_identical".localized() : "redpacket_send_random".localized()
        
        timeLabel.text = DateTools.strToTimeString(entity.stime, dateFormat: "yyyy/MM/dd")
        
        numLabel.text = entity.amount + " " + entity.coinSymbol.aliasName()
        
        var status = ""//Status 1. Collecting 2. Collected 3. Expired
        switch entity.status {
        case "1":
            status = ""
        case "2":
            status = "redpacket_sendout_gone".localized()
        case "3":
            status = "redpacket_sendout_expired".localized()
        default:
            break
        }
        statusLabel.text = status + " " + entity.redPacketGetCount + "/" + entity.redPacketAllCount
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

