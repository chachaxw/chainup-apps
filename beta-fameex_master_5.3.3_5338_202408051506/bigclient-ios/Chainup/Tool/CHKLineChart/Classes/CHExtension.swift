//
//  CHExtension.swift
//  CHKLineChart
//
//  Created by Chance on 2023/9/8.
//  Copyright © 2023年 Chance. All rights reserved.
//

import Foundation
import UIKit
import EXKit
//String class extension
public extension String {
    
    /**
Calculate the width of text
     
     - parameter width:
     - parameter font:
     
     - returns:
     */
    func ch_sizeWithConstrained(_ font: UIFont,
                                constraintRect: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)) -> CGSize {
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil)
        return boundingBox.size
    }
    
    ///String length
    var ch_length: Int {
        return self.count;
    }
}


public extension UIColor {
    
    /**
Hexadecimal represents color
     
     - parameter hex:
     
     - returns:
     */
    class func ch_hex(_ hex: UInt, alpha: Float = 1.0) -> UIColor {
        return UIColor(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(hex & 0x0000FF) / 255.0,
                       alpha: CGFloat(alpha))
    }
    
}

public extension Date {
    
    /*!
*@ method converts timestamp to user format time
     * @abstract
     * @discussion
*@ param timestamp timestamp
*@ param format format
*@ result time
     */
    static func ch_getTimeByStamp(_ timestamp: Int, format: String) -> String {
        var time = ""
        if (timestamp == 0) {
            return ""
        }
        return DateTools.timeStampToString(TimeInterval(timestamp), dateFormat: format)
//        DateHelper.shared.dateFormatter.dateFormat = format
//        return DateHelper.shared.timestampToFormattedString(timestamp: TimeInterval(timestamp))
//        let confromTimesp = Date(timeIntervalSince1970: TimeInterval(timestamp))
//        let formatter = DateFormatter()
//        formatter.dateFormat = format
//        time = formatter.string(from: confromTimesp)
//        return time;
    }
    
    static func klineTimeFormat(_ timestamp: Int, timekey: String) -> String {
        let arr = ["1day", "1week", "1month"]
        var newText = Date.ch_getTimeByStamp(timestamp, format: "MM/dd HH:mm")
        if timekey.count > 0 && arr.contains(timekey){
            newText = Date.ch_getTimeByStamp(timestamp, format: "YY/MM/dd")
        }
        return newText
    }
}


public extension CGFloat {
    
    /**
Convert to string format
     
     - parameter minF:
     - parameter maxF:
     - parameter minI:
     
     - returns:
     */
    func ch_toString(maxF: Int? = 0) -> String {
        let str = "\(self)"
        if maxF! == 0 {
            return str
        }
        let result = str.formatAmountUseDecimal(String(maxF!),holdZero: true)
        return result
    }
}

public extension Array where Element: Equatable {
    
    subscript (safe index: Int) -> Element? {
        return (0..<count).contains(index) ? self[index] : nil
    }
    
    mutating func ch_removeObject(_ object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
    mutating func ch_removeObjectsInArray(_ array: [Element]) {
        for object in array {
            self.ch_removeObject(object)
        }
    }
}

