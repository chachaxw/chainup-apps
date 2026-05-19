//
//  EXShieldTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage

class EXShieldTC: UITableViewCell {
    
    lazy var logoImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.extSetCornerRadius(13)
        return imgV
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var lineV : UIView = {
        let lineV = UIView()
        lineV.extUseAutoLayout()
        lineV.backgroundColor = UIColor.ThemeView.seperator
        return lineV
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([logoImgV,nameLabel,lineV])
        logoImgV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.width.equalTo(26)
            make.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(logoImgV.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-10)
        }
        lineV.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //
    func setCell(_ entity : EXRelationShip){
        var name = ""
        if entity.otcNickName.count > 0{
            name = entity.otcNickName.extStringSub(NSRange.init(location: 0, length: 1))
        }
        if let url = URL.init(string: entity.image){
            logoImgV.yy_setHighlightedImage(with: url, placeholder: UIImage.getTextImage(drawText: name , size: CGSize.init(width: 13, height: 13)) , options: YYWebImageOptions.allowBackgroundTask, completion: nil)
        }else{
            logoImgV.image = UIImage.getTextImage(drawText: name , size: CGSize.init(width: 13, height: 13))
        }
        nameLabel.text = entity.otcNickName
    }
    
    //delete
    @objc func clickDeleteBtn(){
NSLog ("Delete")
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

