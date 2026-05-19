//
//  EXSwapSettingTC.swift
//  Chainup
//
//  Created by cwd on 2022/11/13.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit


class EXSwapSettingTC: UITableViewCell {
    typealias OnValueChangeCallback = (Bool) -> ()
    var onValueChangeCallback : OnValueChangeCallback?
    
    var setItem = EXSContractSetItem(){
        didSet{
            let type = setItem.type
            nameLabel.text = setItem.title
            nameDescLabel.text = setItem.titleDes
            typeLabel.text = setItem.contentValue
            if type == .confirmAgain {
                self.showSwitchV(true)
            }else{
                self.showSwitchV(false)
            }
            switchV.isSelected = setItem.open
//            nameDescLabel.isHidden = !(type == .time)
            if type == .time {
                nameDescLabel.isHidden = false
            }else{
                nameDescLabel.isHidden = true
            }
            
            
        }
    }
    
   
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.ext_SetCell()
        self.contentView.exs_addSubViews([nameLabel,nameDescLabel,typeLabel,arrowView,switchV])
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    //MARK: lazy
    /// 选项名称 English: /Option Name
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.Ex.Harmony(size: 16, weight: .medium), textColor: UIColor.Ex.text1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var nameDescLabel:UILabel = {
        let label = UILabel(text: nil, font: UIFont.Ex.Harmony(size: 12, weight: .medium), textColor: UIColor.Ex.text2, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    /// 内容 English: /Content
    lazy var typeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.Ex.Harmony(size: 14, weight: .medium), textColor: UIColor.Ex.text2, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var arrowView: UIImageView = { //contract_positions_thedropdown
        let arrow = UIImageView(image: UIImage.exs_themeImageNamed(imageName: "contract_positions_thedropdown"))
        arrow.ext_UseAutoLayout()
        arrow.contentMode = .scaleAspectFit
        return arrow
    }()
    
//    lazy var switchV :UIButton = {
//        let v = UIButton()
//        v.addTarget(self, action: #selector(openClose(btn:)), for: .touchUpInside)
//        v.imageView?.contentMode = .scaleAspectFit
//        v.setImage(UIImage.exs_themeImageNamed(imageName: "public_switch_close"), for: .normal)
//        v.setImage(UIImage.exs_themeImageNamed(imageName: "contract_open"), for: .selected)
//        v.isHidden = true
//        return v
//    }()
    //开关 English: switch
    lazy var switchV : UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.clear
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_switch_close_big"), for: .normal)
        btn.setImage(UIImage.svg_themeImageNamed(imageName: "public_switch_open_big"), for: .selected)
        btn.addTarget(self, action: #selector(openClose(btn:)), for: .touchUpInside)
        return btn
    }()
    
    
}

extension EXSwapSettingTC{
    
    
    func showSwitchV(_ status : Bool) {
        if status {
            switchV.isHidden = false
            arrowView.isHidden = true
            typeLabel.isHidden = true
        } else {
            switchV.isHidden = true
            arrowView.isHidden = false
            typeLabel.isHidden = false
        }
    }
    
    
    
    
    @objc func openClose(btn: UIButton){
        btn.isSelected = !btn.isSelected
        self.onValueChangeCallback?(btn.isSelected)
    }
    
    
    private func initLayout() {
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(19)
            make.top.equalToSuperview().offset(16.5)
            
        }
        nameDescLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
        arrowView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(15)
            make.height.equalTo(20)
        }
        typeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(15)
            make.right.equalTo(arrowView.snp.left).offset(-4)
            make.centerY.equalToSuperview()
            make.height.equalTo(16)
        }
        switchV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
}

