//
//  DateExtension.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/23.
//  Copyright © 2023 Chainup. All rights reserved.
//

import Foundation

extension Date {
    
    func isBetween(date dateBegin:Date,date2 dateEnd:Date) -> Bool {
        return dateBegin.compare(self) == self.compare(dateEnd)
    }
    
    ///Obtain the current second level timestamp -10 bits
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    ///Obtain the current millisecond level timestamp -13 bits
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}

