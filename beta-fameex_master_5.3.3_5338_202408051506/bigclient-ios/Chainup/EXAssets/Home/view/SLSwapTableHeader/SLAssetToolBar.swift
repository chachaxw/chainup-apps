//
//  SLAssetToolBar.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2020/1/8.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import Foundation

class SLAssetToolBar : UIView {
    lazy var containerView : UIStackView = {
        let v = UIStackView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 84))
        return v
    }()
    var iconBtnsContainer:[EXTopIconBtn] = []
    var toolbarItems:[EXAssetToolBarItem] = []
    
    typealias ToolBarActionCallback = (EXAssetToolBarAction) -> ()
    var onToolBarSelected:ToolBarActionCallback?
    
    func bindToolBarItems(_ items:[EXAssetToolBarItem]) {
        if iconBtnsContainer.count > 0 {
            self.containerView.removeAllArrangedSubviews()
            self.iconBtnsContainer.removeAll()
        }
        self.toolbarItems = items

        for (idx,item) in items.enumerated() {
            let iconBtn = EXTopIconBtn()
            iconBtn.onTapGesture = {[weak self] in
                self?.itemDidSelect(idx)
            }
            iconBtn.titleLabel.text = item.title
            iconBtn.topIcon.image = UIImage.svgImage(named: item.iconImageName,version: .five)
            //UIImage.themeImageNamed(imageName:item.iconImageName)
            self.containerView.addArrangedSubview(iconBtn)
            iconBtnsContainer.append(iconBtn)
            if item.title == "contract_swap_gift".localized() {
                iconBtn.newLabel.isHidden = false
            }
        }
    }
    
    func itemDidSelect(_ idx:Int) {
        let item = self.toolbarItems[idx]
        self.onToolBarSelected?(item.action)
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
