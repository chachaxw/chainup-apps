//
//  EXTradeEmptyCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/11/16.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXTradeEmptyCell: UITableViewCell {

    lazy var imgV : UIImageView = {
        let imgV = UIImageView.init()
        imgV.extUseAutoLayout()
        imgV.image = EXKitBundle.svgImage(named: "public_nocontentyet") //UIImage.svgImage(named: "public_nocontentyet")
        return imgV
    }()
    
    lazy var label : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.attributedText = NSMutableAttributedString().add(string: "common_tip_nodata".localized(),
                                                               attrDic: [NSAttributedString.Key.font : UIFont.Ex.regular(12) ,
                                                                         NSAttributedString.Key.foregroundColor : UIColor.Ex.text2])
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        label.textColor = .Ex.text2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([imgV,label])
        
        imgV.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(48)
            make.centerX.equalToSuperview()
        }
        
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imgV.snp.bottom).offset(13)
            make.height.equalTo(17)
            make.left.right.equalToSuperview()
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickLabel))
        label.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func clickLabel(){
       // EXAppVersionHandler.getVersionForPublicInfo()
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
