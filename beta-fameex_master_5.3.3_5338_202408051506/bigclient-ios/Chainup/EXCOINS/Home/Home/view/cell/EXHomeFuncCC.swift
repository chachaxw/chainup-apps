//
//  EXHomeFuncCC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//function

import UIKit
import YYWebImage

class EXHomeFuncCC: UICollectionViewCell {
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        return imgV
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        contentView.addSubViews([imgV,nameLabel])
        imgV.snp.makeConstraints { (make) in
            make.height.width.equalTo(22)
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(imgV.snp.bottom).offset(-2)
            make.height.equalTo(32)
        }
    }
    
    func setCell(_ entity : HomeFunctionEntity){
        imgV.isHidden = entity.type == ""
        nameLabel.isHidden = imgV.isHidden
        if entity.type != ""{
            imgV.yy_setImage(with: URL.init(string: entity.imageUrl), options: YYWebImageOptions.allowBackgroundTask)
            nameLabel.text = entity.title
        }
    }
    
    func bindCell(_ model : CmsAppDataItem) {
        imgV.isHidden = model.type == ""
        nameLabel.isHidden = imgV.isHidden
        if model.type != ""{
//            model.title = "Mortgege goan"
            imgV.yy_setImage(with: URL.init(string: model.imageUrl),placeholder: UIImage.themeImageNamed(imageName: "home_icon_quickentry_occupationmap"), options: YYWebImageOptions.allowBackgroundTask)
            let style = NSMutableParagraphStyle()
            style.minimumLineHeight = 15
            style.maximumLineHeight = 15
//            style.lineSpacing = 10 - (nameLabel.font.lineHeight - nameLabel.font.pointSize);

//            style.lineBreakMode = .byTruncatingTail
            style.alignment = .center
//            style.paragraphSpacing = 5
            let attributes = [NSAttributedString.Key.paragraphStyle : style,
                              .foregroundColor:UIColor.ThemeLabel.colorLite,
                              .font:UIFont.ThemeFont.SecondaryRegular]
            let attributedText = NSAttributedString(string: model.title, attributes: attributes)
            nameLabel.attributedText = attributedText
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


