//
//  EXNavigationBar.swift
//  Chainup
//
//  Created by wangdong on 2023/9/17.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
import Swap
class EXAccountNavigationBar: EXCustomBaseView {
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    lazy var leftButton: RepeatButton = {
        let v = RepeatButton(type: .custom)
//        v.setImage(EXKitBundle.image(named: "public_close"), for: .normal)
        v.isHidden = true
        v.setImage(UIImage.exs_themeImageNamed(imageName:"public_return"), for: .normal)
        v.addTarget(self, action: #selector(onLeftButtonAction), for: .touchUpInside)
        return v
    }()
    
    
    lazy var rightButton: RepeatButton = {
        let v = RepeatButton(type: .custom)
        v.setImage(EXKitBundle.image(named: "public_close"), for: .normal)
        v.isHidden = true
        v.addTarget(self, action: #selector(onLeftButtonAction), for: .touchUpInside)
        return v
    }()
    
    lazy var titleLabel: EXLabel = {
        let v = EXLabel()
        v.isHideEdgeWithEmptyText = true
        v.edgeInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        v.font = .Ex.medium(18)
        v.textColor = .Ex.text1
        v.textAlignment = .center
        return v
    }()

    
    func setRightClose() {
        self.leftButton.isHidden = true
        self.rightButton.isHidden = false
    }
    func setLeftClose() {
        self.leftButton.isHidden = false
        self.rightButton.isHidden = true
    }
    func topShowAllBtn() {
        self.leftButton.isHidden = false
        self.rightButton.isHidden = false
    }
    
    override func setSubView() {
        self.backgroundColor = .Ex.fill2
        self.addSubViews([leftButton,rightButton, titleLabel])
        self.leftButton.enlargeInteractionEdge(with: 6)
        self.rightButton.enlargeInteractionEdge(with: 6)
        
        self.leftButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(CGSizeMake(22, 22))
        }
        self.rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(CGSizeMake(22, 22))
        }
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.leftButton)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
    }
    
    
    @objc func onLeftButtonAction() {
        onNavigationBarButtonAction(dismissTopVC: false)
    }
    @objc func onRightButtonAction() {
        onNavigationBarButtonAction(dismissTopVC: true)
    }
    @objc func onNavigationBarButtonAction(dismissTopVC:Bool) {
        guard let targetVc = yy_viewController else { return }
        if let navigationControll = targetVc.navigationController , navigationControll.viewControllers.count > 1 {
            navigationControll.popViewController(animated: true)
        }
        else if targetVc.presentingViewController != nil {
            targetVc.dismiss(animated: true, completion: nil)
        }
//        BusinessTools.logoutNet(dismissTopVC: dismissTopVC)
    }
}


