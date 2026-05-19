//
//  EXAboutTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSBaseInfoTC: UITableViewCell {
 //20 + 16 * 2 
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.HeadRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var infoLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.BodyMedium
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
//    lazy var lineV : UIView = {
//        let view = UIView()
//        view.ext_UseAutoLayout()
//        view.backgroundColor = UIColor.ThemeView.seperator
//        return view
//    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.ext_SetCell()
        contentView.exs_addSubViews([nameLabel,infoLabel])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(180)
        }
        infoLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(150)
        }
//        lineV.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(15)
//            make.right.bottom.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
    }
    
    func setCell(name:String,info:String){
        nameLabel.text = name
        infoLabel.text = info
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
