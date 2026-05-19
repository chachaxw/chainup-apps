//
//  EXContractDocumentaryShareView.swift
//  Chainup
//
//  Created by wangdong on 2023/1/18.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import YYWebImage
import EXKit
import Swap
class EXContractDocumentaryShareView: NibBaseView {
    
    @IBOutlet weak var shareContentView: UIView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var sloganLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var amountTypeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var amountSource: Array<(String, String, Bool)> = []
    
    var model: JSKolShareDialogModel?
    
    var endCaptureImage: ((UIImage, Int) -> ())?
    
    var sourceIndex = 0
    
    convenience init(model: JSKolShareDialogModel) {
        self.init()
        self.model = model
        
        let qrIcon = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator", codeString: UserInfoEntity.sharedInstance().inviteUrl, size: CGSize(width: 50, height: 50), qrColor: UIColor.ThemeLabel.colorLite, bkColor: UIColor.ThemeView.bg)
        
        qrCodeImageView.image = qrIcon
        
        if model.win_rate_week.isEmpty == false {
            var up = true
            var rate = model.win_rate_week.formatAmountUseDecimal("2")
            if model.win_rate_week.greaterThanOrEqual(BTZERO) {
                rate = "+" + rate
            } else {
                up = false
            }
            amountSource.append(("contract_total_profit".localized(), rate, up))
        }
        
        if model.profit_rate.isEmpty == false {
            
            var up = true
            var rate = model.profit_rate.formatAmountUseDecimal("2") + "%"
            if model.profit_rate.greaterThanOrEqual(BTZERO) {
                rate = "+" + rate
            } else {
                up = false
            }
            
            amountSource.append(("", rate, up))
        }
        
        if model.win_rate.isEmpty == false {
            
            var up = true
            var rate = model.win_rate.formatAmountUseDecimal("2") + "%"
            if model.win_rate.greaterThanOrEqual(BTZERO) {
                rate = "+" + rate
            } else {
                up = false
            }
            
            amountSource.append(("contract_win_rate".localized(), rate, up))
        }
        
        if let url = URL.init(string: EXAppConfigManager.sharedInstance.getAppLogo().logo_white){
            logoImageView.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
        }
        
        closeButton.setEnlargeEdgeWithTop(20, left: 20, bottom: 20, right: 20)
        leftButton.setEnlargeEdgeWithTop(20, left: 20, bottom: 20, right: 20)
        rightButton.setEnlargeEdgeWithTop(20, left: 20, bottom: 20, right: 20)
        
        usernameLabel.text = model.user_name
        descLabel.text = ""
        
        sloganLabel.text = EXKitStanders.getAppName() + "-" + "common_share_detail".localized()
        
        updateAmount()
    }
    
    func updateAmount() {
        
        if amountSource.count == 0 {
            return
        }
        
        if sourceIndex >= amountSource.count {
            sourceIndex = 0
        }
        if sourceIndex < 0 {
            sourceIndex = amountSource.count - 1
        }
        
        let tuple = amountSource[sourceIndex]
        amountTypeLabel.text = tuple.0
        amountLabel.text = tuple.1
        amountLabel.textColor = tuple.2 ? UIColor.ThemekLine.up : UIColor.ThemekLine.down
    }
    
    override func onCreate() {

    }
    
    @IBAction func onCloseAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func onLongPressAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            
            let sheet = EXOldActionSheetView()
            sheet.manualDismiss = true
            sheet.actionIdxCallback = {[weak self](idx) in
                guard let self = `self` else { return }
                                
                UIGraphicsBeginImageContextWithOptions(self.shareContentView.frame.size, false, UIScreen.main.scale)
                self.shareContentView.layer.render(in: UIGraphicsGetCurrentContext()!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsGetCurrentContext()
                
                if let image = image {
                    self.endCaptureImage?(image, idx)
                }
                
                EXAlert.dismissEnd {
                    self.close()
                }
            }
            sheet.configButtonTitles(buttons:  ["sl_str_save_image".localized(), "common_share_confirm".localized()])
            EXAlert.showSheet(sheetView: sheet)
        }
    }
    
    @IBAction func onLeftAction(_ sender: Any) {
        sourceIndex =  sourceIndex - 1
        updateAmount()
    }
    
    @IBAction func onRightAction(_ sender: Any) {
        sourceIndex =  sourceIndex + 1
        updateAmount()
    }
    
    func close() {
        self.removeFromSuperview()
    }
    
    deinit {
        print(1)
    }
    
}

