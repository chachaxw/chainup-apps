//
//  EXAppLaunchConfig.swift
//  Chainup
//
//  Created by cwd on 2022/9/9.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXAppLaunchConfig: NSObject {
    //MARK: Must be updated after contract language initialization, otherwise ex_ Localized() will result in a language blank/contract interface that requires the use of multiple languages for the contract
   
    static func upDateEXKitConfig(){
        EXUIDatasource.shared.alertOnlyBtnTitle = "guide_3".localized()
        EXUIDatasource.shared.confirmTitle = "common_text_btnConfirm".localized()
        EXUIDatasource.shared.cancelTitle = "common_text_btnCancel".localized()
        EXUIDatasource.shared.networkError = "check_network_error_settings".localized()
        EXUIDatasource.shared.check_network_settings = "check_network_settings".localized()
        EXUIDatasource.shared.common_tip_nodata = "common_tip_nodata".localized()
        EXUIDatasource.shared.check_network = "check_network".localized()
        EXUIDatasource.shared.noun_date_day = "noun_date_day".localized()
        EXUIDatasource.shared.noun_date_hour = "noun_date_hour".localized()
        EXUIDatasource.shared.noun_date_minute = "noun_date_minute".localized()
        EXUIDatasource.shared.check_refresh_more = "check_refresh_more".localized()
        EXUIDatasource.shared.scan_photo_title = "scan_text_album".localized()
//        EXUIDatasource.shared.common_back_img = UIImage.themeImageNamed(imageName: "public_return_night")
//        EXUIDatasource.shared.scan_photo_img = UIImage.themeImageNamed(imageName: "home_scancode_picture_night")
        EXUIDatasource.shared.scan_fail_msg = "scan_fail_msg".localized()
        EXUIDatasource.shared.scan_tip_aimToScan = "scan_tip_aimToScan".localized()
//        EXUIDatasource.shared.emptyImage = UIImage.svgImage(named: "public_nocontentyet") ?? UIImage()
        EXUIDatasource.shared.alertOnlyBtnTitle =  "common_text_btnConfirm".localized()

//        EXUIDatasource.shared.check_img = UIImage.svgImage(named: "public_checked")
//        EXUIDatasource.shared.unCheck_img = UIImage.themeImageNamed(imageName:"quotes_unselected")
//        EXUIDatasource.shared.refresh_image = UIImage.svgImage(named: "loading") ?? UIImage()
        EXUIDatasource.shared.refresh_up_Title = "common_text_upToRefresh".localized()
        EXUIDatasource.shared.refresh_down_Title = "common_text_downToRefresh".localized()
        EXUIDatasource.shared.refresh_trigger = "common_text_triggerRefresh".localized()
        EXUIDatasource.shared.refresh_refreshing = "common_text_refreshing".localized()
        EXUIDatasource.shared.refresh_refresh_complete = "common_text_refresh_complete".localized()
        EXUIDatasource.shared.refresh_noMoreData = "common_text_noMoreData".localized()
        EXUIDatasource.shared.no_data = "common_tip_nodata".localized()
//        EXUIDatasource.shared.netFailImage = UIImage.svgImage(named: "public_wifi") ?? UIImage()
        EXUIDatasource.shared.camecaErrorTip = "common_tip_cameraPermission".localized()
        EXUIDatasource.shared.albumErrorTip = "common_tip_albumPermission".localized()

    }
}


