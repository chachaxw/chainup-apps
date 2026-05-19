//
//  EXContractMenuItemView.swift
//  Chainup
//
//  Created by cwd on 2022/11/14.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

class EXContractMenuItemView: UICollectionViewCell {
    
    
    var model = EXSBouncedModel(){
        didSet{
            imgV.image = UIImage.exs_themeImageNamed(imageName: model.img)
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
            let attributedText = NSAttributedString(string: model.name, attributes: attributes)
            nameLabel.attributedText = attributedText
        }
    }
    
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
        self.contentView.backgroundColor = UIColor.ThemeView.alertBg
        contentView.addSubViews([imgV,nameLabel])
        imgV.snp.makeConstraints { (make) in
            make.height.width.equalTo(32)
            make.top.equalToSuperview() //.offset(8)
            make.centerX.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(imgV.snp.bottom).offset(4)
            make.height.equalTo(14)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
