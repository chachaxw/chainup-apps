//
//  EXHorizonAssistantMenu.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXHorizonAssistantMenu: NibBaseView {
    
    @IBOutlet var menus: [CMLocalizedButton]!
    var currentType:AssistantAlgorithmType = .Hides
    typealias AssistantAlogithmChangeBlock = (AssistantAlgorithmType) -> ()
    var assistantAlgorithmCallback : AssistantAlogithmChangeBlock?
    @IBOutlet var hideBtn: CMLocalizedButton!
    
    override func onCreate() {
        self.loadBtnStyle()
        self.selectOn(type: currentType)
        hideBtn.setImage(UIImage.themeImageNamed(imageName: "visible_highlight"), for: .normal)
        hideBtn.setImage(UIImage.themeImageNamed(imageName: "hide_lightcolor"), for: .selected)

    }
    
    func loadBtnStyle() {
        for (idx,btn) in menus.enumerated() {
            if idx == 0 {
                btn.titleLabel?.minimumRegular()
            }else {
                btn.titleLabel?.secondaryRegular()
            }
            
            if idx == 0 {
                btn.setTitleColor(UIColor.ThemekLine.labcolorDark, for: .normal)
                btn.setTitleColor(UIColor.ThemekLine.labcolorDark, for: .selected)
            }else {
                btn.setTitleColor(UIColor.ThemekLine.labcolorMedium, for: .normal)
                btn.setTitleColor(UIColor.ThemekLine.labcolorLite, for: .selected)
            }
        }
    }
    
    func selectOn(type:AssistantAlgorithmType) {
        currentType = type
        for(idx,btn) in menus.enumerated() {
            if idx == type.rawValue {
                btn.isSelected = true
                btn.titleLabel?.font = UIFont.ThemeFont.SecondaryBold
            }else {
                btn.isSelected = false
                btn.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
            }
        }
    }
    
    @IBAction func didSelectAlgorithm(_ sender: UIButton) {
        let type = AssistantAlgorithmType.init(rawValue: sender.tag)
        if let selectedType = type, selectedType != currentType {
            self.selectOn(type: selectedType)
            currentType = selectedType
            self.assistantAlgorithmCallback?(selectedType)
        }
    }
}
