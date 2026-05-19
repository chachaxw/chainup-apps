//
//  EXKitStanders+Ex.swift
//  Chainup
//
//  Created by bradjohn on 2023/12/13.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

extension EXKitStanders {
    
    
    /// get the download channel identifier corresponding to the application (info.plist)
    /// Note: The default channel is app store
    /// - Returns: 0: AppStore 1: TestFlight 9: Enterprise
    class func channelId() -> String {
        let info = Bundle.main.infoDictionary
        if info?.keys.contains("channelId") == true, let channelId = info?["channelId"] as? String, !channelId.isEmpty {
            return channelId
        }
        return "0"
    }
    
    /// Whether the two times are on the same day
    /// - Parameters:
    ///   - timeInterval1: timeInterval1
    ///   - timeInterval2: timeInterval2
    /// - Returns: bool
    class func isSameDay(timeInterval1: String?, timeInterval2: String?) -> Bool {
        guard let timeInterval1 = timeInterval1, !timeInterval1.isEmpty else { return false }
        guard let timeInterval2 = timeInterval2, !timeInterval2.isEmpty else { return false }
        guard let interval1 = Double(timeInterval1) else { return false }
        guard let interval2 = Double(timeInterval2) else { return false }
        let calendar = Calendar.current
        let date1 = Date(timeIntervalSince1970: interval1)
        let date2 = Date(timeIntervalSince1970: interval2)
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
    }
    
}
