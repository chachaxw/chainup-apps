//
//  EXBindingTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXBindingBaseTC: UITableViewCell {
    
    typealias OnValueChangeCallback = (Int , Bool) -> ()
    var valueChangeCallback : OnValueChangeCallback?
    
    lazy var infoLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.numberOfLines = 0
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var switchV : EXSwitchV6 = {
        let view = EXSwitchV6(frame: .zero, style: .large)
        view.extUseAutoLayout()
        view.layoutIfNeeded()
        view.onValueChangeCallback = {[weak self] b in
            guard let mySelf = self else{return}
            mySelf.valueChangeCallback?(mySelf.tag , b)
        }
        return view
    }()
    
    lazy var rightLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.textAlignment = .right
        return label
    }()
    
    lazy var rightImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = EXKitBundle.image(named: "public_positions_arrow_right")
        imgV.contentMode = .scaleAspectFit
        return imgV
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([infoLabel,rightLabel,switchV,rightImgV,lineV])
        switchV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        infoLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(SCREEN_WIDTH * 0.7)
            make.top.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
        }
        switchV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(rightImgV.snp.left).offset(-5)
            make.centerY.equalToSuperview()
            make.left.equalTo(infoLabel.snp.right).offset(10)
            make.height.equalTo(17)
        }
        rightImgV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(10)
            make.width.equalTo(7)
        }
        lineV.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.left.equalTo(15)
            make.height.equalTo(0.5)
        }
    }
    
    func setCell(_ entity : EXBindingBaseEntity){
        switchV.isHidden = entity.type == "1"
        rightLabel.isHidden = !switchV.isHidden
        rightImgV.isHidden = rightLabel.isHidden
        
        infoLabel.text = entity.name
        if entity.type == "0"{
            switchV.isOn = entity.switchType != "0"
        }else{
            rightLabel.text = entity.rightName
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
