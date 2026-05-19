//
//  EXSecurityTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import RxSwift
class EXSecurityTC: UITableViewCell {
    
    var entity = EXSecurityEntity()
    
    typealias OnValueChangeCallback = (Bool , EXSecurityEntity) -> ()
    var onValueChangeCallback : OnValueChangeCallback?
    var onFundPasswordCallback : EXComIntBlock?

    lazy var nameLabel : UILabel = {
        let label = UILabel(font: .Ex.medium(16), textColor: .Ex.text1)
        label.extUseAutoLayout()
        return label
    }()
    
    lazy var desLabel : UILabel = {
        let label = UILabel(font: .Ex.regular(12), textColor: .Ex.text2)
        label.extUseAutoLayout()
        label.numberOfLines = 0
        return label
    }()

    lazy var infoLabel : UILabel = {
        let label = UILabel(font: .Ex.medium(12), textColor: .Ex.text2)
        label.extUseAutoLayout()
        return label
    }()
    
    lazy var unBlindLabel: RepeatButton = {
        let btn = RepeatButton()
        btn.extUseAutoLayout()
        btn.setTitle("safety_fundsPass_Unbind".localized(), for: .normal)
        btn.setTitleColor(.Ex.text2, for: .normal)
        btn.titleLabel?.font = .Ex.medium(12)
        btn.addTarget(self, action: #selector(unbind), for: .touchUpInside)
        return btn
    }()
    
    lazy var rightBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.extUseAutoLayout()
        btn.setImage(EXKitBundle.image(named: "public_positions_arrow_right"), for: .normal)
        return btn
    }()
    
    lazy var switchV : EXSwitchV6 = {
        let view = EXSwitchV6(frame: .zero, style: .large)
        view.extUseAutoLayout()
        view.layoutIfNeeded()
        view.onValueChangeCallback = {[weak self] b in
            guard let mySelf = self else{return}
            mySelf.onValueChangeCallback?(b , mySelf.entity)
        }
        return view
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = .Ex.fill4
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([nameLabel,desLabel,unBlindLabel,infoLabel,rightBtn,switchV,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        desLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-52)
            make.bottom.equalToSuperview().offset(-12.5)
        }
        
        rightBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(16)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(rightBtn.snp.left).offset(-8)
        }
        
        unBlindLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(infoLabel.snp.left).offset(-8)
        }
        
        switchV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        lineV.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(1)
        }
    }
    
    func setCell(_ entity : EXSecurityEntity){
        self.entity = entity
        infoLabel.isHidden = entity.info == ""
        switchV.isHidden = !infoLabel.isHidden
        rightBtn.isHidden = infoLabel.isHidden
        desLabel.isHidden = entity.desc.isEmpty
        desLabel.text = entity.desc
        nameLabel.text = entity.name
        infoLabel.text = entity.info
        switchV.isOn = entity.switchOn
        if entity.type == .gooleAuth || entity.type == .moneyPassWord {
            lineV.isHidden = false
        }else{
            lineV.isHidden = true
        }
        unBlindLabel.isHidden = !entity.showUnbind
        if entity.type == .whiteList {
            desLabel.isHidden = false
            nameLabel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(12.5)
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-52)
                make.height.equalTo(19)
            }
            desLabel.snp.makeConstraints { (make) in
                make.top.equalTo(nameLabel.snp.bottom).offset(4)
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-52)
                make.bottom.equalToSuperview().offset(-12.5)
            }
        }else{
            desLabel.isHidden = true
            nameLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-52)
                make.top.equalToSuperview().offset(16.5)
                make.bottom.equalToSuperview().offset(-16.5)

            }
        }
    }
    
    
    @objc func unbind(){
        self.onFundPasswordCallback?(0)
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
