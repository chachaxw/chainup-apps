//
//  EXCoinWithDrawEmptyAddress.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXCoinWithDrawEmptyAddress: NibBaseView {
    @IBOutlet var withdrawAddress: EXWithDrawAddressField!
    
    typealias QRActionCallback = ()->()
    typealias AddressBookCallback = ()->()
    var onQRScanCallback:QRActionCallback?
    var onAddressBookCallback:AddressBookCallback?
    
    override func onCreate() {
        withdrawAddress.setTitle(title: "withdraw_text_address".localized())
        withdrawAddress.setPlaceHolder(placeHolder: "withdraw_tip_addressEmpty".localized())
        withdrawAddress.scanBtn.addTarget(self, action: #selector(scanDidTapped), for: .touchUpInside)
        withdrawAddress.addressBtn.addTarget(self, action: #selector(addressDidTapped), for: .touchUpInside)
        withdrawAddress.addressBtn.setImage(UIImage.themeImageNamed(imageName: "assets_address"), for: .normal)
    }
    
    @objc func scanDidTapped(){
        onQRScanCallback?()
    }
    
    @objc func addressDidTapped() {
        onAddressBookCallback?()
    }
    
    func setAddress(_ text:String) {
        withdrawAddress.setText(text: text)
        withdrawAddress.input.sendActions(for: .valueChanged)
    }
    
    func setEmpty() {
        withdrawAddress.setText(text: "")
    }
    
    func setWithdrawSingleScanMode() {
        withdrawAddress.onlyScan()
    }
}
