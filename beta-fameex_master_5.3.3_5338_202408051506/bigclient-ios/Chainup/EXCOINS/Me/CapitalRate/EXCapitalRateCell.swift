//
//  EXCapitalRateCell.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/15.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXCapitalRateCell: UITableViewCell,EXReusableView {
    
    var entity = EXSecurityEntity()
    
    typealias OnValueChangeCallback = (Bool) -> ()
    var onValueChangeCallback : OnValueChangeCallback?
    
    lazy var nameLabel : UILabel = {
        let label = UILabel(font: .Ex.regular(16), textColor: .Ex.text1)
        label.extUseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var switchV : EXSwitchV6 = {
        let view = EXSwitchV6(frame: .zero, style: .large)
        view.extUseAutoLayout()
        view.layoutIfNeeded()
        view.onValueChangeCallback = {[weak self] op in
            guard let mySelf = self else{return}
            self?.entity.switchOn = op
            mySelf.onValueChangeCallback?(op)
        }
        return view
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = .Ex.fill4
        return view
    }()
    
    lazy var infoLabel : UILabel = {
        let label = UILabel(font: .Ex.regular(12), textColor: .Ex.text2)
        label.extUseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extSetCell(isRemoveSelectedBackgroundView: true)
        contentView.addSubViews([nameLabel,switchV,lineV,infoLabel])
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(28)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-45)
        }
        switchV.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-15)
        }
        lineV.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(1)
        }
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineV.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    
    func setCell(_ entity : EXSecurityEntity){
        self.entity = entity
        nameLabel.text = entity.name
        infoLabel.text = entity.info
        switchV.isOn = entity.switchOn
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
