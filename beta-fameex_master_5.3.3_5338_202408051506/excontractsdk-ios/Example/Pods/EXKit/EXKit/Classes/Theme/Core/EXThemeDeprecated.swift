//
//  EXThemeDeprecated.swift
//  EXKit
//
//  Created by zq on 2023/4/19.
//

import UIKit

internal let lastThemeIndexKey = "lastedThemeIndex"
internal let lastedKlineIndex = "lastedKlineIndex"

public class EXUIDatasource: NSObject {

    public var confirmTitle:String = "Confirm"
    public var cancelTitle:String = "Cancel"
    public var networkError:String = "Network Error"
    public var isDarkConfig:Bool = false
    public var check_network_settings:String = ""
    public var common_tip_nodata:String = ""
    public var check_network:String = ""
    public var noun_date_day:String = ""
    public var noun_date_hour:String = ""
    public var noun_date_minute:String = ""
    public var scan_tip_aimToScan:String = ""
    public var check_refresh_more:String = ""
    public var scan_photo_title:String = ""
    public var scan_fail_msg:String = ""
    public var no_data:String = ""
    public var alertOnlyBtnTitle:String = ""
    //下拉刷新
    public var refresh_up_Title:String = ""
    public var refresh_down_Title:String = ""
    public var refresh_trigger:String = ""
    public var refresh_refreshing:String = ""
    public var refresh_refresh_complete:String = ""
    public var refresh_noMoreData:String = ""
    public var supportVoiceCode:Bool = false //是否支持语音验证码
    
    public static var shared : EXUIDatasource {
        struct Static {
            static let instance : EXUIDatasource = EXUIDatasource()
        }
        return Static.instance
    }

}
