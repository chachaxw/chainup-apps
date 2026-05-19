//
//  EXMyInfoTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXMyInfoTC: UITableViewCell {
    
    var entity = EXMyInfoEntity()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel(font: .Ex.medium(14), textColor: .Ex.text2)
        label.extUseAutoLayout()
        return label
    }()
    
    lazy var rightImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFit
        imgV.extUseAutoLayout()
        return imgV
    }()
    
    lazy var rightLabel : UILabel = {
        let label = UILabel(font: .Ex.medium(14), textColor: .Ex.text1)
        label.extUseAutoLayout()
        label.textAlignment = .right
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var rightBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(EXKitBundle.svgImage(named: "public_positions_arrow_right_night"), for: .normal)
        btn.addTarget(self, action: #selector(copyClick), for: .touchUpInside)
        return btn
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([nameLabel,rightImgV,rightLabel,rightBtn])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.right.equalTo(rightLabel.snp.left).offset(-10)
        }
        rightImgV.snp.makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(16, 16))
            make.right.equalTo(rightBtn.snp.left).offset(-4)
            make.centerY.equalToSuperview()
        }
        rightLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(rightBtn.snp.left).offset(-4)
            make.height.equalTo(17)
        }
        rightBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(16, 16))
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    func setCell(_ entity : EXMyInfoEntity){
        self.entity = entity
        nameLabel.text = entity.name
        rightImgV.isHidden = entity.rightImgName == ""
        rightLabel.isHidden = !rightImgV.isHidden
        rightBtn.isHidden = entity.rightBtnBool
        if entity.rightBtnBool == false{
            rightLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(rightBtn.snp.left).offset(-4)
                make.height.equalTo(17)
            }
            if entity.name == "UID" {
                rightBtn.setImage(EXKitBundle.image(named: "trade_icon_compared"), for: .normal)
                rightBtn.snp.remakeConstraints { (make) in
                    make.height.equalTo(16)
                    make.width.equalTo(16)
                    make.right.equalToSuperview().offset(-16)
                    make.centerY.equalToSuperview()
                }
            }else{
                rightBtn.setImage(EXKitBundle.image(named: "public_positions_arrow_right"), for: .normal)
                rightBtn.backgroundColor = .clear
                rightBtn.snp.remakeConstraints { (make) in
                    make.size.equalTo(CGSize(width: 16, height: 16))
                    make.right.equalToSuperview().offset(-16)
                    make.centerY.equalToSuperview()
                }
            }
            
        }else{
            rightLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-16)
                make.height.equalTo(17)
            }
        }
        if entity.rightImgName != ""{
            rightImgV.image = UIImage.themeImageNamed(imageName: "headportrait1")
        }else{
            self.rightLabel.text = entity.rightInfo
        }
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
    
    @objc func  copyClick(){
        if self.entity.name == "UID" {
            let past = UIPasteboard.general
            past.string = UserInfoEntity.sharedInstance().uid
            EXAlert.showSuccess(msg: "personal_Center_text2".localized())
        }
    }
}
