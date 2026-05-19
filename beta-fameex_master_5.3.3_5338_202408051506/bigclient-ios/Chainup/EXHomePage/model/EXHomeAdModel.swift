//
//  EXHomeAdModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/23.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit


class EXHomeAdModel: EXBaseModel {
    var startTime:String = "" {
        didSet {
            if startTime.count >= 13 {
                if let t = Int(startTime.prefix(10)){
                    startTimeInterval = t
                }
            }
        }
    }
    var endTime:String = "" {
        didSet {
            if endTime.count >= 13 {
                if let t = Int(endTime.prefix(10)){
                    endTimeInterval = t
                }
            }
        }
    }
    var startTimeInterval:Int = 0
    var endTimeInterval:Int = 0
    
    var id:String = ""
    var picture:String = ""
    var pictureUrl:String = ""
    var picturePath:String = ""
    var isLogin:String = ""//0 not logged in, 1 logged in, 2 logged in for the first time every day (natural days), 3 logged in for the first time every day (natural days)
    var activityTitle:String = ""//name
    var pictureDLPath:String = ""
    
    class func isNeedShowToday(startTime:Int,endTime:Int,isLogin:String) -> Bool{
        
        let now = DateTools.getNowTimeInterval()
        if now >= startTime, now < endTime {
            if XUserDefault.isOffLine() {
                if isLogin == "1" || isLogin == "2" {
                    return false
                }else {
                    if isLogin == "0" {
                        return true
                    }else if isLogin == "3" {
                        if let time = EXAppCache.sharedCache.getAppAdShowTime() {
                            if DateTools.isBeforeToday(from: time) {
                                return true
                            }else {
                                return false
                            }
                        }else {
                            return true
                        }
                    }
                }
            }else {
                if isLogin == "0" || isLogin == "1" {
                    return true
                }else {
                    if isLogin == "2" || isLogin == "3" {
                        if let time = EXAppCache.sharedCache.getAppAdShowTime() {
                            if DateTools.isBeforeToday(from: time) {
                                return true
                            }else {
                                return false
                            }
                        }else {
                            return true
                        }
                    }
                }
            }
            return false
        }else {
            return false
        }
    }
}

