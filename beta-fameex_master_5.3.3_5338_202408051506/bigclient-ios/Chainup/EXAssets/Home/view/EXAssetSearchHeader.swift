//
//  EXAssetSearchHeader.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXAssetSearchHeader: NibBaseView {
    @IBOutlet var checkBox: EXCheckBox!
    @IBOutlet var searchBar: UITextField!
    @IBOutlet var searchIcon: UIImageView!
    @IBOutlet weak var questionButton: UIButton!
    
    override func onCreate() {
        let searchTitle = "assets_action_search".localized()
        let checkTitle = "assets_action_privacy".localized()
        let contentWidth = checkTitle.textSizeWithFont(UIFont.ThemeFont.SecondaryRegular, width:CGFloat.greatestFiniteMagnitude).width
        searchIcon.image = UIImage.themeImageNamed(imageName: "public_search")
        
        searchBar.setPlaceHolderAtt(searchTitle)
        checkBox.text(content: checkTitle)
        checkBox.checkLabel.textColor = UIColor.ThemeLabel.colorMedium
        checkBox.checkLabel.font = UIFont.ThemeFont.SecondaryRegular
        checkBox.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-25)
            make.centerY.equalToSuperview()
            make.width.equalTo(contentWidth + 25)
        }
        
        searchBar.snp.makeConstraints { (make) in
            make.left.equalTo(searchIcon.snp.right).offset(8)
            make.right.equalTo(checkBox.snp.left).offset(-5)
            make.centerY.equalToSuperview()
        }
        
        questionButton.setEnlargeEdgeWithTop(30, left: 30, bottom: 30, right: 30)
    }
    @IBAction func onQuestionAction(_ sender: Any) {
        let alert = EXNormalAlert()
        let amount = EXAppConfigManager.sharedInstance.configVm.cfgModel.minHoldAccount.newString()
        let tip = String(format: "assets_less_than_0.0001BTC".localized(), amount)
        alert.configSigleAlert(title: tip, message: "", sigleBtnTitle: "alert_common_i_understand".localized())
        EXAlert.showAlert(alertView: alert)
    }
    
}
