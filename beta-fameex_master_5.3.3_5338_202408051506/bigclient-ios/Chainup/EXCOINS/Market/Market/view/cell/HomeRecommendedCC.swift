//
//  HomeRecommendedCC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class HomeRecommendedCC: UICollectionViewCell,MarkCheckable {
//    var checkMarkView = CheckMarkView.init(style: CheckStyle.checkMark, isChecked: true, presenter: self)
    internal lazy var checkMarkView : CheckMarkView = {
        let check =  CheckMarkView.init(style:.checkMarkBig, isChecked:true, presenter:self)
        check.isUserInteractionEnabled = false
        return check
    }()
    var entity = EXHomeTicker()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemekLine.labcolorMedium
        return label
    }()
    
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemekLine.labcolorLite
        return label
    }()
    
    lazy var appliesLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.BodyBold
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.extSetCornerRadius(4)
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor.ThemekLine.navBg
        contentView.addSubViews([nameLabel,priceLabel,appliesLabel,checkMarkView])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14.5)
            make.right.equalTo(checkMarkView.snp.left).offset(-1)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(14)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(15)
            make.height.equalTo(19)
            make.right.equalToSuperview().offset(-10)
        }
        appliesLabel.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.left.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
        }
        checkMarkView.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.height.width.equalTo(31)
        }
    }
    
    func setCell(_ entity : EXHomeTicker){
        if entity.name.aliasCoinMapName() == ""{
            nameLabel.text = "--"
            priceLabel.text = "--"
            appliesLabel.text = "--"
            return
        }
        self.entity = entity
        nameLabel.text = entity.name.aliasCoinMapName()
        appliesLabel.textColor = entity.backColor
        appliesLabel.text = entity.rose
        priceLabel.text = entity.close
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
