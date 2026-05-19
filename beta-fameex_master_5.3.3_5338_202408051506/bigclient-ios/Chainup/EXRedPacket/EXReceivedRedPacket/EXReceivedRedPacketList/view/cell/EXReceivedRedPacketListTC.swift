//
//  EXReceivedRedPacketListTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXReceivedRedPacketListTC: EXSendOutRedPacketListCell {

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        imgV.isHidden = true
        nameLabel.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(22)
            make.top.equalToSuperview().offset(15)
            make.right.equalTo(numLabel.snp.left).offset(-10)
        }
    }
    
    func setCell(_ entity : EXReceivedRedPacketListDetailEntity){
        nameLabel.text = entity.nickName
        
        timeLabel.text = DateTools.strToTimeString(entity.ctime, dateFormat: "yyyy/MM/dd")
        
        numLabel.text = entity.amount + " " + entity.coinSymbol.aliasName()
        
        statusLabel.text = entity.equivalentFiat()
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
