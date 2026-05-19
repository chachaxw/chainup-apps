//
//  EXAccountTransferHeaderView.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXAccountTransferHeaderView: NibBaseView {
    
    @IBOutlet var transferIcon: UIImageView!
    @IBOutlet var exchangeBtn: UIButton!
    @IBOutlet var fromTitle: UILabel!
    @IBOutlet var toTitle: UILabel!
    @IBOutlet var leftView: UIView!
    @IBOutlet var container: UIStackView!
    
    @IBOutlet var fromAccountView: EXAccountTransferSelectorView!
    @IBOutlet var toAccountView: EXAccountTransferSelectorView!
    var upsideDown:Bool = false
    
    typealias TransferAccountTapCallback = ()->()
    var onTransferTapCallback:TransferAccountTapCallback?
    
    typealias TransferAccountUpsidedownCallback = (Bool)->()
    var onTransferUpsidedownCallback:TransferAccountUpsidedownCallback?
    
    override func onCreate() {
        
        transferIcon.image = EXKitBundle.svgImage(named: "assets_indicationpoint")
        exchangeBtn.setImage(EXKitBundle.svgImage(named: "public_transfer_big"), for: .normal)
        fromTitle.font = UIFont.ThemeFont.BodyRegular
        toTitle.font = UIFont.ThemeFont.BodyRegular
        fromTitle.textColor = UIColor.ThemeLabel.colorMedium
        toTitle.textColor = UIColor.ThemeLabel.colorMedium

        fromTitle.text = "transfer_text_from".localized()
        toTitle.text = "transfer_text_to".localized()
        
        fromAccountView.onSelectorTapped = {[weak self] in
            self?.accountTapped()
        }
        
        toAccountView.onSelectorTapped = {[weak self] in
            self?.accountTapped()
        }
    }
    
    func accountTapped() {
        onTransferTapCallback?()
    }
    
    func setFromAccountTitle(_ title:String) {
        fromAccountView.titleLabel.text = title
    }
    
    func setToAccountTitle(_ title:String) {
        toAccountView.titleLabel.text = title
    }
    
    func setFromAccountType(_ accountType:EXAccountType) {
        fromAccountView.accountType = accountType
    }
    
    func setToAccountType(_ accountType:EXAccountType) {
        toAccountView.accountType = accountType
    }
    
    func setMultiAccountStyle(isfromAccountMulti:Bool) {
        if isfromAccountMulti {
            fromAccountView.enableTap = EXAppConfigManager.sharedInstance.hasMultiAccounts()
            toAccountView.enableTap = false
        }else {
            fromAccountView.enableTap = false
            toAccountView.enableTap =  EXAppConfigManager.sharedInstance.hasMultiAccounts()
        }
    }
    
    @IBAction func exchangeBtnAction(_ sender: Any) {
        //Inverted
        fromAccountView.snp.removeConstraints()
        toAccountView.snp.removeConstraints()
        if upsideDown {
            UIView.animate(withDuration: 0.3) {
                self.container.insertArrangedSubview(self.fromAccountView, at: 0)
            }
        }else {
            UIView.animate(withDuration: 0.3) {
                self.container.insertArrangedSubview(self.fromAccountView, at: 1)
            }
        }
        upsideDown = !upsideDown
        onTransferUpsidedownCallback?(upsideDown)
    }
}

