//
//  EXOTCMerchantHeaderView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXOTCMerchantHeaderView: NibBaseView {
    
    @IBOutlet var avatarView: EXAvatarView!
    @IBOutlet var mutiView: EXFourColumnView!
    @IBOutlet var horizontalView: EXHorizontalColumnView!
    var merchantModel:EXMerchantModel = EXMerchantModel()
    
    override func onCreate() {
        
    }
    
    func handleUserAuthInfo() {
        
        let model = ExThreeColumnDataModel()
        model.title = "otc_text_merchantPhoneAuth".localized()
        let style = self.getStyle()
        style.topLabelFont = UIFont.ThemeFont.SecondaryRegular
        style.topLabelColor = UIColor.ThemeLabel.colorMedium
        model.style = style
        model.aliment = .left
        if merchantModel.mobileAuthStatus == "1" {
            model.iconStatus = true
        }

        let modelm = ExThreeColumnDataModel()
        modelm.title = "common_text_identify".localized()
        modelm.style = style
        modelm.aliment = .center
        if merchantModel.authLevel == "1" {
            modelm.iconStatus = true
        }
        
        let modelr = ExThreeColumnDataModel()
        modelr.title = ""

        horizontalView.bindItems([model,modelm,modelr])
    }
    
    func handleUserInfo() {
        let style = self.getStyle()
        style.topLabelFont = UIFont.ThemeFont.SecondaryRegular
        let model = ExThreeColumnDataModel()
        model.title = "otc_text_merchantTradeNumber".localized()
        model.content = merchantModel.completeOrders
        model.aliment = .left
        model.style = style
        
//        let modelm = ExThreeColumnDataModel()
//        modelm.title = "otc_text_merchantAppealNumber".localized()
//        modelm.content = merchantModel.complainNum
//        modelm.style = style
//        modelm.aliment = .center
//
//        let modelr = ExThreeColumnDataModel()
//        modelr.title = "otc_text_merchantAppealWin".localized()
//        modelr.content = merchantModel.sucComplainNum
//        modelr.style = style
//        modelm.aliment = .center

        let modelf = ExThreeColumnDataModel()
        modelf.title = "otc_text_merchantCredit".localized()
        modelf.content = merchantModel.trustScore
        
        modelf.aliment = .right
        modelf.style = style
        mutiView.bindItems([model,modelf])
    }
    
    func getStyle()->ExThreeColumnStyle {
        let style = ExThreeColumnStyle()
        style.bottomLabelColor = UIColor.ThemeLabel.colorLite
        return style
    }
    
    func bindHeaderInfo(model:EXMerchantModel) {
        self.merchantModel = model
        self.handleUserInfo()
        self.handleUserAuthInfo()
        avatarView.bindAvatarInfo(name: model.otcNickName,
                                  avatarImg: model.imageUrl,
                                  userOnline: model.loginStatus == "1")
    }
}
