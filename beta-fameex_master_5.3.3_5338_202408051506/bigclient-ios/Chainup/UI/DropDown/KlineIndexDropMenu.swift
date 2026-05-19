//
//  KlineIndexDropMenu.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class KlineIndexDropMenu: UIView {
    
    var masterMenus:[EXDropMenuBtn]=[]
    var assistantMenus:[EXDropMenuBtn]=[]

    typealias MasterAlgorithmBlock = (MasterAlgorithmType) -> ()
    var masterTypeChange : MasterAlgorithmBlock?
    typealias AssistantAlgorithmBlock = (AssistantAlgorithmType) -> ()
    var assistantTypeChange : AssistantAlgorithmBlock?
    
    lazy var mainLabel:UILabel = {
        var title = UILabel()
        title.textColor = UIColor.ThemekLine.labcolorLite
        title.text = "kline_action_main".localized()
        title.font = UIFont.ThemeFont.SecondaryRegular
        return title
    }()

    lazy var subLabel:UILabel = {
        var title = UILabel()
        title.textColor = UIColor.ThemekLine.labcolorLite
        title.text = "kline_action_assistant".localized()
        title.font = UIFont.ThemeFont.SecondaryRegular
        return title
    }()
    
    lazy var mainContainer :UIStackView = {
        var container = UIStackView()
        container.axis = .horizontal
        container.spacing = 10
        container.backgroundColor = UIColor.ThemekLine.viewBg
        return container
    }()
    
    lazy var subContainer :UIStackView = {
        var container = UIStackView()
        container.axis = .horizontal
        container.spacing = 10
        container.backgroundColor = UIColor.ThemekLine.viewBg
        return container
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemekLine.viewBg
        configMenus()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configMenus()
    }
    
    func configMenus() {
        self.clipsToBounds = true
        self.addSubview(mainLabel)
        self.addSubview(subLabel)
        self.addSubview(mainContainer)
        self.addSubview(subContainer)
        mainLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(20)
        }
        subLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        mainContainer.snp.makeConstraints { (make) in
            make.left.equalTo(mainLabel.snp.right).offset(14)
            make.centerY.equalTo(mainLabel.snp.centerY)
        }
        subContainer.snp.makeConstraints { (make) in
            make.left.equalTo(mainContainer.snp.left)
            make.centerY.equalTo(subLabel.snp.centerY)
        }
        
        let mainMenus:[String] = ["MA","BOLL"]
        let subMenus:[String] = ["MACD","KDJ","RSI","WR"]
        
        for (idx, scale) in mainMenus.enumerated() {
            let showScale = scale
            let scaleView = EXDropMenuBtn()
            scaleView.setTitle(showScale.localized(), for: .normal)
            scaleView.addTarget(self, action: #selector(mainAlgorithmAction(_:)), for: .touchUpInside)
            scaleView.tag = idx
            scaleView.isSelected = false
            mainContainer.addArrangedSubview(scaleView)

            scaleView.snp.makeConstraints { (make) in
                make.width.equalTo(55)
                make.height.equalTo(22)
            }
            masterMenus.append(scaleView)
        }
        
        for (idx, scale) in subMenus.enumerated() {
            let showScale = scale
            let scaleView = EXDropMenuBtn()
            scaleView.setTitle(showScale.localized(), for: .normal)
            scaleView.addTarget(self, action: #selector(assistantAlgorithmAction(_:)), for: .touchUpInside)
            scaleView.tag = idx
            subContainer.addArrangedSubview(scaleView)
            assistantMenus.append(scaleView)

            scaleView.snp.makeConstraints { (make) in
                make.width.equalTo(55)
                make.height.equalTo(22)
            }
        }
    }
    
    func updateMasterType(masterType:MasterAlgorithmType,assistantType:AssistantAlgorithmType) {
        if masterType != .none, masterType != .Hides,masterMenus.count > masterType.rawValue - 1{
            let btn = masterMenus[masterType.rawValue - 1]
            btn.isSelected = true
        }
        
        if assistantType != .none, assistantType != .Hides,assistantMenus.count > assistantType.rawValue - 1 {
            let btn = assistantMenus[assistantType.rawValue - 1]
            btn.isSelected = true
        }
    }
    
    @objc func mainAlgorithmAction(_ sender: EXDropMenuBtn) {
        for (idx,btn) in masterMenus.enumerated() {
            if btn == sender {
                sender.isSelected = !sender.isSelected
                let type = MasterAlgorithmType.init(rawValue: idx + 1)
                if let updateType = type {
                    if sender.isSelected {
                        masterTypeChange?(updateType)
                    }else {
                        masterTypeChange?(.Hides)
                    }
                }
            }else {
                btn.isSelected = false
            }
        }
    }
    
    @objc func assistantAlgorithmAction(_ sender: EXDropMenuBtn) {
        
        for (idx,btn) in assistantMenus.enumerated() {
            if btn == sender {
                sender.isSelected = !sender.isSelected
                let type = AssistantAlgorithmType.init(rawValue: idx + 1)
                if let updateType = type {
                    if sender.isSelected {
                        assistantTypeChange?(updateType)
                    }else {
                        assistantTypeChange?(.Hides)
                    }
                }
            }else {
                btn.isSelected = false
            }
        }
    }
    
    static func getHeight()->CGFloat {
        return 94
    }
}

