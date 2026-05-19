//
//  EXQRAddressView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXQRAddressView: NibBaseView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleIconWidth: NSLayoutConstraint!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var copyBtn: EXButton!
    @IBOutlet var tipIcon: UIImageView!
    
    override func onCreate() {
        tipIcon.contentMode = UIView.ContentMode.right
        let icon = UIImage.themeImageNamed(imageName: "public_hint").reSizeImage(reSize: CGSize(width: 12, height: 12))
        tipIcon.image = icon
        titleLabel.text = "charge_text_chargeAddress".localized()
        addressLabel.text = "--"
        titleLabel.font = UIFont.ThemeFont.SecondaryMedium
        addressLabel.font = UIFont.ThemeFont.Semibold
        copyBtn.color = UIColor.ThemeView.bgTab
        copyBtn.titleLabel?.font = UIFont.ThemeFont.SecondaryBold
        copyBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        titleIconWidth.constant = 0
        tipIcon.isHidden = true
        
        
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        tap.rx.event.asControlEvent().subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.addressLabel.text?.copyToPasteBoard()
            EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
        }).disposed(by: disposeBag)

        
        
        copyBtn.rx.tap.throttle(.seconds(3), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] in
            self?.addressLabel.text?.copyToPasteBoard()
            EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
        }).disposed(by: self.disposeBag)
    }
    
    func showIcon() {
        tipIcon.isHidden = false 
        titleIconWidth.constant = 17
    }
    
    @IBAction func tipBtnAction(_ sender: Any) {
        if tipIcon.isHidden == false {
            let normal = EXNormalAlert()
            normal.configSigleAlert(title: "common_text_tip".localized(), message: "charge_tip_tagWarning".localized())
            EXAlert.showAlert(alertView: normal)
        }

    }
    
    func setCopyBtnTitle(title:String){
        copyBtn.setTitle(title, for: .normal)
    }
    
}
