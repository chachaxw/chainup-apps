//
//  RegionTC.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/17.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

class RegionTC: UITableViewCell {
    
    //name
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.bodyRegular()
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    //coding
    lazy var codeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.bodyRegular()
        label.textAlignment = .right
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        self.backgroundColor = UIColor.ThemeView.bg
        contentView.addSubViews([nameLabel,codeLabel,lineV])
        addConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.width = SCREEN_WIDTH
    }
    
    func addConstraints() {
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(11)
            make.centerY.equalToSuperview()
            make.height.equalTo(16)
            make.right.equalTo(codeLabel.snp.left).offset(-10)
        }
        codeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(13)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(100)
        }
        lineV.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(0.5)
        }
    }
    
    func setCellWithEntity(_ entity : RegionEntity){
        if BasicParameter.isHan(){
            if entity.cnName == "@"{
                
NameLabel. text="All"
            }else{
                nameLabel.text = entity.cnName

            }
        }else{
            if entity.enName == "@"{
                
                nameLabel.text = "All"
            }else{
                nameLabel.text = entity.enName

            }
        }
        if entity.enName == "@" || entity.cnName == "@"{
        
            codeLabel.text = ""
        }else{
            codeLabel.text = entity.dialingCode

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

}

