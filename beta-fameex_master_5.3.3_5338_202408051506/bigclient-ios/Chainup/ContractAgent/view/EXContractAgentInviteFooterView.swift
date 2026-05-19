//
//  EXContractAgentInviteFooterView.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXContractAgentInviteFooterView: UIView {
    
    lazy var container:UIStackView = {
        let stacker :UIStackView = UIStackView.init()
        stacker.axis = .horizontal
        return stacker
    }()
    
    lazy var redpacktShare:EXButton = {
        let btn = EXButton.init(type: .custom)
        btn.setTitle("coAgent_text_redpackInvite".localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        btn.setFont(UIFont.ThemeFont.HeadBold)
        return btn
    }()
    
    lazy var inviteFriendBtn:EXButton = {
        let btn = EXButton.init(type: .custom)
        btn.setTitle("coAgent_text_friendInvite".localized(), for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setFont(UIFont.ThemeFont.HeadBold)
        return btn
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(container)
        container.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(44)
        }
        redpacktShare.color = UIColor.ThemeTab.bg
        container.addArrangedSubview(redpacktShare)
        container.addArrangedSubview(inviteFriendBtn)
        
        let redWidth = SCREEN_WIDTH*0.344
        let inviteWidth = SCREEN_WIDTH - redWidth
        redpacktShare.snp.makeConstraints { (make) in
            make.width.equalTo(redWidth)
        }
        inviteFriendBtn.snp.makeConstraints { (make) in
            make.width.equalTo(inviteWidth)
        }
        
    }
    
    func hideRedPackBtn() {
        redpacktShare.isHidden = true
        inviteFriendBtn.snp.makeConstraints { (make) in
            make.width.equalTo(SCREEN_WIDTH)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
