//
//  EXAlgorithmDropView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXAlgorithmDropView: NibBaseView {
    
    @IBOutlet var masterTitleLabel: CMLocalizedLabel!
    @IBOutlet var assistantTitleLabel: CMLocalizedLabel!
    @IBOutlet var masterMenus: [EXTextButton]!
    @IBOutlet var assistantMenus: [EXTextButton]!
    
    @IBOutlet var masterHideBtn: EXTextButton!
    @IBOutlet var assistantHideBtn: EXTextButton!
    
    
    typealias MasterAlgorithmBlock = (MasterAlgorithmType) -> ()
    var masterTypeChange : MasterAlgorithmBlock?
    typealias AssistantAlgorithmBlock = (AssistantAlgorithmType) -> ()
    var assistantTypeChange : AssistantAlgorithmBlock?
    
    
    
    var menuModel = EXMenuSelectionModel.init() {
        didSet {
            for (idx,btn) in masterMenus.enumerated() {
                let type = MasterAlgorithmType.init(rawValue: idx + 1)
                if menuModel.masterType == type {
                    btn.isSelected = true
                }else {
                    btn.isSelected = false
                }
            }
            for (idx,btn) in assistantMenus.enumerated() {
                let type = AssistantAlgorithmType.init(rawValue: idx + 1)
                if menuModel.assitantType == type {
                    btn.isSelected = true
                }else {
                    btn.isSelected = false
                }
            }
        }
    }

    override func onCreate() {
        masterTitleLabel.text = "kline_action_main".localized()
        assistantTitleLabel.text = "kline_action_assistant".localized()
        masterHideBtn.color = UIColor.clear
        assistantHideBtn.color = UIColor.clear
        masterHideBtn.setImage(UIImage.themeImageNamed(imageName: "visible_highlight"), for: .normal)
        masterHideBtn.setImage(UIImage.themeImageNamed(imageName: "hide_lightcolor"), for: .selected)

        assistantHideBtn.setImage(UIImage.themeImageNamed(imageName: "visible_highlight"), for: .normal)
        assistantHideBtn.setImage(UIImage.themeImageNamed(imageName: "hide_lightcolor"), for: .selected)

        for (idx,btn) in masterMenus.enumerated() {
            if EXKlineEnum.masterMenuTitles().count > idx {
                btn.color = UIColor.clear
                btn .setTitle(EXKlineEnum.masterMenuTitles()[idx], for: .normal)
                btn.titleLabel?.secondaryRegular()
                btn.supportCheckHighlight = true
                btn.isSelected = false
                btn.highlighTextColor = UIColor.ThemekLine.labcolorHighlight
                btn.normalTextColor = UIColor.ThemekLine.labcolorLite
            }
        }
        
        for (idx,btn) in assistantMenus.enumerated() {
            if EXKlineEnum.assistantTitles().count > idx {
                btn.color = UIColor.clear
                btn .setTitle(EXKlineEnum.assistantTitles()[idx], for: .normal)
                btn.titleLabel?.secondaryRegular()
                btn.cornerRadius = 1.5
                btn.supportCheckHighlight = true
                btn.isSelected = false
                btn.highlighTextColor = UIColor.ThemekLine.labcolorHighlight
                btn.normalTextColor = UIColor.ThemekLine.labcolorLite
            }
        }
        if let btn = masterMenus.first {
            btn.isSelected = true 
        }
    }
    
    @IBAction func mainAlgorithmAction(_ sender: EXTextButton) {
        for (idx,btn) in masterMenus.enumerated() {
            if btn == sender {
                if sender.isSelected {
                    return
                }
                let type = MasterAlgorithmType.init(rawValue: idx + 1)
                if let updateType = type {
                    masterTypeChange?(updateType)
                }
                sender.isSelected = !sender.isSelected
            }else {
                btn.isSelected = false
            }
        }
    }
    
    @IBAction func assistantAlgorithmAction(_ sender: EXTextButton) {
        
        for (idx,btn) in assistantMenus.enumerated() {
            if btn == sender {
                if sender.isSelected {
                    return
                }
                let type = AssistantAlgorithmType.init(rawValue: idx + 1)
                if let updateType = type {
                    assistantTypeChange?(updateType)
                }
                
                sender.isSelected = !sender.isSelected
            }else {
                btn.isSelected = false
            }
        }
    }
    
}
