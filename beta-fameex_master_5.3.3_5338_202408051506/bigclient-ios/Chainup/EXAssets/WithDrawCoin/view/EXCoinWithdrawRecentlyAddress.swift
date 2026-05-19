//
//  EXCoinWithdrawRecentlyAddress.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXCoinWithdrawRecentlyAddress: NibBaseView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var useNewBtn: UIButton!
    @IBOutlet var bgBtn: UIButton!
    @IBOutlet var addressVerticalView: EXAddressVerticalView!
    
    typealias TapCallback = () -> ()
    var onTapCallback:TapCallback?
    
    override func onCreate() {
        
        titleLabel.text = "withdraw_text_address".localized()
        titleLabel.textColor = UIColor.ThemeLabel.colorMedium
        useNewBtn.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
        useNewBtn.setTitle("withdraw_action_newAddress".localized(), for: .normal)
        useNewBtn.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        
        addressVerticalView.checkIcon.image = EXKitBundle.image(named: "public_positions_arrow_right")
        addressVerticalView.checkIcon.contentMode = .scaleAspectFit
        self.bgBtn.addTarget(self, action: #selector(didTapped), for: .touchUpInside)
    }
    
    @objc func didTapped() {
        onTapCallback?()
    }
    
    func updateAddress(_ itemModel:AddressItem) {
        let coinAddress = itemModel.address
        let remark = itemModel.label
        if let _ = coinAddress.range(of: "_") {
            let addressAry = coinAddress.components(separatedBy: "_")
            if addressAry.count == 2 {
                addressVerticalView.addressLabel.text = addressAry[0]
                addressVerticalView.tagLabel.text = addressAry[1]
            }
        }else {
            addressVerticalView.hideTagLabel()
            addressVerticalView.addressLabel.text = coinAddress
        }
        addressVerticalView.remarkLabel.text = remark
        
    }
    
}
