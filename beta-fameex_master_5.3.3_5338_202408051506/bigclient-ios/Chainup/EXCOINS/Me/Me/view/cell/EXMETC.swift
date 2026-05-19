//
//  EXMETC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXMETC: UITableViewCell {
    var entity = EXMEEntity() {
        didSet{
            setCell()
        }
    }
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.contentMode = UIView.ContentMode.scaleAspectFit
        return imgV
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    lazy var detailTipLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = "personal_Center_text4".localized()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.textAlignment = .right
        return label
    }()
    lazy var rightImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.contentMode = .scaleAspectFit
        imgV.image = EXKitBundle.image(named: "public_positions_arrow_right")
        imgV.layoutIfNeeded()
        return imgV
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var redView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.extSetCornerRadius(3)
        view.backgroundColor = .Ex.fall1
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([imgV,nameLabel,detailTipLabel,rightImgV,lineV,redView])
        imgV.snp.makeConstraints { (make) in
            make.height.width.equalTo(16)
            make.left.equalToSuperview().offset(17)
            make.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imgV.snp.right).offset(14)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        detailTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(14)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-35)
        }
        rightImgV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.size.equalTo(CGSizeMake(16, 16))
            make.centerY.equalToSuperview()
        }
        lineV.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalTo(imgV)
        }
        redView.snp.makeConstraints { (make) in
            make.height.width.equalTo(6)
            make.centerY.equalToSuperview()
            make.right.equalTo(rightImgV.snp.left).offset(-7)
        }
    }
    
    func setCell(){
        nameLabel.text = self.entity.name
        lineV.isHidden = true
        imgV.image = UIImage.themeImageNamed(imageName: entity.imgName)
        redView.isHidden = self.entity.unRead
        detailTipLabel.text = self.entity.detail
        detailTipLabel.isHidden = !self.entity.tip
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
