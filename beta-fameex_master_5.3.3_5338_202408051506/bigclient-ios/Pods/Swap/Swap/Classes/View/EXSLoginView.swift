//
//  EXSLoginView.swift
//  EXSwapSDK
//
//  Created by ZYJ on 2023/5/5.
//

import UIKit

class EXSLoginView: EXSNibBaseView {
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var tipImageView: UIImageView!
    @IBOutlet weak var tipLabel: UILabel!
    override func onCreate() {
        backgroundColor = UIColor.ThemeView.card1
        tipLabel.textColor = UIColor.ThemeLabel.colorMedium
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .center
        tipLabel.font = UIFont.ThemeFont.SecondaryRegular
        confirmButton.layer.cornerRadius = 4
        confirmButton.setTitleColor(.Ex.text4, for: .normal)
        confirmButton.backgroundColor = .Ex.main1
        confirmButton.titleLabel?.font = .Ex.medium(14)
        tipImageView.snp.remakeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tipLabel.snp.top).offset(-8)
        }
        tipLabel.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(confirmButton.snp.top).offset(-26)
        }
        confirmButton.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
        
    }
    func setupLoginUI() {
        tipLabel.text = "cp_overview_text64".ex_localized()
        tipImageView.image = UIImage.svg_themeImageNamed(imageName: "trade_treaty_notopened")
        confirmButton.setTitle("cp_overview_text67".ex_localized(), for: .normal)
    }
    func setupRegisterUI() {
        tipLabel.text = "cp_overview_text65".ex_localized()
        tipImageView.image = UIImage.svg_themeImageNamed(imageName: "trade_treaty_illustration")
        confirmButton.setTitle("cp_overview_text66".ex_localized(), for: .normal)

    }
}
