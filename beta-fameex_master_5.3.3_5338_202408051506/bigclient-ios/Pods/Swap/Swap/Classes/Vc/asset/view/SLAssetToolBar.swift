//
//  SLAssetToolBar.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/1/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Foundation
import EXKit
public enum EXContractAssetToolBarAction {
    case none
    case co_transfer //划转 English: Transfer
    case co_journalAccount //流水 English: running water
    case co_swapGift //合约赠金 English: Contract bonus
    case co_ProfitRecord //合约盈亏分析 Contract profit and loss analysis
}

class EXContractAssetToolBarItem:NSObject {
    var title :String = ""
    var iconImageName :String = ""
    var action :EXContractAssetToolBarAction = .none
    
   static func getSwapToolbars()->[EXContractAssetToolBarItem] {
        let itemA = EXContractAssetToolBarItem()
        itemA.action = .co_transfer
        itemA.title = "assets_action_transfer".ex_localized()
        itemA.iconImageName = "assets_transfer"
        let itemB = EXContractAssetToolBarItem()
        itemB.action = .co_journalAccount
        itemB.title = "cp_extra_text143".ex_localized()
        itemB.iconImageName = "assets_capitalflow"
       if EXSwapPrivateConfig.shared.coCouponSwitchUrl != "" && EXSwapPrivateConfig.shared.coCouponSwitchUrlStatus == "1" {
            let itemC = EXContractAssetToolBarItem()
            itemC.action = .co_swapGift
            itemC.title = "contract_swap_gift".ex_localized()
            itemC.iconImageName = "assets_contractbill"
            return [itemA,itemB,itemC]
        }
        return [itemA,itemB]
    }
    
    
}



class SLAssetToolBar : UIView {
    lazy var containerView : UIStackView = {
        let v = UIStackView(frame: CGRect.init(x: 0, y: 0, width: EXSCREEN_WIDTH, height: 84))
        return v
    }()
    var iconBtnsContainer:[EXSCoTopIconBtn] = []
    var toolbarItems:[EXContractAssetToolBarItem] = []
    
    typealias ToolBarActionCallback = (EXContractAssetToolBarItem) -> ()
    var onToolBarSelected:ToolBarActionCallback?
    func bindToolBarItems(_ items:[EXContractAssetToolBarItem]) {
        if iconBtnsContainer.count > 0 {
            self.containerView.removeAllArrangedSubviews()
            self.iconBtnsContainer.removeAll()
        }
        self.toolbarItems = items

        for (idx,item) in items.enumerated() {
            let iconBtn = EXSCoTopIconBtn()
            iconBtn.onTapGesture = {[weak self] in
                self?.itemDidSelect(idx)
            }
            iconBtn.titleLabel.text = item.title
            iconBtn.topIcon.image = UIImage.svg_themeImageNamed(imageName:item.iconImageName)
            self.containerView.addArrangedSubview(iconBtn)
            iconBtnsContainer.append(iconBtn)
            if item.action == .co_swapGift {
                iconBtn.newLabel.isHidden = false
            }
        }
    }
    
    func itemDidSelect(_ idx:Int) {
        let item = self.toolbarItems[idx]
        self.onToolBarSelected?(item)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        containerView.axis = .horizontal
        containerView.distribution = .fillEqually
        self.addSubview(containerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

